# Windows 截图模式：截全屏 + 模拟鼠标键盘操作前台的 Chrome（等同 Mac 的 snap.sh + click + scroll）。
# 只用 Windows 自带的 PowerShell 5.1 / .NET，不需要装任何东西。
# 坐标一律是「物理像素」：脚本开头已声明 DPI 感知，截图里的像素坐标就是点击坐标（再按缩小比例换算）。
#
# 由 AI 助手执行（用户不需要手动运行）：
#   powershell -NoProfile -ExecutionPolicy Bypass -File screen.ps1 <输出目录> <名字> [步骤...]
# 步骤（按顺序执行，每一步前都会检查 Chrome 在前台；设置环境变量 EXPECT=<网址片段> 时还会核对窗口标题）：
#   click X Y          左键单击（物理像素）
#   scroll N           在屏幕中部滚动 N 格，负数往下
#   key KEYS           发送按键，SendKeys 语法：^l = Ctrl+L，^0 = Ctrl+0，^{-} = Ctrl+减号，{ENTER}，{ESC}
#   paste TEXT         通过剪贴板粘贴文字（中文用这个；会先备份剪贴板，结束时还原）
#   url URL            地址栏打开网址（Ctrl+L → 粘贴 → 回车）
#   wait SEC           等待秒数
# 最后截全屏，保存 <输出目录>\<名字>.png 和缩小到宽 2000 的 <名字>_s.png，并输出两者路径和原图尺寸。
# 只截图不操作：screen.ps1 <输出目录> <名字>

param([Parameter(ValueFromRemainingArguments = $true)][string[]]$argv)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
Add-Type @'
using System; using System.Runtime.InteropServices; using System.Text;
public static class W {
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr h);
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint f, int dx, int dy, int data, UIntPtr extra);
  [DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte scan, uint f, UIntPtr extra);
}
'@
[void][W]::SetProcessDPIAware()

if ($argv.Count -lt 2) { Get-Content $PSCommandPath -Encoding UTF8 -TotalCount 19 | Select-Object -Skip 1; exit 1 }
$outDir = $argv[0]; $name = $argv[1]
$steps = if ($argv.Count -gt 2) { $argv[2..($argv.Count - 1)] } else { @() }
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function Get-FrontInfo {
  $h = [W]::GetForegroundWindow(); $pid0 = 0
  [void][W]::GetWindowThreadProcessId($h, [ref]$pid0)
  $sb = New-Object Text.StringBuilder 512; [void][W]::GetWindowText($h, $sb, 512)
  $p = Get-Process -Id $pid0 -ErrorAction SilentlyContinue
  return @{ proc = $(if ($p) { $p.ProcessName } else { '' }); title = $sb.ToString() }
}

function Activate-Chrome {
  $c = Get-Process chrome -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
  if (-not $c) { Write-Output 'Chrome 没有打开窗口, abort'; exit 1 }
  $h = $c.MainWindowHandle
  if ([W]::IsIconic($h)) { [void][W]::ShowWindow($h, 9) }
  # Windows 限制后台程序抢前台：先按一下 Alt 再切换，是常用的绕法
  [W]::keybd_event(0x12, 0, 0, [UIntPtr]::Zero); [W]::keybd_event(0x12, 0, 2, [UIntPtr]::Zero)
  [void][W]::SetForegroundWindow($h)
  Start-Sleep -Milliseconds 700
}

function Check-Front {
  $f = Get-FrontInfo
  if ($f.proc -ne 'chrome') { Write-Output "front=$($f.proc), abort"; Restore-Clip; exit 1 }
  # Windows 拿不到当前标签页网址，用窗口标题（= 当前标签页标题）核对
  if ($env:EXPECT -and ($f.title -notlike "*$($env:EXPECT)*")) { Write-Output "title=$($f.title), expect=$($env:EXPECT), abort"; Restore-Clip; exit 1 }
}

$script:clipSaved = $false; $script:clipBackup = $null
function Save-Clip { if (-not $script:clipSaved) { try { $script:clipBackup = Get-Clipboard -Raw } catch {}; $script:clipSaved = $true } }
function Restore-Clip { if ($script:clipSaved) { if ($null -ne $script:clipBackup) { Set-Clipboard -Value $script:clipBackup } }; $script:clipSaved = $false }
function Paste([string]$t) { Save-Clip; Set-Clipboard -Value $t; [System.Windows.Forms.SendKeys]::SendWait('^v'); Start-Sleep -Milliseconds 300 }

Activate-Chrome
Check-Front
$i = 0
while ($i -lt $steps.Count) {
  Check-Front
  switch ($steps[$i]) {
    'click' {
      $x = [int]$steps[$i + 1]; $y = [int]$steps[$i + 2]; $i += 3
      [void][W]::SetCursorPos($x, $y); Start-Sleep -Milliseconds 80
      [W]::mouse_event(0x02, 0, 0, 0, [UIntPtr]::Zero); Start-Sleep -Milliseconds 80
      [W]::mouse_event(0x04, 0, 0, 0, [UIntPtr]::Zero); Start-Sleep -Milliseconds 2500
    }
    'scroll' {
      $n = [int]$steps[$i + 1]; $i += 2
      $b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
      [void][W]::SetCursorPos([int]($b.Width * 0.6), [int]($b.Height * 0.6)); Start-Sleep -Milliseconds 100
      $dir = [Math]::Sign($n)
      for ($k = 0; $k -lt [Math]::Abs($n); $k++) { [W]::mouse_event(0x0800, 0, 0, 120 * $dir, [UIntPtr]::Zero); Start-Sleep -Milliseconds 40 }
      Start-Sleep -Milliseconds 1500
    }
    'key'   { [System.Windows.Forms.SendKeys]::SendWait($steps[$i + 1]); $i += 2; Start-Sleep -Milliseconds 500 }
    'paste' { Paste $steps[$i + 1]; $i += 2 }
    'url'   {
      [System.Windows.Forms.SendKeys]::SendWait('^l'); Start-Sleep -Milliseconds 300
      Paste $steps[$i + 1]; [System.Windows.Forms.SendKeys]::SendWait('{ENTER}'); $i += 2; Start-Sleep -Seconds 6
    }
    'wait'  { Start-Sleep -Seconds ([double]$steps[$i + 1]); $i += 2 }
    default { Write-Output "unknown step: $($steps[$i])"; Restore-Clip; exit 1 }
  }
}
Restore-Clip

$b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
$g = [System.Drawing.Graphics]::FromImage($bmp); $g.CopyFromScreen($b.Location, [System.Drawing.Point]::Empty, $b.Size); $g.Dispose()
$full = [IO.Path]::GetFullPath((Join-Path $outDir "$name.png")); $bmp.Save($full, [System.Drawing.Imaging.ImageFormat]::Png)
$w = [Math]::Min(2000, $b.Width); $h = [int]($b.Height * $w / $b.Width)
$small = New-Object System.Drawing.Bitmap $w, $h
$g = [System.Drawing.Graphics]::FromImage($small); $g.InterpolationMode = 'HighQualityBicubic'; $g.DrawImage($bmp, 0, 0, $w, $h); $g.Dispose()
$sPath = [IO.Path]::GetFullPath((Join-Path $outDir "${name}_s.png")); $small.Save($sPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose(); $small.Dispose()
Write-Output "$sPath"
Write-Output "full=$($b.Width)x$($b.Height) small=${w}x${h} 点击坐标 = 缩小图坐标 x $([Math]::Round($b.Width / $w, 4))"
