#!/bin/bash
# Mac 调试模式：通过 Apple 事件在指定标签页里执行 JavaScript，不需要 Chrome 在最前面，也不动鼠标。
# 前提：Chrome 菜单「查看 → 开发者 → 允许 Apple 事件中的 JavaScript」已勾选。
#
# 用法:
#   chrome.sh check                    检查 Chrome 是否在运行、JS 开关是否打开
#   chrome.sh open <url>               在前台窗口末尾新开标签页，随后切回用户原来的标签页；输出新标签页 id
#   chrome.sh js <tab-id> <file.js> [KEY=值 ...]
#                                      在该标签页执行 JS 文件，输出返回值；KEY=值 会把文件里的 __KEY__ 替换成值
#   chrome.sh eval <tab-id> '<code>'   同上，直接传代码
#   chrome.sh go <tab-id> <url>        让该标签页打开新网址（不切到前台）
#   chrome.sh url <tab-id>             输出该标签页当前网址
#   chrome.sh close <tab-id>           关闭该标签页（只关自己打开的）
#   chrome.sh show <tab-id>            把该标签页切到前台并激活 Chrome（截图兜底时用）
#   chrome.sh tabs                     列出所有标签页 id 和网址
set -e
cmd=$1; shift || true

# 按 id 找标签页并执行一段 AppleScript；$1=tab id，$2=对 t 做的事
with_tab() {
  osascript - "$1" <<EOF
on run argv
  set tid to (item 1 of argv)
  tell application "Google Chrome"
    repeat with w in windows
      repeat with t in tabs of w
        if ((id of t) as text) is tid then
          $2
        end if
      end repeat
    end repeat
  end tell
  error "tab not found: " & tid
end run
EOF
}

run_js_file() {
  osascript - "$1" "$2" <<'EOF'
on run argv
  set tid to (item 1 of argv)
  set js to read POSIX file (item 2 of argv) as «class utf8»
  tell application "Google Chrome"
    repeat with w in windows
      repeat with t in tabs of w
        if ((id of t) as text) is tid then return execute t javascript js
      end repeat
    end repeat
  end tell
  error "tab not found: " & tid
end run
EOF
}

case $cmd in
  check)
    pgrep -xq "Google Chrome" || { echo "Chrome 没有在运行"; exit 1; }
    r=$(osascript -e 'tell application "Google Chrome" to execute active tab of front window javascript "1+1"' 2>&1) || true
    if [ "$r" = "2" ]; then echo ok; else echo "JS 开关没打开或被拒绝: $r"; exit 1; fi ;;
  open)
    osascript - "$1" <<'EOF'
on run argv
  tell application "Google Chrome"
    set w to front window
    set oldIdx to active tab index of w
    set t to make new tab at end of tabs of w with properties {URL:(item 1 of argv)}
    set tid to id of t
    set active tab index of w to oldIdx
    return tid
  end tell
end run
EOF
    ;;
  js)
    tid=$1; src="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"; shift 2
    if [ $# -eq 0 ]; then run_js_file "$tid" "$src"; else
      code=$(cat "$src"); for kv in "$@"; do code=${code//__${kv%%=*}__/${kv#*=}}; done
      f=$(mktemp -t cjs); printf '%s' "$code" > "$f"; run_js_file "$tid" "$f"; rm -f "$f"
    fi ;;
  eval) f=$(mktemp -t cjs); printf '%s' "$2" > "$f"; run_js_file "$1" "$f"; rm -f "$f" ;;
  go)   osascript - "$1" "$2" <<'EOF'
on run argv
  set tid to (item 1 of argv)
  tell application "Google Chrome"
    repeat with w in windows
      repeat with t in tabs of w
        if ((id of t) as text) is tid then
          set URL of t to (item 2 of argv)
          return "ok"
        end if
      end repeat
    end repeat
  end tell
  error "tab not found: " & tid
end run
EOF
    ;;
  url)  with_tab "$1" 'return URL of t' ;;
  close) with_tab "$1" 'close t
          return "closed"' ;;
  show) osascript - "$1" <<'EOF'
on run argv
  set tid to (item 1 of argv)
  tell application "Google Chrome"
    repeat with w in windows
      set i to 0
      repeat with t in tabs of w
        set i to i + 1
        if ((id of t) as text) is tid then
          set index of w to 1
          set active tab index of w to i
          activate
          return "shown"
        end if
      end repeat
    end repeat
  end tell
  error "tab not found: " & tid
end run
EOF
    ;;
  tabs)
    osascript -e 'tell application "Google Chrome"' -e 'set out to ""' -e 'repeat with w in windows' -e 'repeat with t in tabs of w' -e 'set out to out & (id of t) & "  " & (URL of t) & linefeed' -e 'end repeat' -e 'end repeat' -e 'return out' -e 'end tell' ;;
  *) sed -n '2,15p' "$0"; exit 1 ;;
esac
