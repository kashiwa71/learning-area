# エージェントコーディング学習リポジトリ

コーディングエージェント（Claude Code）に仕事を任せられるようになるための学習リポジトリ。
エージェントの操作方法そのものより、**リポジトリ側に何を書いておけばエージェントが正しく動くか**に重心を置く。

読む教材は `docs/`、手を動かす課題は `exercises/`、新規プロジェクトにコピーして使う雛形は `templates/` に置いてある。
このリポジトリ自身も `CLAUDE.md` と `.claude/` を持っていて、教材で説明した設定がそのまま動く実例になっている。

## 前提

- Claude Code がインストールされ、`claude` コマンドが動く状態
- git が使える状態
- 対象読者は、これから自分のプロジェクトを立ち上げる開発者

## 学習の順路

上から順に読むと、制約の説明から具体的な設定ファイルへ、最後に立ち上げ手順へ進む。

| # | 教材 | 何が身につくか |
|---|------|---------------|
| 00 | [エージェントコーディングとは何か](docs/00-agent-coding.md) | 補完型の支援との違い、エージェントに任せる単位 |
| 01 | [コンテキストという制約](docs/01-context.md) | 以降のすべての作法が導かれる前提 |
| 02 | [CLAUDE.md の書き方](docs/02-claude-md.md) | 置き場所、載せる内容、削る基準 |
| 03 | [ルールの分割](docs/03-rules.md) | `.claude/rules/` とパススコープ |
| 04 | [スキル](docs/04-skills.md) | 手順を再利用可能な形にする |
| 05 | [サブエージェント](docs/05-subagents.md) | 調査とレビューを別コンテキストに逃がす |
| 06 | [フック](docs/06-hooks.md) | 指示ではなく機構で強制する |
| 07 | [権限と設定](docs/07-permissions.md) | `settings.json` と権限ルールの文法 |
| 08 | [仕事の進め方](docs/08-workflow.md) | 調査、計画、実装、検証のループ |
| 09 | [新規プロジェクトの立ち上げ](docs/09-new-project.md) | 0 から始めるときに何をいつ書くか |
| 10 | [つまずきどころ](docs/10-antipatterns.md) | うまくいかないときの診断 |

02、06、09 がこのリポジトリの中心にあたる。時間がないときはこの三つだけでも効果がある。

## 演習

`exercises/` の各ディレクトリに課題と確認項目が入っている。読んだ直後に対応する演習をやると定着しやすい。

| # | 演習 | 対応する教材 |
|---|------|-------------|
| 01 | [CLAUDE.md を書く](exercises/01-write-claude-md/README.md) | 02 |
| 02 | [CLAUDE.md を刈り込む](exercises/02-prune-claude-md/README.md) | 02 |
| 03 | [最初のスキルを作る](exercises/03-first-skill/README.md) | 04 |
| 04 | [検証ループを閉じる](exercises/04-verification-loop/README.md) | 08 |
| 05 | [サブエージェントにレビューさせる](exercises/05-subagent-review/README.md) | 05 |
| 06 | [フックで規約を強制する](exercises/06-hook-guardrail/README.md) | 06 |
| 07 | [新規プロジェクトを立ち上げる](exercises/07-new-project/README.md) | 09 |

## 雛形

`templates/` の中身は、新しいプロジェクトにそのままコピーして使うことを想定している。
使い方は [templates/README.md](templates/README.md) にある。

## このリポジトリ自体を読む

教材の説明と実物を突き合わせられるように、設定ファイルを一通り置いてある。

```text
CLAUDE.md                            プロジェクト指示の実例（40行）
.claude/
├── settings.json                    権限とフックの設定
├── rules/docs-style.md              paths スコープ付きルール
├── skills/
│   ├── new-project-setup/SKILL.md   新規プロジェクトの初期設定を対話で進める
│   └── claude-md-review/SKILL.md    CLAUDE.md をレビューして削る
├── agents/doc-reviewer.md           読み手視点で教材を点検するサブエージェント
└── hooks/check-claude-md-size.sh    CLAUDE.md の肥大を警告する
```

`claude` を起動して `/context` を実行すると、どのファイルが実際に読み込まれたか確認できる。

## 出典

内容は [Claude Code 公式ドキュメント](https://code.claude.com/docs/) の記述に基づく。
仕様は更新されるため、細部が食い違う場合は公式ドキュメントを正とする。
