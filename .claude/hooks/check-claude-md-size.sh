#!/usr/bin/env bash
# PostToolUse フック。CLAUDE.md が 200 行を超えたときに、エージェントへ警告を返す。
#
# 標準入力に、どのツールがどのファイルを編集したかの JSON が渡される。
# 終了コード 2 で標準エラー出力がエージェントに渡り、直す機会が生まれる。
set -uo pipefail

LIMIT=200

input=$(cat)
file=$(printf '%s' "$input" \
  | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
  | tail -1)

# 対象外なら何もしない
[ -n "$file" ] || exit 0
[ "$(basename "$file")" = "CLAUDE.md" ] || exit 0
[ -f "$file" ] || exit 0

lines=$(wc -l < "$file")
if [ "$lines" -gt "$LIMIT" ]; then
  cat >&2 <<MSG
$file が ${lines} 行になった（上限 ${LIMIT} 行）。
毎セッション読み込まれるファイルなので、この長さだと個々の指示の追従率が落ちる。
次のどれかで減らすこと。

- 手順として書かれた段落を .claude/skills/ のスキルに移す
- 特定のファイルにだけ効く規約を .claude/rules/ にパススコープ付きで移す
- 機械で判定できる規約をフックに移し、本文からは消す
- エージェントがコードを読めば分かる記述を消す
MSG
  exit 2
fi

exit 0
