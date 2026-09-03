---
name: new-project-setup
description: 新規プロジェクトのエージェント向け設定を、検証手段から順に作る。git init 直後のリポジトリや、CLAUDE.md がまだ無いプロジェクトで使う。
argument-hint: [プロジェクトの一行説明]
disable-model-invocation: true
---

新しいプロジェクトの設定を立ち上げる。対象：$ARGUMENTS

## 現在の状態

!`ls -a | head -30`

!`test -f CLAUDE.md && echo "CLAUDE.md あり" || echo "CLAUDE.md なし"`

!`test -d .claude && find .claude -type f | head -20 || echo ".claude なし"`

## 進め方

順序を守る。後ろの段階を先にやると、まだ起きていない問題への対策を書くことになる。

### 1. 検証手段を確かめる

このプロジェクトで、合否を終了コードで返すコマンドが何かを調べる。
`package.json` の scripts、`Makefile`、`pyproject.toml` などを読む。
見つからなければ、AskUserQuestion でユーザーに聞く。答えが「まだ無い」なら、
先にそれを作ることを提案し、ここで止まる。設定を足しても、検証手段が無い限り
任せられる範囲は広がらない。

### 2. 権限を許可する

`.claude/settings.json` を作る（既にあれば追記する）。入れるもの。

- 手順 1 で特定した検証コマンド
- 繰り返し使う開発コマンド（ビルド、フォーマッタ、型検査）
- `git add`、`git commit`、`git diff`、`git log`

`deny` に入れるもの。

- `Read(./.env)` と `Read(./.env.*)`
- `Bash(git push --force *)`
- そのプロジェクトで触られたくないパスがあれば `Edit(...)` で

`git push` を `allow` に入れるかは、AskUserQuestion で確認する。

### 3. CLAUDE.md を書く

ユーザーに聞かないと分からないことだけを、AskUserQuestion でまとめて聞く。
コードを読めば分かることは聞かない。聞く候補。

- このプロジェクトが何をするものか（一、二文）
- 既定と違う規約があるか
- 触ると壊れる場所、環境の前提
- ブランチとコミットの慣習

集めた内容で `CLAUDE.md` を書く。40 行程度に収める。この時点で書けるのは、
コマンドと、ユーザーがすでに決めている方針だけである。予防的な規約を足さない。

### 4. .gitignore を確認する

`CLAUDE.local.md` と `.claude/settings.local.json` が無視対象に入っているか確かめ、
入っていなければ足す。

### 5. 報告する

作ったファイルを一覧で示し、次にやることとして以下を伝える。

- `claude` を起動して `/context` を叩き、`CLAUDE.md` が読み込まれているか確認する
- 規約は、破られたときに足す。予防的に書かない
- 同じ手順を三回チャットに貼ったらスキルにする
- `CLAUDE.md` が 200 行に近付いたら、ルールとスキルへの移動が遅れている

## やらないこと

- フックとサブエージェントは、この段階では作らない。必要が生じてから足す。
- 既存の `CLAUDE.md` を上書きしない。あれば、追記案を示して確認を取る。
