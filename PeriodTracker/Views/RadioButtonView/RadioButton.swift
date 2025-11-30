//
//  RadioButton.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftUI

struct RadioButton: View {
    let label: String
    let image: UIImage?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                if image == nil {
                    Image(systemName: isSelected ? "circle.inset.filled" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray)
                        .imageScale(.large)
                }
                else {
                    Image(uiImage: image!)
                        .background(isSelected ? .blue : .clear)
                        .imageScale(.large)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .aspectRatio(contentMode: .fit)
                }
                Text(label.replacingOccurrences(of: "_", with: " ").capitalized)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
//        .buttonStyle(.plain)
    }
}
