# Windows 调试模式：通过 Chrome 远程调试接口（CDP，127.0.0.1:9222）操作「抖音分析专用 Chrome」，不需要窗口在前台，也不动鼠标。
# 专用 Chrome 由 AI 执行 `cdp.ps1 launch` 自动打开（单独的一份 Chrome 资料，和用户平时的 Chrome 互不影响），
# 用户只需要第一次在这个窗口里扫码登录抖音。「启动抖音分析Chrome.bat」是备用方案，launch 失败时才让用户双击。
# 只用 Windows 自带的 PowerShell 5.1 / .NET，不需要装任何东西。
#
# 由 AI 助手执行（用户不需要手动运行）：
#   powershell -NoProfile -ExecutionPolicy Bypass -File cdp.ps1 <命令> [参数]
# 命令：
#   launch                    自动打开专用 Chrome（已经开着就什么都不做），等调试接口就绪；首次使用会顺便建桌面快捷方式
#   check                     检查专用 Chrome 是否已启动、调试接口能否连上
#   tabs                      列出所有标签页 id 和网址
#   open <url>                新开后台标签页，输出标签页 id
#   go <id> <url>             让该标签页打开新网址
#   url <id>                  输出该标签页当前网址
#   js <id> <file.js> [KEY=值 ...]  在该标签页执行 JS 文件，输出返回值；KEY=值 把文件里的 __KEY__ 替换成值（和 Mac 的 chrome.sh js 用同一批 js 文件）
#   eval <id> <code>          同上，直接传代码
#   shot <id> <out.png>       只截这个标签页（不需要在前台），用于读图表或核对
#   close <id>                关闭该标签页（只关自己打开的）
#   slow                      触发过抖音安全验证后执行：之后 2 小时内所有间隔翻倍、每小时上限减半
#   pace                      查看最近一小时的访问次数和当前限速状态
#
# 防风控限速（open / go / 滚动 / 点击都会自动等待，不用另外 sleep）：
#   打开页面：douyin.com 间隔随机 8~15 秒，创作者中心 3~6 秒；每打开 10 个页面额外休息 60~90 秒；
#   每小时最多打开 60 个页面；同一页面最多滚动加载 8 次，每次间隔随机 3~6 秒；点击筛选、搜索框 3~6 秒。
#   超过上限时以退出码 3 结束并说明原因，这时要停下来，告诉用户稍后再继续，不要绕过。

param([string]$cmd, [string]$a1, [string]$a2, [Parameter(ValueFromRemainingArguments = $true)][string[]]$rest)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$base = 'http://127.0.0.1:9222'

function Get-Targets { Invoke-RestMethod -Uri "$base/json/list" -TimeoutSec 5 }
function Get-Target([string]$id) {
  $t = Get-Targets | Where-Object { $_.id -eq $id -and $_.type -eq 'page' }
  if (-not $t) { throw "tab not found: $id" }
  return $t
}

# 发一条 CDP 命令并等待对应 id 的回复
function Invoke-Cdp([string]$id, [string]$method, $params) {
  $t = Get-Target $id
  $ws = New-Object System.Net.WebSockets.ClientWebSocket
  $ct = [Threading.CancellationToken]::None
  $ws.ConnectAsync([Uri]$t.webSocketDebuggerUrl, $ct).Wait()
  try {
    $msg = @{ id = 1; method = $method; params = $params } | ConvertTo-Json -Depth 10 -Compress
    $bytes = [Text.Encoding]::UTF8.GetBytes($msg)
    $ws.SendAsync([ArraySegment[byte]]$bytes, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $ct).Wait()
    $buf = New-Object byte[] 1048576
    while ($true) {
      $ms = New-Object System.IO.MemoryStream
      do {
        $r = $ws.ReceiveAsync([ArraySegment[byte]]$buf, $ct).Result
        $ms.Write($buf, 0, $r.Count)
      } while (-not $r.EndOfMessage)
      $text = [Text.Encoding]::UTF8.GetString($ms.ToArray())
      $obj = $text | ConvertFrom-Json
      if ($obj.id -eq 1) { return $obj }
    }
  } finally {
    if ($ws.State -eq 'Open') { $ws.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, '', $ct).Wait() }
    $ws.Dispose()
  }
}

