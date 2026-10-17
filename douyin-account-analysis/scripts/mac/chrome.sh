#!/bin/bash
# Mac 调试模式：通过 Apple 事件在指定标签页里执行 JavaScript，不需要 Chrome 在最前面，也不动鼠标。
# 前提：Chrome 菜单「查看 → 开发者 → 允许 Apple 事件中的 JavaScript」已勾选。
#
# 用法:
#   chrome.sh check                    检查 Chrome 是否在运行、JS 开关是否打开
#   chrome.sh open <url>               在专用的最小化窗口「抖音分析（AI 自动操作中）」里打开网址，输出标签页 id；不碰用户的窗口
#                                      这个窗口只有一个标签页，再次 open 会复用它（之前的 id 仍然有效）
#   chrome.sh js <tab-id> <file.js> [KEY=值 ...]
#                                      在该标签页执行 JS 文件，输出返回值；KEY=值 会把文件里的 __KEY__ 替换成值
#   chrome.sh eval <tab-id> '<code>'   同上，直接传代码
#   chrome.sh go <tab-id> <url>        让该标签页打开新网址（不切到前台）
#   chrome.sh url <tab-id>             输出该标签页当前网址
#   chrome.sh close <tab-id>           关闭该标签页（只关自己打开的）；关掉专用窗口里唯一的标签页，窗口也就关了
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

# 有些页面动作（例如提交搜索）会让 Chrome 自己跳到前台；这里记下原来的前台应用，事后切回去
front_app() { osascript -e 'tell application "System Events" to return name of first process whose frontmost is true'; }
give_back_focus() {
  [ "$1" = "Google Chrome" ] && return
  for i in 1 2 3; do
    sleep 1
    [ "$(front_app)" = "Google Chrome" ] && osascript -e "tell application \"System Events\" to set frontmost of process \"$1\" to true" >/dev/null
  done
}

case $cmd in
  check)
    pgrep -xq "Google Chrome" || { echo "Chrome 没有在运行"; exit 1; }
    r=$(osascript -e 'tell application "Google Chrome" to execute active tab of front window javascript "1+1"' 2>&1) || true
    if [ "$r" = "2" ]; then echo ok; else echo "JS 开关没打开或被拒绝: $r"; exit 1; fi ;;
  open)
    # 所有自动操作都放在一个单独的、最小化的窗口「抖音分析（AI 自动操作中）」里，不碰用户自己的窗口和标签页。
    # 这个窗口只用一个标签页：第一次 open 时建窗口并最小化，之后的 open 只是让这个标签页换网址（往最小化窗口里加标签页会把它弹出来）。
    # 建窗口时 Chrome 会被系统切到前台，所以结束时把焦点还给原来的应用。最小化时页面照样加载，只是滚动加载更慢，要多滚几次。
    osascript - "$1" "$(python3 -c 'import json,sys;print(json.dumps(sys.argv[1]))' "$1")" <<'EOF'
on run argv
  set wname to "抖音分析（AI 自动操作中）"
  tell application "System Events" to set prevApp to name of first process whose frontmost is true
  tell application "Google Chrome"
    set w to missing value
    set isNew to false
    repeat with x in windows
      try
        if given name of x is wname then set w to x
      end try
    end repeat
    if w is missing value then
      set isNew to true
      set w to make new window
      set given name of w to wname
      set minimized of w to true
    end if
    set t to active tab of w
    if isNew then
      set URL of t to (item 1 of argv)
    else
      execute t javascript "location.href=" & (item 2 of argv) & ";'ok'"
    end if
    if not (minimized of w) then set minimized of w to true
    set tid to (id of t) as text
  end tell
  if prevApp is not "Google Chrome" then
    tell application "System Events" to set frontmost of process prevApp to true
  end if
  return tid
end run
EOF
    ;;
  js)
    tid=$1; src="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"; shift 2
    prev=$(front_app)
    if [ $# -eq 0 ]; then run_js_file "$tid" "$src"; else
      code=$(cat "$src"); for kv in "$@"; do code=${code//__${kv%%=*}__/${kv#*=}}; done
      f=$(mktemp -t cjs); printf '%s' "$code" > "$f"; run_js_file "$tid" "$f"; rm -f "$f"
    fi
    case "$src" in *search_box.js) give_back_focus "$prev" ;; esac ;;
  eval) f=$(mktemp -t cjs); printf '%s' "$2" > "$f"; run_js_file "$1" "$f"; rm -f "$f" ;;
  go)
    # 用页面里的 JS 跳转，不用 AppleScript 的 set URL：后者会把最小化窗口弹出来、把 Chrome 切到前台
    f=$(mktemp -t cjs); python3 -c 'import json,sys;print("location.href="+json.dumps(sys.argv[1])+";\"ok\"")' "$2" > "$f"
    run_js_file "$1" "$f"; rm -f "$f" ;;
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
