//
//  NamedImage.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftUI
import Foundation

struct NamedImage: Identifiable {
    var id: String
    var image: UIImage
    
    init() {
        self.image = UIImage()
        self.id = ""
    }
    
    init(image: UIImage, id: String) {
        self.image = image
        self.id = id
    }
    
    mutating func setEmojiImage(id: String) {
        self.id = id
        
        self.image = self.id.emojiToImage()!
    }    
}
