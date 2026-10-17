import Foundation
import CoreGraphics
// usage: scroll x y lines   (negative lines = scroll down)
let a = CommandLine.arguments
let x = Double(a[1])!, y = Double(a[2])!, n = Int32(a[3])!
let p = CGPoint(x: x, y: y)
CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: p, mouseButton: .left)?.post(tap: .cghidEventTap)
usleep(200000)
let step: Int32 = n < 0 ? -5 : 5
var left = abs(n)
while left > 0 {
  let s = min(5, left)
  CGEvent(scrollWheelEvent2Source: nil, units: .line, wheelCount: 1, wheel1: step < 0 ? -s : s, wheel2: 0, wheel3: 0)?.post(tap: .cghidEventTap)
  usleep(30000)
  left -= s
}
