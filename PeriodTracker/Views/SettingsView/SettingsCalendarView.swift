//
//  SettingsCalendarView.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftUI
import SwiftData

struct SettingsCalendarView: View {
    @Environment(\.dismiss) var dismiss
    let defaults = UserDefaults.standard
    @State private var menstrualColor: Color
    @State private var predictionMenstrualColor: Color
    @State private var ovulationColor: Color
    @State private var predictionOvulationColor: Color
    @State private var informativeColor: Color
    @State private var bgColor: Color
    @State private var bgColorGradient: Color
    @State private var menstrualIcon = "🎃"
    @State private var ovulationIcon = "🪺"
    @State private var informativeIcon = "🤓"
    @State private var padBrand = ""
    @State private var tamponBrand = ""
    @State private var isGradient: Bool = false
    private var possibleIcons: [NamedImage] = []
    
    init() {
        var uiColor: UIColor = UIColor(.gray)
        var arr: [CGFloat] = []
        
        for emoji in emojis {
            var tmpNamedImg = NamedImage()
            tmpNamedImg.setEmojiImage(id: emoji)
            possibleIcons.append(tmpNamedImg)
        }
        
        // Bg
        arr = (defaults.array(forKey: "bgColor") as? [CGFloat] ?? Color(.gray).toRGB())!
        uiColor = UIColor(red: arr[0], green: arr[1], blue: arr[2], a: arr[3])
        bgColor = Color(uiColor)
        arr = (defaults.array(forKey: "bgColorGradient") as? [CGFloat] ?? Color(.gray).toRGB())!
        uiColor = UIColor(red: arr[0], green: arr[1], blue: arr[2], a: arr[3])
        bgColorGradient = Color(uiColor)
        isGradient = defaults.bool(forKey: "isGradient")
        
        // Menstrual
        menstrualIcon = defaults.string(forKey: "menstrualIcon") ?? "🎃"
        arr = (defaults.array(forKey: "menstrualColor") as? [CGFloat] ?? Color("menstrual").toRGB())!
        uiColor = UIColor(red: arr[0], green: arr[1], blue: arr[2], a: arr[3])
        menstrualColor = Color(uiColor)
        arr = (defaults.array(forKey: "predictionMenstrualColor") as? [CGFloat] ?? Color("paleMenstrual").toRGB())!
        uiColor = UIColor(red: arr[0], green: arr[1], blue: arr[2], a: arr[3])
        predictionMenstrualColor = Color(uiColor)
        
        // Ovulation
        ovulationIcon = defaults.string(forKey: "ovulationIcon") ?? "🪺"
        arr = (defaults.array(forKey: "ovulationColor") as? [CGFloat] ?? Color("ovulation").toRGB())!
        uiColor = UIColor(red: arr[0], green: arr[1], blue: arr[2], a: arr[3])
        ovulationColor = Color(uiColor)
        arr = (defaults.array(forKey: "predictionOvulationColor") as? [CGFloat] ?? Color("paleOvulation").toRGB())!
        uiColor = UIColor(red: arr[0], green: arr[1], blue: arr[2], a: arr[3])
        predictionOvulationColor = Color(uiColor)
        
        // Informative
        informativeIcon = defaults.string(forKey: "informativeIcon") ?? "🤓"
        arr = (defaults.array(forKey: "informativeColor") as? [CGFloat] ?? Color("luteal").toRGB())!
        uiColor = UIColor(red: arr[0], green: arr[1], blue: arr[2], a: arr[3])
        informativeColor = Color(uiColor)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                VStack {
                    Text("Need to close & re-open app to see changes").font(.system(size: 20))
                    Spacer()
                    
                    // Menstrual
                    VStack {
                        Text("Menstrual:")
                        // Event image/emoji
                        Text("Icon to display:")
                        Spacer()
                        RadioButtonImageGroup(options: self.possibleIcons, selectedOption: $menstrualIcon)
                        Spacer()
                        // Menstrual Color Picker
                        ColorPicker("Color", selection: $menstrualColor)
                        Spacer()
                        // Menstrual Prediction Color Picker
                        ColorPicker("Prediction Color", selection: $predictionMenstrualColor)
                    }
                    Spacer()
                    // Ovulation
                    VStack {
                        Text("Ovulation:")
                        // Event image/emoji
                        Text("Icon to display:")
                        Spacer()
                        RadioButtonImageGroup(options: self.possibleIcons, selectedOption: $menstrualIcon)
                        Spacer()
                        // Ovulation Color Picker
                        ColorPicker("Color", selection: $ovulationColor)
                        Spacer()
                        // Ovulation Prediction Color Picker
                        ColorPicker("Prediction Color", selection: $predictionOvulationColor)
                    }
                    Spacer()
                    // Informative
                    VStack {
                        Text("Informative:")
                        // Event image/emoji
                        Text("Icon to display:")
                        Spacer()
                        RadioButtonImageGroup(options: self.possibleIcons, selectedOption: $menstrualIcon)
                        Spacer()
                        // Informative Color Picker
                        ColorPicker("Color", selection: $informativeColor)
                    }
                    Spacer()
                    // Background color/image
                    VStack {
                        Text("Background color")
                        Toggle(isOn: $isGradient) {
                            Text("Make the background a gradient?")
                        }
                        ColorPicker("Background Color", selection: $bgColor)
                        if isGradient {
                            ColorPicker("Gradient Color", selection: $bgColorGradient)
                        }
                        Spacer()
                    }
                    Spacer()
                    VStack {
                        Text("Brands").font(.title)
                        Spacer()
                        HStack {
                            Text("Pads:")
                            TextField("Pads", text: $padBrand )
                        }
                        Spacer()
                        HStack {
                            Text("Tampons:")
                            TextField("Tampons", text: $tamponBrand )
                        }
                    }
                }
                Section(footer:
                    Button {
                    defaults.set(menstrualColor.toRGB() ?? Color("menstrual").toRGB(), forKey: "menstrualColor")
                    defaults.set(ovulationColor.toRGB() ?? Color("ovulation").toRGB(), forKey: "ovulationColor")
                    defaults.set(informativeColor.toRGB() ?? Color("luteal").toRGB(), forKey: "informativeColor")
                    defaults.set(predictionMenstrualColor.toRGB() ?? Color("paleMenstrual").toRGB(), forKey: "predictionMenstrualColor")
                    defaults.set(predictionOvulationColor.toRGB() ?? Color("paleOvulation").toRGB(), forKey: "predictionOvulationColor")
                    defaults.set(bgColor.toRGB() ?? Color(.gray).toRGB(), forKey: "bgColor")
                    defaults.set(bgColorGradient.toRGB() ?? Color(.gray).toRGB(), forKey: "bgColorGradient")
                    defaults.set(isGradient, forKey: "isGradient")
                    defaults.set(menstrualIcon, forKey: "menstrualIcon")
                    defaults.set(ovulationIcon, forKey: "ovulationIcon")
                    defaults.set(informativeIcon, forKey: "informativeIcon")
                    defaults.set(padBrand, forKey: "padBrand")
                    defaults.set(tamponBrand, forKey: "tamponBrand")
                    dismiss()
                } label: {
                    Text("Save & Exit").font(.system(size:40))
                }
                ) {
                    EmptyView()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
