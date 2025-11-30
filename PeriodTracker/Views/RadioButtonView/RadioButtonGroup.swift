//
//  RadioButtonGroup.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftUI

struct RadioButtonGroup<Option: Identifiable & Equatable>: View {
    let options: [Option]
    let label: (Option) -> String   // How to display each option
    @Binding var selectedOption: Option
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack() {
                ForEach(options) { option in
                    RadioButton(
                        label: label(option),
                        image: nil,
                        isSelected: selectedOption == option
                    ) {
                        selectedOption = option
                    }
                }
            }
        }
    }
}

struct RadioButtonMultiSelectGroup<Option: Identifiable & Equatable>: View {
    let options: [Option]
    let label: (Option) -> String   // How to display each option
    @Binding var selectedOption: [Option]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack() {
                ForEach(options) { option in
                    RadioButton(
                        label: label(option),
                        image: nil,
                        isSelected: selectedOption.contains(option)
                    ) {
                        if selectedOption.contains(option) {
                            selectedOption.removeAll(where: {$0 == option})
                        }
                        else {
                            selectedOption.append(option)
                        }
                    }
                }
            }
        }
    }
}

struct RadioButtonImageGroup: View {
    let options: [NamedImage]
    @Binding var selectedOption: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack() {
                ForEach(options) { option in
                    RadioButton(
                        label: option.id,
                        image: option.image,
                        isSelected: selectedOption == option.id
                    ) {
                        selectedOption = option.id
                    }
                }
            }
        }
        .padding(.vertical, 10)
    }
}
