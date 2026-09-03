# 演習 06：フックで規約を強制する

対応する教材：[フック](../../docs/06-hooks.md)

## 課題

`CLAUDE.md` に書いても守られない規約を一つ選び、フックに移す。
移した後、`CLAUDE.md` から該当の行を消しても守られることを確認する。

題材が決まらなければ「編集したファイルにフォーマッタをかける」を作る。

## 進め方

1. `.claude/hooks/` を作り、シェルスクリプトを置く。標準入力に JSON が渡るので、
   対象のファイルパスを取り出す。

   ```bash
   #!/usr/bin/env bash
   set -uo pipefail
   input=$(cat)
   file=$(printf '%s' "$input" \
     | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | tail -1)
   [ -n "$file" ] || exit 0
   # ここに、そのファイルに対する処理を書く
   ```

2. 実行権限を付ける。`chmod +x .claude/hooks/my-hook.sh`

3. 端末から手で動かして確かめる。エージェントを起動する前に、ここで壊れていないことを見る。

   ```bash
   echo '{"tool_name":"Edit","tool_input":{"file_path":"src/index.ts"}}' \
     | ./.claude/hooks/my-hook.sh; echo "exit=$?"
   ```

4. `.claude/settings.json` に登録する。

   ```json
   {
     "hooks": {
       "PostToolUse": [
         {
           "matcher": "Edit|Write",
           "hooks": [
             { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/my-hook.sh" }
           ]
         }
       ]
     }
   }
   ```

5. `claude` を起動し、`/hooks` で登録されていることを確認する。

6. 対象のファイルを編集させ、フックが動くことを確認する。

7. `CLAUDE.md` から、同じことを指示していた行を消す。もう一度編集させ、
   それでも守られることを確認する。

## できたと言える条件

- [ ] 手順 3 の手動実行が、意図した終了コードを返す
- [ ] `/hooks` にフックが表示される
- [ ] エージェントにファイルを編集させたとき、フックが実際に動いた
- [ ] `CLAUDE.md` から対応する指示の行を消しても、規約が守られる
- [ ] `CLAUDE.md` の行数が、演習の前より減っている

## 次の一歩

止めるフックを書く。`PreToolUse` で、終了コード 2 と標準エラー出力、あるいは
終了コード 0 と `permissionDecision: "deny"` の JSON で、ツールの実行を拒否できる。

同じことがパスの指定だけで決まるなら、フックより[権限ルール](../../docs/07-permissions.md)の
`deny` のほうが簡単である。中身を見て判断したいときにフックを選ぶ。
