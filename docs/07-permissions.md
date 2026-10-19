# 権限と設定

`settings.json` は、エージェントに何を許すかを決める設定ファイルである。指示文と違って、
書いた内容はモデルの判断を経ずに Claude Code 側で適用される。

許可の設計を怠ると、確認のたびに手が止まる。十回目の確認では、開発者はもう読まずに承認を押している。
安全だと分かっている操作を先に許可しておくことが、結果として危ない操作への注意を守る。

## 置き場所と優先順位

同じ項目が複数の場所にあるときは、上にあるものが勝つ。

| 順 | ファイル | 決める人 |
|----|---------|---------|
| 1 | 管理ポリシー（`managed-settings.json`） | 組織 |
| 2 | `claude --settings` | 自分、そのセッションだけ |
| 3 | `.claude/settings.local.json` | 自分、そのプロジェクト（`.gitignore` に入れる） |
| 4 | `.claude/settings.json` | チーム全員（git に入れる） |
| 5 | `~/.claude/settings.json` | 自分、全プロジェクト |

厳密な JSON なので、`//` のコメントや末尾のカンマを書くと読み込みに失敗する。
先頭に `$schema` を書いておくと、エディタで補完と検証が効く。

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(npm run lint)",
      "Bash(npm run test *)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)"
    ]
  }
}
```

保存すれば動作中のセッションにも反映される。読み込まれたかどうかは `/status` で確認できる。

## allow、ask、deny

- **allow**：確認せずに実行させる。
- **ask**：毎回確認する。
- **deny**：実行させない。

評価は deny、ask、allow の順で、最初に一致したものが結果になる。ルールの具体性は順序を変えない。
`Bash(aws *)` を deny に置くと、`Bash(aws s3 ls)` を allow に書いても実行されない。
広い deny に例外を持たせる書き方はできないので、禁じたいものだけを狭く書く。

`Bash` のようにツール名だけを deny に書くと、そのツールがエージェントから見えなくなる。
`Bash(rm *)` のように括弧付きで書けば、ツールは残り、一致する呼び出しだけが拒否される。

## Bash のルール

コマンド全体の文字列に対して照合し、`*` が任意の文字列に当たる。

```json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Bash(git commit *)"],
    "deny": ["Bash(git push *)"]
  }
}
```

`*` はサブコマンドの後ろに置く。最初の `*` より前は書いたとおりに照合されるので、
そこまでの語がルールの範囲を決める。

| 書き方 | 一致する | 一致しない |
|--------|---------|-----------|
| `Bash(npm run build)` | `npm run build` | `npm run build --watch` |
| `Bash(npm run *)` | `npm run build`、`npm run test --watch`、`npm run` | `npm install` |
| `Bash(git * main)` | `git merge main`、`git push origin main` | `git log` |
| `Bash(ls *)` | `ls -la`、`ls` | `lsof` |
| `Bash(ls*)` | `ls -la`、`lsof` | |

`Bash(git * main)` のように `*` をサブコマンドの位置に置くと、`git push` まで通ってしまう。
末尾の `*` の直前の空白はルールの一部で、`Bash(ls *)` は `lsof` に一致しない。
`Bash(ls:*)` は `Bash(ls *)` と同じ意味になる。

複合コマンドは分解して照合される。`&&`、`||`、`;`、`|`、`&`、改行が区切りとして認識され、
それぞれが独立に一致しなければ通らない。`Bash(safe-cmd *)` を許可しても
`safe-cmd && rm -rf /` は通らない。

一方で、`npx`、`docker exec`、`devbox run` のような、引数をコマンドとして実行する道具は
この分解の対象外である。`Bash(devbox run *)` を許可すると `devbox run rm -rf .` まで通る。
実行環境を挟む場合は `Bash(devbox run npm test)` のように、内側のコマンドまで含めて書く。

`ls`、`cat`、`grep`、`find`、読み取り系の `git` などは、組み込みで読み取り専用と見なされ、
どのモードでも確認なしに実行される。この集合は変更できない。確認させたいなら `ask` か `deny` を足す。

## ファイルのルール

`Read` と `Edit` は gitignore と同じパターン構文を使う。先頭の記号で基準の位置が変わる。

| 書き方 | 基準 | 例 |
|--------|------|-----|
| `//path` | ファイルシステムのルート | `Read(//Users/alice/secrets/**)` |
| `~/path` | ホームディレクトリ | `Read(~/Documents/*.pdf)` |
| `/path` | その設定ファイルの位置 | `Edit(/src/**/*.ts)` |
| `path`、`./path` | 現在のディレクトリ | `Read(*.env)` |

`/Users/alice/file` は絶対パスにならない。スラッシュ一つは設定ファイルの位置を基準にする。
絶対パスを書くならスラッシュを二つ重ねる。

`Read` の deny は、同じパスへの `Edit` と `Write` も止める。ただし `NotebookEdit` は対象外なので、
どのツールにも変更させたくないパスには `Edit` の deny も書く。
`Write(...)`、`Glob(...)` にパスを書いたルールは受け付けられるが参照されない。
書き込みの禁止は `Edit(...)`、読み取りの禁止は `Read(...)` に寄せる。

これらはエージェントのファイルツールと、Claude Code が認識できる `cat` や `sed` に効く。
Python スクリプトがファイルを開くような間接的な読み書きは止まらない。
OS の層で塞ぎたいならサンドボックスを使う。

## その他のツール

`WebFetch` はホスト名で照合する。

- `WebFetch(domain:example.com)`：そのホスト
- `WebFetch(domain:*.example.com)`：任意の深さのサブドメイン（`example.com` 自体は含まない）

MCP のツールは、サーバ名とツール名で指定する。

- `mcp__puppeteer`：そのサーバのすべてのツール
- `mcp__puppeteer__puppeteer_navigate`：そのツールだけ

## 動作モード

セッションが始まるときのモードは、`settings.json` の `defaultMode` で決められる。

| モード | 動き |
|--------|------|
| `default` | ツールを初めて使うときに確認する |
| `acceptEdits` | ファイル編集と `mkdir` などを自動で承認する |
| `plan` | 読むだけ。ソースを書き換えない |
| `auto` | 別のモデルが安全性を確認したうえで自動承認する |
| `dontAsk` | 事前に許可したもの以外は自動的に拒否する |
| `bypassPermissions` | 確認を飛ばす |

`bypassPermissions` は `.git` や `.claude` への書き込みも通る。
コンテナや VM のように、壊れても影響が閉じる環境でだけ使う。

## 最初に許可するもの

プロジェクトを始めるとき、次の三種類を `.claude/settings.json` に入れておくと確認の回数が大きく減る。

1. 何度も走らせるコマンド（テスト、リント、型検査、ビルド）
2. 読み取り専用の調査コマンド
3. 危険なものの明示的な禁止（`.env` の読み取り、本番へのプッシュ、`rm -rf`）

その場で承認するときに「今後は確認しない」を選ぶと、選んだ内容がファイルに追記される。
しばらく使ってから `/permissions` で一覧を眺め、チームで共有すべきものを
`.claude/settings.local.json` から `.claude/settings.json` へ移す、という育て方でよい。

雛形は [templates/settings.json](../templates/settings.json) に置いてある。