# ---------- 防风控限速 ----------
$PaceLog = Join-Path $env:TEMP 'douyin-skill-pace.log'
$SlowFlag = Join-Path $env:TEMP 'douyin-skill-slow'
function Get-Now { [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() }
function Invoke-Pace([string]$kind, [string]$url) {
  $now = Get-Now; $factor = 1; $rnd = New-Object System.Random
  if ((Test-Path $SlowFlag) -and ([long](Get-Content $SlowFlag -TotalCount 1) -gt $now)) { $factor = 2 }
  $lines = @()
  if (Test-Path $PaceLog) { $lines = @(Get-Content $PaceLog | Where-Object { $_ -and ([long]($_.Split(' ')[0]) -ge ($now - 3600)) }) }
  Set-Content -Path $PaceLog -Value $lines
  $gap = 0
  switch ($kind) {
    'nav' {
      $cnt = @($lines | Where-Object { $_.Split(' ')[1] -eq 'nav' }).Count
      if ($cnt -ge [int](60 / $factor)) { [Console]::Error.WriteLine("已达到每小时访问上限（$cnt 个页面），为避免触发抖音风控，请停下来，告诉用户过一段时间再继续"); exit 3 }
      if ($url -like '*creator.douyin.com*') { $gap = (3 + $rnd.Next(4)) * $factor } else { $gap = (8 + $rnd.Next(8)) * $factor }
      if ($cnt -gt 0 -and ($cnt % 10) -eq 0) { $gap += (60 + $rnd.Next(31)) * $factor; [Console]::Error.WriteLine("已连续打开 $cnt 个页面，休息 $gap 秒防风控…") }
    }
    'scroll' {
      $n = 0
      foreach ($l in $lines) { $k = $l.Split(' ')[1]; if ($k -eq 'nav') { $n = 0 } elseif ($k -eq 'scroll') { $n++ } }
      if ($n -ge 8) { [Console]::Error.WriteLine("这个页面已经滚动加载 $n 次，够用了；再多容易触发风控"); exit 3 }
      $gap = (3 + $rnd.Next(4)) * $factor
    }
    'light' { $gap = (3 + $rnd.Next(4)) * $factor }
  }
  if ($lines.Count -gt 0) {
    $elapsed = $now - [long]($lines[-1].Split(' ')[0])
    if ($elapsed -lt $gap) { Start-Sleep -Seconds ($gap - $elapsed) }
  }
  Add-Content -Path $PaceLog -Value ("{0} {1}" -f (Get-Now), $kind)
}

function Invoke-Js([string]$id, [string]$code) {
  $res = Invoke-Cdp $id 'Runtime.evaluate' @{ expression = $code; returnByValue = $true; awaitPromise = $true }
  if ($res.error) { throw $res.error.message }
  if ($res.result.exceptionDetails) { throw ($res.result.exceptionDetails.exception.description) }
  return $res.result.result.value
}

function Find-Chrome {
  $cands = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
  )
  foreach ($c in $cands) { if ($c -and (Test-Path $c)) { return $c } }
  $reg = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($reg -and $reg.'(default)' -and (Test-Path $reg.'(default)')) { return $reg.'(default)' }
  return $null
}

function Test-Debug { try { $null = Invoke-RestMethod -Uri "$base/json/version" -TimeoutSec 2; return $true } catch { return $false } }

