# フック

`CLAUDE.md` に「コミット前に必ずリントを通す」と書いても、通らないことがある。あれは指示文であって、
守るかどうかはその場の判断に委ねられている。文章が長ければ埋もれるし、目の前の作業に集中していれば飛ばされる。

**フック**は、決められた時点で必ず走るシェルコマンドである。エージェントの判断を経由しないので、
実行されるかどうかがモデルの状態に左右されない。例外を許さない要求は、指示ではなくここに書く。

## 設定の形

`.claude/settings.json` の `hooks` に、イベント名、対象の絞り込み、実行するコマンドの三段で書く。

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/format.sh"
          }
        ]
      }
    ]
  }
}
```

`matcher` はツール名に対する絞り込みで、完全一致、`|` や `,` 区切りの複数指定、正規表現が使える。
省略するか `"*"` を書くと、そのイベントのすべてに反応する。`mcp__memory__.*` のように書けば、
特定の MCP サーバのツールだけを対象にできる。

スクリプトのパスは `${CLAUDE_PROJECT_DIR}` を頭に付ける。エージェントがサブディレクトリで
作業していても、同じファイルを指せる。

## 主なイベント

| イベント | 発火する時点 |
|---------|-------------|
| `SessionStart` | セッションの開始時と再開時 |
| `UserPromptSubmit` | 指示が送られ、処理される前 |
| `PreToolUse` | ツールが実行される前（止められる） |
| `PostToolUse` | ツールが成功した後 |
| `PostToolUseFailure` | ツールが失敗した後 |
| `Stop` | エージェントが応答を終えるとき |
| `SubagentStart` / `SubagentStop` | サブエージェントの起動時と終了時 |
| `PreCompact` / `PostCompact` | コンテキストの圧縮の前後 |
| `InstructionsLoaded` | `CLAUDE.md` やルールが読み込まれたとき |
| `SessionEnd` | セッションの終了時 |

`InstructionsLoaded` は、どの指示ファイルがいつ読み込まれたかを記録できる。
パススコープ付きルールが効いていないときの調査に使える。

## 受け取る情報と返し方

フックは標準入力から JSON を受け取る。`PreToolUse` なら、どのツールがどんな引数で呼ばれようとしているかが入っている。

```json
{
  "session_id": "abc123",
  "cwd": "/home/user/my-project",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf /tmp/build",
    "description": "ビルドディレクトリを削除"
  }
}
```

返し方は終了コードで決まる。

- **0**：正常。標準出力に JSON があれば、判断として解釈される
- **2**：ブロッキングエラー。標準エラー出力が理由として扱われ、動作が止まる
- **その他**：非ブロッキングエラー。処理は続く

`PreToolUse` で止めたいときは、終了コード 2 で理由を標準エラーに書くか、
終了コード 0 で次の JSON を標準出力に返す。

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "この操作はフックで禁止されている"
  }
}
```

`permissionDecision` を省略すれば判断せず、通常の権限フローに戻る。

## 実際に置くもの

三つの型がよく効く。

**編集の後に整形と検査を走らせる**。`PostToolUse` で `Edit|Write` を拾い、フォーマッタとリンタをかける。
エージェントが規約を覚えている必要が無くなるので、その分 `CLAUDE.md` から規約の行を削れる。

**終わったことにさせない**。`Stop` でテストを走らせ、落ちていれば終了コード 2 で止める。
「できました」で終わらせず、通るまで直させられる。ただし連続で 8 回止めると、
Claude Code 側が打ち切ってターンを終える。無限には粘れない。

**触らせない場所を守る**。`PreToolUse` でパスを見て、マイグレーションや生成物への書き込みを拒否する。
同じことは[権限ルール](07-permissions.md)の `deny` でもできる。条件がパスだけで決まるなら権限ルール、
中身を見て判断したいならフックにする。

## このリポジトリの実例

[.claude/hooks/check-claude-md-size.sh](../.claude/hooks/check-claude-md-size.sh) は、
`CLAUDE.md` が 200 行を超えたときに警告を返す `PostToolUse` フックである。
[.claude/settings.json](../.claude/settings.json) に登録してあり、
このリポジトリで `CLAUDE.md` を編集すると実際に動く。

教材が「200 行に収める」と書いておきながら守られない、という事態を、
指示ではなく機構で防いでいる。設定の全体は `/hooks` で一覧できる。

## 書かせる

フックはエージェント自身に書かせられる。「ファイルを編集したら eslint を走らせるフックを書いて」
「マイグレーションディレクトリへの書き込みを禁止するフックを書いて」といった依頼で通る。
できたものは `.claude/settings.json` を開いて自分で確認する。自分の環境で毎回走るスクリプトなので、
中身を読まずに採用しないほうがよい。

## 演習

- [フックで規約を強制する](../exercises/06-hook-guardrail/README.md)
