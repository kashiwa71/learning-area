# スキル

同じ手順を何度もチャットに貼り付けているなら、それはスキルにする合図である。
`CLAUDE.md` の一節が事実の記述ではなく手順の説明に育ってしまったときも同じで、そこはスキルに移す。

スキルの本文は、呼び出されたときにだけ読み込まれる。常駐するのは `description` の一行だけなので、
長い手順書を用意しても、使わないセッションではほとんど代金がかからない。

## 最小のスキル

ディレクトリを作り、その中に `SKILL.md` を置く。ディレクトリ名がそのままコマンド名になる。

```text
.claude/skills/summarize-changes/SKILL.md
```

```markdown
---
description: 未コミットの変更を要約し、危なそうな箇所を挙げる。何を変えたか聞かれたとき、コミットメッセージを求められたときに使う。
---

## 現在の変更

!`git diff HEAD`

## 指示

上の差分を2〜3個の箇条書きに要約し、続けて気付いた risk を挙げる。エラー処理の欠落、
ハードコードされた値、更新が必要なテストなど。差分が空なら、未コミットの変更は無いと答える。
```

これで `/summarize-changes` と打てば呼び出せる。`description` に書いた状況に当てはまるとエージェントが判断すれば、
打たなくても自動で読み込まれる。

`` !`git diff HEAD` `` の行は、スキルが読み込まれる前にシェルで実行され、出力に置き換わる。
エージェントは差分が埋め込まれた状態の文章を受け取るので、「差分を見て」と指示してから読ませるより一往復少なくて済む。

## 置き場所

| 場所 | パス | 効く範囲 |
|------|------|---------|
| 個人 | `~/.claude/skills/<名前>/SKILL.md` | 自分の全プロジェクト |
| プロジェクト | `.claude/skills/<名前>/SKILL.md` | そのプロジェクト |
| プラグイン | `<plugin>/skills/<名前>/SKILL.md` | プラグインを有効にした場所 |

同じ名前があるときは、個人がプロジェクトより優先される。プラグインのスキルは
`plugin-name:skill-name` の名前空間に入るので衝突しない。

古い `.claude/commands/*.md` の形式も動き続ける。同じ名前でスキルとコマンドが両方あればスキルが勝つ。
新しく作るならスキルのほうがよい。付随ファイルを同じディレクトリに置けて、
誰が呼び出せるかをフロントマターで制御できる。

## フロントマター

すべて任意で、`description` だけは書いたほうがよい。エージェントがいつ使うかを判断する材料になる。

| 項目 | 用途 |
|------|------|
| `name` | 一覧での表示名。省略するとディレクトリ名 |
| `description` | 何をするスキルか、いつ使うか。主な用途を先頭に書く |
| `when_to_use` | 呼び出す状況の補足。きっかけになる言い回しや依頼の例 |
| `argument-hint` | 補完時に出す引数のヒント。`[issue-number]` など |
| `arguments` | 名前付き引数の宣言。`$名前` で本文から参照する |
| `disable-model-invocation` | `true` にすると自動では読み込まれず、`/名前` でだけ動く |
| `user-invocable` | `false` にすると `/` メニューに出ず、エージェントだけが使う |
| `allowed-tools` | そのターンだけ許可を求めずに使えるツール |
| `disallowed-tools` | そのスキルが動いている間、使わせないツール |
| `model` / `effort` | そのスキルの間だけモデルや思考量を変える |
| `context` | `fork` にすると別コンテキストのサブエージェントで動く |
| `paths` | 一致するファイルを扱うときだけ自動で読み込む |

`description` と `when_to_use` を合わせた文字列は、一覧の中で 1,536 文字に切り詰められる。
長く書くほど末尾が落ちるので、肝心の用途を先頭に置く。

副作用のある作業（デプロイ、本番へのプッシュ、破壊的なマイグレーション）には
`disable-model-invocation: true` を付ける。エージェントの判断で勝手に始まっては困るものを、
手で打ったときだけ動くようにできる。

## 引数を渡す

`$ARGUMENTS` は、スキル名の後ろに打った文字列すべてに置き換わる。

```markdown
---
name: fix-issue
description: GitHub の issue を修正する
disable-model-invocation: true
---

issue $ARGUMENTS を、このリポジトリの規約に従って修正する。

1. issue の内容を読む
2. 関係するファイルを特定する
3. 修正する
4. テストを書いて走らせる
5. コミットする
```

`/fix-issue 123` と打てば `$ARGUMENTS` が `123` になる。位置で取りたいときは `$0`、`$1` と書く
（`$ARGUMENTS[0]` の短縮形）。フロントマターに `arguments: [issue, branch]` と宣言しておけば、
`$issue`、`$branch` の名前で参照できる。

複数語をひとまとまりで渡したいときは、`/my-skill "hello world" second` のように引用符で囲む。

## 使える置換

| 変数 | 中身 |
|------|------|
| `$ARGUMENTS` | 渡された引数の全体 |
| `$0`、`$1`、… | 位置で取り出した引数 |
| `${CLAUDE_SKILL_DIR}` | その `SKILL.md` があるディレクトリ |
| `${CLAUDE_PROJECT_DIR}` | プロジェクトのルート |
| `${CLAUDE_SESSION_ID}` | 現在のセッション ID |
| `${CLAUDE_EFFORT}` | 現在の思考量の設定 |

`${CLAUDE_SKILL_DIR}` は本文と `allowed-tools` の両方で展開される。同じ書き方を両方に置けば、
同梱したスクリプトを許可を求めずに実行できる。

```markdown
---
name: render-chart
description: CSV からグラフを描く
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/render.sh *)
---

`${CLAUDE_SKILL_DIR}/scripts/render.sh <csv-file>` を実行してグラフを描く。
```

## 付随ファイル

`SKILL.md` は 500 行までに収め、詳しい参照資料は同じディレクトリの別ファイルに置く。
別ファイルは、エージェントが必要と判断したときに読まれる。

```text
my-skill/
├── SKILL.md        入口。何をするか、どのファイルに何があるか
├── reference.md    詳細な仕様
├── examples.md     使用例
└── scripts/
    └── helper.py   実行されるだけで、読み込まれない
```

`SKILL.md` の中から、各ファイルに何が書いてあるかを説明しておく。

```markdown
## 参照

- 完全な仕様は [reference.md](reference.md)
- 使用例は [examples.md](examples.md)
```

## 本文を短く保つ

一度読み込まれたスキルの本文は、そのセッションの間コンテキストに残り続ける。
毎ターン代金がかかるので、`CLAUDE.md` と同じ節約が要る。なぜそうするのかの説明ではなく、
何をするのかだけを書く。

## このリポジトリの実例

- [.claude/skills/new-project-setup/SKILL.md](../.claude/skills/new-project-setup/SKILL.md)：新しいプロジェクトの初期設定を対話で進める
- [.claude/skills/claude-md-review/SKILL.md](../.claude/skills/claude-md-review/SKILL.md)：`CLAUDE.md` を点検して削る候補を出す

## 演習

- [最初のスキルを作る](../exercises/03-first-skill/README.md)
