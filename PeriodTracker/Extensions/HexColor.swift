//
//  HexColor.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftUI

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }
    
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat, a: CGFloat = 1.0) {
        self.init(red: red, green: green, blue: blue, alpha: a)
    }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

extension Color {
    func toRGB() -> [CGFloat]? {
            // Convert SwiftUI Color to UIColor
            let uiColor = UIColor(self)
            
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
                return [red, green, blue, alpha]
            } else {
                // Could not extract RGBA (e.g. for system colors like .secondary)
                return nil
            }
        }
}
