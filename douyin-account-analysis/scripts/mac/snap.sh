#!/bin/bash
# 用法: snap.sh <输出目录> <名字> [click x y] [scroll n] [paste 文字] [key enter|esc|cmd+l|cmd+0|cmd+-] [wait 秒] ...
# paste 会先备份剪贴板、结束时还原；中文输入都用 paste
# 先激活 Chrome 并确认它在最前面，再依次执行点击/滚动，最后截图并生成缩小图 <名字>_s.png
# 设置环境变量 EXPECT=<网址片段>（如 EXPECT=douyin.com）时，每次点击/滚动前都核对当前标签页网址，不符就中止
DIR="$(cd "$(dirname "$0")" && pwd)"
OUT=$1; name=$2; shift 2
mkdir -p "$OUT"
fp=$(osascript -e 'tell application "Google Chrome" to activate' -e 'delay 0.8' -e 'tell application "System Events" to return name of first process whose frontmost is true')
if [ "$fp" != "Google Chrome" ]; then echo "front=$fp, abort"; exit 1; fi
check() {
  fp=$(osascript -e 'tell application "System Events" to return name of first process whose frontmost is true')
  [ "$fp" = "Google Chrome" ] || { echo "front=$fp, abort"; exit 1; }
  if [ -n "$EXPECT" ]; then
    u=$(osascript -e 'tell application "Google Chrome" to get URL of active tab of front window')
    case "$u" in *"$EXPECT"*) ;; *) echo "url=$u, expect=$EXPECT, abort"; exit 1;; esac
  fi
}
CLIP=$(mktemp -t clip); pbpaste > "$CLIP"; trap 'pbcopy < "$CLIP"; rm -f "$CLIP"' EXIT
check
while [ $# -gt 0 ]; do
  check
  case $1 in
    click) "$DIR/click" "$2" "$3"; shift 3; osascript -e 'delay 2.5';;
    scroll) "$DIR/scroll" 1100 800 "$2"; shift 2; osascript -e 'delay 1.5';;
    paste) printf '%s' "$2" | pbcopy; osascript -e 'tell application "System Events" to keystroke "v" using command down' -e 'delay 0.5'; shift 2;;
    key) case $2 in
           enter) osascript -e 'tell application "System Events" to key code 36';;
           esc) osascript -e 'tell application "System Events" to key code 53';;
           cmd+*) osascript -e "tell application \"System Events\" to keystroke \"${2#cmd+}\" using command down";;
           *) echo "unknown key: $2"; exit 1;;
         esac; shift 2; osascript -e 'delay 1';;
    wait) osascript -e "delay $2"; shift 2;;
    *) echo "unknown step: $1"; exit 1;;
  esac
done
screencapture -x "$OUT/$name.png" && sips -Z 2400 "$OUT/$name.png" --out "$OUT/${name}_s.png" >/dev/null && echo "$OUT/${name}_s.png"
