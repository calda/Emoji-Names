//
//  UIImage+Color.swift
//  Emoji Names
//
//  Created by Cal Stephens on 11/10/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

extension UIImage {
    
    var prominentColor: UIColor {
        guard let pixelData = self.onWhiteBackground?.cgImage?.dataProvider?.data else {
            return #colorLiteral(red: 0.75, green: 0.75, blue: 0.75, alpha: 1)
        }
        
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        typealias Pixel = (red: Int, green: Int, blue: Int)
        
        func pixelAtPoint(_ x: Int, _ y: Int) -> Pixel {
            let pixelIndex = ((Int(self.size.width) * y) + x) * 4
            let r = Int(data[pixelIndex + 2])
            let g = Int(data[pixelIndex + 1])
            let b = Int(data[pixelIndex])
            let alpha = Int(data[pixelIndex + 3])
            
            if alpha < 255 {
                return (0, 0, 0)
            }
            
            return (r, g, b)
        }
        
        func clampInt(_ int: Int, onInterval interval: Int) -> Int {
            return Int(int / interval) * interval
        }
        
        enum ProminentColorMode {
            case ignoreGrayscale
            case ignoreWhiteOnly
            case ignoreNothing
        }
        
        func mostFrequentColor(_ mode: ProminentColorMode) -> UIColor? {
            var countMap: [String : (color: Pixel, count: Int)] = [:]
            var maximum: (color: Pixel, count: Int)?
            
            for y in 0 ..< Int(self.size.width) {
                for x in 0 ..< Int(self.size.height) {
                    let pixel = pixelAtPoint(x, y)
                    
                    if mode == .ignoreGrayscale {
                        //ignore if this color is close to grayscale
                        let average = (pixel.red + pixel.green + pixel.blue) / 3
                        if abs(pixel.red - average) < 20
                            && abs(pixel.green - average) < 20
                            && abs(pixel.red - average) < 20 {
                            continue
                        }
                    }
                    
                    if mode == .ignoreWhiteOnly {
                        if pixel.red > 250 && pixel.green > 250 && pixel.red > 250 {
                            continue
                        }
                    }
                    
                    let red = clampInt(pixel.red, onInterval: 20)
                    let green = clampInt(pixel.green, onInterval: 20)
                    let blue = clampInt(pixel.blue, onInterval: 20)
                    let key = "r:\(red) g:\(green) b:\(blue)"
                    
                    var (_, currentCount) = countMap[key] ?? ((0, 0, 0), 0)
                    currentCount += 1
                    countMap.updateValue((pixel, currentCount), forKey: key)
                    
                    if currentCount > (maximum?.count ?? 0) {
                        maximum = (pixel, currentCount)
                    }
                }
            }
            
            guard let pixel = maximum?.color else {
                return nil
            }
            
            return UIColor(
                red: CGFloat(pixel.red) / 255.0,
                green: CGFloat(pixel.green) / 255.0,
                blue: CGFloat(pixel.blue) / 255.0,
                alpha: 1.0)
        }
        
        let prominentColor = mostFrequentColor(.ignoreGrayscale)
            ?? mostFrequentColor(.ignoreWhiteOnly)
            ?? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        return prominentColor
    }
    
    private var onWhiteBackground: UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        guard let cgImage = cgImage else { return nil }
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        
        guard let imageOnWhite = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        return imageOnWhite
    }
    
}

extension UIColor {
    
    var luma: CGFloat {
        var r : CGFloat  = 0.0
        var g : CGFloat  = 0.0
        var b : CGFloat  = 0.0
        getRed(&r, green: &g, blue: &b, alpha: nil)
        
        let lumaR : CGFloat = CGFloat(r) * 0.3
        let lumaG : CGFloat = CGFloat(g) * 0.59
        let lumaB : CGFloat = CGFloat(b) * 0.11
        return (lumaR + lumaG + lumaB) / 3
    }
    
    var lightened: UIColor {
        return lightened(by: 0.1)
    }
    
    var stronglyLightened: UIColor {
        return lightened(by: 0.25)
    }
    
    private func lightened(by desaturationAmount: CGFloat) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: nil)
        
        // lighten grays/blacks
        if s <= 0.1 {
            return UIColor(hue: h, saturation: s, brightness: b + 0.2, alpha: 1)
        }
            
        // desaturate vibrant colors
        else {
            return UIColor(hue: h, saturation: max(s - desaturationAmount, 0.1), brightness: b, alpha: 1)
        }
    }
    
    var secondaryColorsForBackground: (text: UIColor, border: UIColor) {
        var hue : CGFloat  = 0.0
        var sat : CGFloat  = 0.0
        var bright : CGFloat  = 0.0
        getHue(&hue, saturation: &sat, brightness: &bright, alpha: nil)
        
        var textColor = UIColor(hue: hue, saturation: sat, brightness: bright + 0.35, alpha: 1.0)

        var lumaDiff = abs(textColor.luma - self.luma)
        if lumaDiff < 0.8 && textColor.luma > 0.1 {
            textColor = UIColor(hue: hue, saturation: sat, brightness: bright - 0.35, alpha: 1.0)
            lumaDiff = abs(textColor.luma - self.luma)
        }
        
        if lumaDiff < 0.05 || textColor.luma < 0.1 {
            textColor = UIColor(hue: hue, saturation: sat - 0.25, brightness: bright + 0.5, alpha: 1.0)
        }
        
        let borderColor = UIColor(hue: hue, saturation: sat, brightness: bright - 0.1, alpha: 1.0)
        
        return (textColor, borderColor)
    }
    
    func approxEquals(_ other: UIColor, within: CGFloat = 0.025) -> Bool {
        var thisRed: CGFloat = 0.0
        var thisGreen: CGFloat = 0.0
        var thisBlue: CGFloat = 0.0
        var thisAlpha: CGFloat = 0.0
        self.getRed(&thisRed, green: &thisGreen, blue: &thisBlue, alpha: &thisAlpha)
        
        var otherRed: CGFloat = 0.0
        var otherGreen: CGFloat = 0.0
        var otherBlue: CGFloat = 0.0
        var otherAlpha: CGFloat = 0.0
        other.getRed(&otherRed, green: &otherGreen, blue: &otherBlue, alpha: &otherAlpha)
        
        let diffRed = abs(thisRed - otherRed)
        let diffBlue = abs(thisBlue - otherBlue)
        let diffGreen = abs(thisGreen - otherGreen)
        let diffAlpha = abs(thisAlpha - otherAlpha)
        return diffRed < within && diffBlue < within && diffGreen < within && diffAlpha < within
    }
    
}
