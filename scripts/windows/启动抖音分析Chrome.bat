@echo off
chcp 65001 >nul
rem 双击运行：打开「抖音分析专用 Chrome」（开启远程调试，只监听本机 127.0.0.1:9222）。
rem 用的是单独的一份 Chrome 资料（%LOCALAPPDATA%\DouyinAnalysisChrome），和你平时用的 Chrome 互不影响。
rem 第一次运行会在桌面建一个快捷方式「抖音分析专用Chrome」，以后双击那个快捷方式即可。

set "PROFILE=%LOCALAPPDATA%\DouyinAnalysisChrome"
set "CHROME="
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set "CHROME=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not defined CHROME if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" set "CHROME=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not defined CHROME if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" set "CHROME=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
if not defined CHROME (
  echo 没有找到 Chrome，请先安装 Google Chrome。
  pause
  exit /b 1
)

set "ARGS=--remote-debugging-port=9222 --remote-debugging-address=127.0.0.1 --user-data-dir="%PROFILE%" --no-first-run"

if not exist "%USERPROFILE%\Desktop\抖音分析专用Chrome.lnk" (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut([Environment]::GetFolderPath('Desktop')+'\抖音分析专用Chrome.lnk'); $s.TargetPath='%CHROME%'; $s.Arguments='--remote-debugging-port=9222 --remote-debugging-address=127.0.0.1 --user-data-dir=\"%PROFILE%\" --no-first-run https://creator.douyin.com/'; $s.IconLocation='%CHROME%,0'; $s.Save()"
  echo 已在桌面创建快捷方式「抖音分析专用Chrome」。
)

start "" "%CHROME%" %ARGS% https://creator.douyin.com/
echo 已打开抖音分析专用 Chrome。第一次使用请在这个窗口里扫码登录抖音创作者中心，然后回到 AI 助手说「好了」。
echo 用完关掉这个 Chrome 窗口即可，调试接口会随之关闭。
timeout /t 8 >nul
