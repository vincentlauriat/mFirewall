import CoreGraphics
import ImageIO
import Foundation
import UniformTypeIdentifiers

let size: CGFloat = 1024
let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(data: nil, width: Int(size), height: Int(size), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    fatalError("no context")
}

func rgba(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    return CGColor(red: r/255, green: g/255, blue: b/255, alpha: a)
}

let rect = CGRect(x: 0, y: 0, width: size, height: size)
let cornerRadius = rect.width * 0.2237

func squirclePath(in rect: CGRect, cornerRadius r: CGFloat) -> CGPath {
    return CGPath(roundedRect: rect, cornerWidth: r, cornerHeight: r, transform: nil)
}

ctx.saveGState()
ctx.addPath(squirclePath(in: rect, cornerRadius: cornerRadius))
ctx.clip()

// Background gradient: deep blue-gray, steel/night tone
let bgColors = [rgba(24, 33, 43), rgba(44, 58, 72)] as CFArray
let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0, 1])!
ctx.drawLinearGradient(bgGradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: size, y: 0), options: [])

// Warm flame glow, broad and soft, centered above the wall
ctx.saveGState()
let glowCenter = CGPoint(x: size*0.5, y: size*0.66)
let glowColors = [rgba(255, 170, 60, 0.9), rgba(255, 110, 40, 0.45), rgba(255, 90, 40, 0.0)] as CFArray
let glowGradient = CGGradient(colorsSpace: colorSpace, colors: glowColors, locations: [0, 0.55, 1])!
ctx.drawRadialGradient(glowGradient, startCenter: glowCenter, startRadius: 0, endCenter: glowCenter, endRadius: size*0.40, options: [])
ctx.restoreGState()

// Flame silhouette — classic flickering flame shape, single bold form
ctx.saveGState()
let flame = CGMutablePath()
let cx = size * 0.5
let baseY = size * 0.60
let tipY = size * 0.985
// Start at base-left, up the left flank with two flicker bulges, to the tip, down the right flank mirrored (slightly asymmetric)
flame.move(to: CGPoint(x: cx, y: baseY))
flame.addCurve(to: CGPoint(x: cx - size*0.150, y: baseY + (tipY-baseY)*0.38),
                control1: CGPoint(x: cx - size*0.045, y: baseY + (tipY-baseY)*0.02),
                control2: CGPoint(x: cx - size*0.170, y: baseY + (tipY-baseY)*0.16))
flame.addCurve(to: CGPoint(x: cx - size*0.060, y: baseY + (tipY-baseY)*0.62),
                control1: CGPoint(x: cx - size*0.128, y: baseY + (tipY-baseY)*0.54),
                control2: CGPoint(x: cx - size*0.100, y: baseY + (tipY-baseY)*0.60))
flame.addCurve(to: CGPoint(x: cx - size*0.030, y: baseY + (tipY-baseY)*0.90),
                control1: CGPoint(x: cx - size*0.035, y: baseY + (tipY-baseY)*0.68),
                control2: CGPoint(x: cx - size*0.075, y: baseY + (tipY-baseY)*0.80))
flame.addCurve(to: CGPoint(x: cx, y: tipY),
                control1: CGPoint(x: cx + size*0.010, y: baseY + (tipY-baseY)*0.96),
                control2: CGPoint(x: cx - size*0.006, y: tipY))
flame.addCurve(to: CGPoint(x: cx + size*0.045, y: baseY + (tipY-baseY)*0.88),
                control1: CGPoint(x: cx + size*0.020, y: tipY),
                control2: CGPoint(x: cx + size*0.048, y: baseY + (tipY-baseY)*0.95))
flame.addCurve(to: CGPoint(x: cx + size*0.095, y: baseY + (tipY-baseY)*0.58),
                control1: CGPoint(x: cx + size*0.042, y: baseY + (tipY-baseY)*0.78),
                control2: CGPoint(x: cx + size*0.100, y: baseY + (tipY-baseY)*0.70))
flame.addCurve(to: CGPoint(x: cx + size*0.175, y: baseY + (tipY-baseY)*0.34),
                control1: CGPoint(x: cx + size*0.086, y: baseY + (tipY-baseY)*0.48),
                control2: CGPoint(x: cx + size*0.150, y: baseY + (tipY-baseY)*0.44))
flame.addCurve(to: CGPoint(x: cx, y: baseY),
                control1: CGPoint(x: cx + size*0.195, y: baseY + (tipY-baseY)*0.16),
                control2: CGPoint(x: cx + size*0.048, y: baseY + (tipY-baseY)*0.02))
