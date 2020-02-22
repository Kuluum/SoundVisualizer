//
//  MicrophoneMonitor.swift
//  SoundVisualuzer
//
//  Created by Daniil on 22.02.2020.
//  Copyright © 2020 Kuluum. All rights reserved.
//

import Foundation
import AVFoundation

class MicrophoneMonitor: ObservableObject {
    
    private var audioRecorder: AVAudioRecorder
    private var timer: Timer?
    
    private var currentSample: Int
    private let numberOfSamples: Int
    
    @Published public var soundSamles: [Float]
    
    init(numberOfSamples: Int) {
        self.numberOfSamples = numberOfSamples
        self.soundSamles = [Float](repeating: .zero, count: numberOfSamples)
        self.currentSample = 0
        
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.recordPermission != .granted {
            audioSession.requestRecordPermission { (isGranted) in
                if !isGranted {
                    fatalError("Allow audio recording")
                }
            }
        }
        
        let url = URL(fileURLWithPath: "/dev/null", isDirectory: true)
        let recordedSettings: [String: Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: recordedSettings)
            try audioSession.setCategory(.playAndRecord, mode:.default, options: [])
            
            startMonitoring()
        } catch {
            fatalError("Exception")
        }
    }
    
    func startMonitoring() {
        audioRecorder.isMeteringEnabled = true
        audioRecorder.record()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
            self.audioRecorder.updateMeters()
            self.soundSamles[self.currentSample] = self.audioRecorder.averagePower(forChannel: 0)
            self.currentSample = (self.currentSample + 1) % self.numberOfSamples
        })
    }
    
    deinit {
        timer?.invalidate()
        audioRecorder.stop()
    }
}