switch ($cmd) {
  'launch' {
    if (Test-Debug) { 'ok already running'; break }
    $chrome = Find-Chrome
    if (-not $chrome) { '没有找到 Chrome：请用户先安装 Google Chrome'; exit 1 }
    $profileDir = Join-Path $env:LOCALAPPDATA 'DouyinAnalysisChrome'
    $chromeArgs = @('--remote-debugging-port=9222', '--remote-debugging-address=127.0.0.1', "--user-data-dir=`"$profileDir`"", '--no-first-run', 'https://creator.douyin.com/')
    Start-Process -FilePath $chrome -ArgumentList $chromeArgs | Out-Null
    # 顺便在桌面建快捷方式「抖音分析专用Chrome」，以后用户也可以自己双击打开
    try {
      $lnk = Join-Path ([Environment]::GetFolderPath('Desktop')) '抖音分析专用Chrome.lnk'
      if (-not (Test-Path $lnk)) {
        $sc = (New-Object -ComObject WScript.Shell).CreateShortcut($lnk)
        $sc.TargetPath = $chrome; $sc.Arguments = ($chromeArgs -join ' '); $sc.IconLocation = "$chrome,0"; $sc.Save()
      }
    } catch {}
    for ($i = 0; $i -lt 20; $i++) { Start-Sleep -Seconds 1; if (Test-Debug) { 'ok launched'; exit 0 } }
    '专用 Chrome 已启动，但调试接口 20 秒内没有就绪：请检查是否被安全软件拦截，或让用户双击 scripts\windows\启动抖音分析Chrome.bat'; exit 1
  }
  'check' {
    try { $v = Invoke-RestMethod -Uri "$base/json/version" -TimeoutSec 3; "ok $($v.Browser)" }
    catch { "专用 Chrome 没有启动或调试接口连不上：先执行 cdp.ps1 launch 自动打开"; exit 1 }
  }
  'tabs' { Get-Targets | Where-Object { $_.type -eq 'page' } | ForEach-Object { "$($_.id)  $($_.url)" } }
  'open' {
    Invoke-Pace 'nav' $a1
    $u = [Uri]::EscapeUriString($a1)
    try { $t = Invoke-RestMethod -Method Put -Uri "$base/json/new?$u" } catch { $t = Invoke-RestMethod -Uri "$base/json/new?$u" }
    $t.id
  }
  'go'    { Invoke-Pace 'nav' $a2; $null = Invoke-Cdp $a1 'Page.navigate' @{ url = $a2 }; 'ok' }
  'url'   { (Get-Target $a1).url }
  'js'    {
    if ($a2 -like '*search_results.js' -and ($rest -contains 'SCROLL=1')) { Invoke-Pace 'scroll' '' }
    elseif ($a2 -like '*click_text.js' -or $a2 -like '*search_box.js') { Invoke-Pace 'light' '' }
    $code = [IO.File]::ReadAllText((Resolve-Path $a2), [Text.Encoding]::UTF8)
    foreach ($kv in $rest) { $k, $v = $kv -split '=', 2; $code = $code.Replace("__${k}__", $v) }
    Invoke-Js $a1 $code
  }
  'eval'  { Invoke-Js $a1 $a2 }
  'shot' {
    $res = Invoke-Cdp $a1 'Page.captureScreenshot' @{ format = 'png' }
    $out = [IO.Path]::GetFullPath($a2)
    [IO.File]::WriteAllBytes($out, [Convert]::FromBase64String($res.result.data))
    $out
  }
  'slow'  { Set-Content -Path $SlowFlag -Value ((Get-Now) + 7200); '已进入慢速模式：之后 2 小时内间隔翻倍、每小时上限减半' }
  'pace'  {
    $now = Get-Now; $lines = @(); if (Test-Path $PaceLog) { $lines = @(Get-Content $PaceLog | Where-Object { $_ -and ([long]($_.Split(' ')[0]) -ge ($now - 3600)) }) }
    "最近一小时：打开页面 $(@($lines | Where-Object { $_.Split(' ')[1] -eq 'nav' }).Count) 次，滚动 $(@($lines | Where-Object { $_.Split(' ')[1] -eq 'scroll' }).Count) 次"
    if ((Test-Path $SlowFlag) -and ([long](Get-Content $SlowFlag -TotalCount 1) -gt $now)) { "慢速模式：还剩 $([int](([long](Get-Content $SlowFlag -TotalCount 1) - $now) / 60)) 分钟" } else { '正常速度' }
  }
  'close' { $null = Invoke-RestMethod -Uri "$base/json/close/$a1"; 'closed' }
  default { Get-Content $PSCommandPath -Encoding UTF8 -TotalCount 30 | Select-Object -Skip 1; exit 1 }
}
