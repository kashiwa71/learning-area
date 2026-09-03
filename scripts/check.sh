#!/usr/bin/env bash
# 教材リポジトリの整合性チェック。
# エージェントが自分の変更を検証できるように、合否を終了コードで返す。
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

fail=0
report() { printf 'NG  %s\n' "$1"; fail=1; }
files() { find . -path ./.git -prune -o -type f -name "$1" -print | sort; }

# 1. CLAUDE.md が肥大していないか（200行を超えると指示の追従率が落ちる）
while IFS= read -r f; do
  [ -n "$f" ] || continue
  lines=$(wc -l < "$f")
  [ "$lines" -le 200 ] || report "$f が ${lines} 行ある（上限 200 行）"
done < <(files 'CLAUDE.md')

# 2. Markdown 内の相対リンク先が実在するか
broken=$(
  while IFS= read -r md; do
    [ -n "$md" ] || continue
    dir=$(dirname "$md")
    awk '/^[[:space:]]*```/ { inblock = !inblock; next } !inblock' "$md" \
      | grep -o ']([^)]*)' | sed 's/^](//; s/)$//' | while IFS= read -r link; do
      link=${link%%#*}
      [ -n "$link" ] || continue
      case "$link" in http://*|https://*|mailto:*|/*) continue ;; esac
      [ -e "$dir/$link" ] || printf '%s のリンク先が無い: %s\n' "$md" "$link"
    done
  done < <(files '*.md')
)
if [ -n "$broken" ]; then
  printf '%s\n' "$broken" | sed 's/^/NG  /'
  fail=1
fi

# 3. スキルに description フロントマターがあるか
while IFS= read -r skill; do
  [ -n "$skill" ] || continue
  head -20 "$skill" | grep -q '^description:' || report "$skill に description が無い"
done < <(files 'SKILL.md')

# 4. シェルスクリプトの構文
while IFS= read -r sh; do
  [ -n "$sh" ] || continue
  bash -n "$sh" 2>/dev/null || report "$sh に構文エラーがある"
done < <(files '*.sh')

# 5. settings.json が妥当な JSON か
while IFS= read -r js; do
  [ -n "$js" ] || continue
  python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$js" 2>/dev/null \
    || report "$js が JSON として読めない"
done < <(files 'settings.json')

[ "$fail" -eq 0 ] && echo "OK  すべてのチェックを通過した"
exit "$fail"
