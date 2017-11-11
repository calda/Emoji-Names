//
//  UIImage+Color.swift
//  Emoji Names
//
//  Created by Cal Stephens on 11/10/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

extension UIImage {
    
    var primaryColor: UIColor {
        guard let image = self.cgImage else { return .white }
        let pixelData = image.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        typealias Pixel = (red: Int, green: Int, blue: Int)
        func pixelAtPoint(_ x: Int, _ y: Int) -> Pixel {
            let pixelIndex = ((Int(self.size.width) * y) + x) * 4
            let b = Int(data[pixelIndex])
            let g = Int(data[pixelIndex + 1])
            let r = Int(data[pixelIndex + 2])
            return (r, g, b)
        }
        
        func clampInt(_ int: Int, onInterval interval: Int) -> Int {
            return Int(int / interval) * interval
        }
        
        var countMap: [String : (color: Pixel, count: Int)] = [:]
        var maximum: (color: Pixel, count: Int)?
        
        for y in 0 ..< Int(self.size.width) {
            for x in 0 ..< Int(self.size.height) {
                let pixel = pixelAtPoint(x, y)
                
                //ignore if this color is close to grayscale
                let average = (pixel.red + pixel.green + pixel.blue) / 3
                if abs(pixel.red - average) < 5
                    && abs(pixel.green - average) < 5
                    && abs(pixel.red - average) < 5 {
                    continue
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
        
        let color = maximum?.color ?? (red: 255, green: 255, blue: 255)
        return UIColor(red: CGFloat(color.red) / 255.0, green: CGFloat(color.green) / 255.0, blue: CGFloat(color.blue) / 255.0, alpha: 1.0)
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
    
    var secondaryColorsForBackground: (text: UIColor, border: UIColor) {
        var hue : CGFloat  = 0.0
        var sat : CGFloat  = 0.0
        var bright : CGFloat  = 0.0
        getHue(&hue, saturation: &sat, brightness: &bright, alpha: nil)
        
        var textColor = UIColor(hue: hue, saturation: sat, brightness: bright + 0.35, alpha: 1.0)

        let lumaDiff = abs(textColor.luma - self.luma)
        if lumaDiff < 0.8 && textColor.luma > 0.1 {
            textColor = UIColor(hue: hue, saturation: sat, brightness: bright - 0.35, alpha: 1.0)
        } else if lumaDiff < 0.8 {
            textColor = UIColor(hue: hue, saturation: sat - 0.5, brightness: bright + 0.5, alpha: 1.0)
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
