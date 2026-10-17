# Windows 调试模式：通过 Chrome 远程调试接口（CDP，127.0.0.1:9222）操作「抖音分析专用 Chrome」，不需要窗口在前台，也不动鼠标。
# 前提：用户已双击「启动抖音分析Chrome.bat」打开了专用 Chrome，并在里面登录过抖音。
# 只用 Windows 自带的 PowerShell 5.1 / .NET，不需要装任何东西。
#
# 由 AI 助手执行（用户不需要手动运行）：
#   powershell -NoProfile -ExecutionPolicy Bypass -File cdp.ps1 <命令> [参数]
# 命令：
#   check                     检查专用 Chrome 是否已启动、调试接口能否连上
#   tabs                      列出所有标签页 id 和网址
#   open <url>                新开后台标签页，输出标签页 id
#   go <id> <url>             让该标签页打开新网址
#   url <id>                  输出该标签页当前网址
#   js <id> <file.js> [KEY=值 ...]  在该标签页执行 JS 文件，输出返回值；KEY=值 把文件里的 __KEY__ 替换成值（和 Mac 的 chrome.sh js 用同一批 js 文件）
#   eval <id> <code>          同上，直接传代码
#   shot <id> <out.png>       只截这个标签页（不需要在前台），用于读图表或核对
#   close <id>                关闭该标签页（只关自己打开的）

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

function Invoke-Js([string]$id, [string]$code) {
  $res = Invoke-Cdp $id 'Runtime.evaluate' @{ expression = $code; returnByValue = $true; awaitPromise = $true }
  if ($res.error) { throw $res.error.message }
  if ($res.result.exceptionDetails) { throw ($res.result.exceptionDetails.exception.description) }
  return $res.result.result.value
}

switch ($cmd) {
  'check' {
    try { $v = Invoke-RestMethod -Uri "$base/json/version" -TimeoutSec 3; "ok $($v.Browser)" }
    catch { "专用 Chrome 没有启动或调试接口连不上：请让用户双击「启动抖音分析Chrome.bat」"; exit 1 }
  }
  'tabs' { Get-Targets | Where-Object { $_.type -eq 'page' } | ForEach-Object { "$($_.id)  $($_.url)" } }
  'open' {
    $u = [Uri]::EscapeUriString($a1)
    try { $t = Invoke-RestMethod -Method Put -Uri "$base/json/new?$u" } catch { $t = Invoke-RestMethod -Uri "$base/json/new?$u" }
    $t.id
  }
  'go'    { $null = Invoke-Cdp $a1 'Page.navigate' @{ url = $a2 }; 'ok' }
  'url'   { (Get-Target $a1).url }
  'js'    {
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
  'close' { $null = Invoke-RestMethod -Uri "$base/json/close/$a1"; 'closed' }
  default { Get-Content $PSCommandPath -Encoding UTF8 -TotalCount 18 | Select-Object -Skip 1; exit 1 }
}