flame.closeSubpath()
ctx.addPath(flame)
ctx.clip()
let flameColors = [rgba(255, 224, 140, 1.0), rgba(255, 158, 60, 0.98), rgba(220, 70, 38, 0.95)] as CFArray
let flameGradient = CGGradient(colorsSpace: colorSpace, colors: flameColors, locations: [0, 0.5, 1])!
ctx.drawLinearGradient(flameGradient, start: CGPoint(x: cx, y: tipY), end: CGPoint(x: cx, y: baseY), options: [])
ctx.restoreGState()

// inner hot core of the flame (small bright highlight near base)
ctx.saveGState()
let core = CGMutablePath()
core.addEllipse(in: CGRect(x: cx - size*0.028, y: baseY + (tipY-baseY)*0.10, width: size*0.056, height: size*0.10))
ctx.addPath(core)
ctx.setFillColor(rgba(255, 245, 210, 0.85))
ctx.fillPath()
ctx.restoreGState()

// Wall: bold, simplified brick courses (3 large rows), sits in front of / blocks the flame
ctx.saveGState()
let wallTop = size * 0.605
let wallRect = CGRect(x: 0, y: 0, width: size, height: wallTop)
ctx.addRect(wallRect)
ctx.clip()

let wallColors = [rgba(64, 79, 96), rgba(36, 47, 60)] as CFArray
let wallGradient = CGGradient(colorsSpace: colorSpace, colors: wallColors, locations: [0, 1])!
ctx.drawLinearGradient(wallGradient, start: CGPoint(x: 0, y: wallTop), end: CGPoint(x: 0, y: 0), options: [])

let jointColor = rgba(18, 24, 32, 0.95)
ctx.setStrokeColor(jointColor)
let rowH: CGFloat = wallTop / 3.0
var rowY: CGFloat = wallTop
var rowIndex = 0
while rowY > 0.01 {
    ctx.setLineWidth(size * 0.018)
    ctx.move(to: CGPoint(x: 0, y: rowY))
    ctx.addLine(to: CGPoint(x: size, y: rowY))
    ctx.strokePath()
    let brickW: CGFloat = size * 0.34
    let offset: CGFloat = (rowIndex % 2 == 0) ? 0 : brickW/2
    var colX: CGFloat = -brickW + offset
    while colX < size {
        ctx.move(to: CGPoint(x: colX, y: rowY))
        ctx.addLine(to: CGPoint(x: colX, y: max(rowY - rowH, 0)))
        ctx.strokePath()
        colX += brickW
    }
    rowY -= rowH
    rowIndex += 1
}

// crisp top edge of the wall + subtle highlight
ctx.setStrokeColor(rgba(150, 175, 200, 0.55))
ctx.setLineWidth(size * 0.010)
ctx.move(to: CGPoint(x: 0, y: wallTop))
ctx.addLine(to: CGPoint(x: size, y: wallTop))
ctx.strokePath()

ctx.restoreGState()

// Glass-style top sheen across the whole icon (Liquid Glass hint)
ctx.saveGState()
ctx.addPath(squirclePath(in: rect, cornerRadius: cornerRadius))
ctx.clip()
let sheen = CGMutablePath()
sheen.move(to: CGPoint(x: -size*0.1, y: size*1.02))
sheen.addLine(to: CGPoint(x: size*1.1, y: size*1.02))
sheen.addLine(to: CGPoint(x: size*1.1, y: size*0.72))
sheen.addQuadCurve(to: CGPoint(x: -size*0.1, y: size*0.80), control: CGPoint(x: size*0.5, y: size*0.58))
sheen.closeSubpath()
ctx.addPath(sheen)
ctx.clip()
let sheenColors = [rgba(255,255,255,0.24), rgba(255,255,255,0.0)] as CFArray
let sheenGradient = CGGradient(colorsSpace: colorSpace, colors: sheenColors, locations: [0,1])!
ctx.drawLinearGradient(sheenGradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: 0, y: size*0.68), options: [])
ctx.restoreGState()

ctx.restoreGState()

// Outer subtle border stroke
ctx.addPath(squirclePath(in: rect.insetBy(dx: 1, dy: 1), cornerRadius: cornerRadius))
ctx.setStrokeColor(rgba(0,0,0,0.25))
ctx.setLineWidth(2)
ctx.strokePath()

guard let image = ctx.makeImage() else { fatalError("no image") }

let outPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon_1024.png"
let url = URL(fileURLWithPath: outPath)
guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    fatalError("no dest")
}
CGImageDestinationAddImage(dest, image, nil)
CGImageDestinationFinalize(dest)
print("wrote \(outPath)")
