//
//  ContentView.swift
//  SoundVisualuzer
//
//  Created by Daniil on 22.02.2020.
//  Copyright © 2020 Kuluum. All rights reserved.
//

import SwiftUI

let numberOfSamples: Int = 10


struct ContentView: View {
    
    @ObservedObject private var mic = MicrophoneMonitor(numberOfSamples: numberOfSamples)
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 50) / 2
        
        return CGFloat(level * (300 / 25))
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                ForEach(mic.soundSamles, id: \.self) { level in
                    BarView(value: self.normalizeSoundLevel(level: level))
                }
            }
        }
    }
    
}

struct BarView: View {
    
    var value: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(gradient: Gradient(colors: [.purple, .blue]),
                                     startPoint: .top,
                                     endPoint: .bottom))
                .frame(width: (UIScreen.main.bounds.width - CGFloat(numberOfSamples) * 4) / CGFloat(numberOfSamples), height: value)
        }
    }
}
