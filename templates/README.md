# 雛形

新しいプロジェクトにコピーして使うファイル。角括弧の箇所を自分のプロジェクトの内容に置き換える。

| ファイル | コピー先 | 何をするもの |
|---------|---------|-------------|
| [CLAUDE.md](CLAUDE.md) | プロジェクト直下 | 毎セッション読み込まれる指示 |
| [settings.json](settings.json) | `.claude/settings.json` | 権限の設定 |
| [SPEC.md](SPEC.md) | 任意の場所 | 実装前に固める仕様 |
| [skills/example-skill/SKILL.md](skills/example-skill/SKILL.md) | `.claude/skills/<名前>/SKILL.md` | 手順を再利用する単位 |
| [agents/code-reviewer.md](agents/code-reviewer.md) | `.claude/agents/code-reviewer.md` | 読み取り専用のレビュアー |

## コピーの順

全部をいきなり置かない。[新規プロジェクトの立ち上げ](../docs/09-new-project.md)で説明した順に、
必要になったものから足す。

```bash
# 1. 権限（テストコマンドを毎回承認しなくて済むようにする）
mkdir -p .claude && cp path/to/templates/settings.json .claude/settings.json

# 2. 指示（コマンドと、既に決めている方針だけを書く）
cp path/to/templates/CLAUDE.md ./CLAUDE.md

# 3. 以降は、必要が生じた時点で
```

## .gitignore に足すもの

雛形をコピーしたら、次の二行が `.gitignore` に入っているか確認する。
入っていないと、自分のローカル設定をチームに配ってしまう。

```gitignore
CLAUDE.local.md
.claude/settings.local.json
```

`CLAUDE.md` と `.claude/settings.json` は git に入れる。チームで共有するものなので、
コードと同じようにレビューして育てる。
