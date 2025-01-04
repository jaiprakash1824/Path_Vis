//
//  ViewModel.swift
//  Webview
//
//  Created by Jai Prakash Veerla on 1/1/25.
//


import AVFoundation
import Foundation
import Observation
import XCAOpenAIClient
import UIKit

@Observable
class ViewModel: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    let client = OpenAIClient(apiKey: "")
    var audioPlayer: AVAudioPlayer!
    var audioRecorder: AVAudioRecorder!
    #if !os(macOS)
    var recordingSession = AVAudioSession.sharedInstance()
    #endif
    var animationTimer: Timer?
    var recordingTimer: Timer?
    var audioPower = 0.0
    var prevAudioPower: Double?
    var processingSpeechTask: Task<Void, Never>?
    
    var selectedVoice = VoiceType.alloy
    
    var captureURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("recording.m4a")
    }
    
    var state = VoiceChatState.idle {
        didSet { print(state) }
    }
    var isIdle: Bool {
        if case .idle = state {
            return true
        }
        return false
    }
    
    var siriWaveFormOpacity: CGFloat {
        switch state {
        case .recordingSpeech, .playingSpeech: return 1
        default: return 0
        }
    }
    
    override init() {
        super.init()
        #if !os(macOS)
        do {
            #if os(iOS)
            try recordingSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            #else
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            #endif
            try recordingSession.setActive(true)
            
            AVAudioApplication.requestRecordPermission { [unowned self] allowed in
                if !allowed {
                    self.state = .error("Recording not allowed by the user")
                }
            }
        } catch {
            state = .error(error)
        }
        #endif
    }
    
    func startCaptureAudio(image: UIImage) {
        resetValues()
        state = .recordingSpeech
        do {
            audioRecorder = try AVAudioRecorder(url: captureURL,
                                                settings: [
                                                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                                                    AVSampleRateKey: 12000,
                                                    AVNumberOfChannelsKey: 1,
                                                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                                                ])
            audioRecorder.isMeteringEnabled = true
            audioRecorder.delegate = self
            audioRecorder.record()
            
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [unowned self]_ in
                guard self.audioRecorder != nil else { return }
                self.audioRecorder.updateMeters()
                let power = min(1, max(0, 1 - abs(Double(self.audioRecorder.averagePower(forChannel: 0)) / 50) ))
                self.audioPower = power
            })
            
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.6, repeats: true, block: { [unowned self]_ in
                guard self.audioRecorder != nil else { return }
                self.audioRecorder.updateMeters()
                let power = min(1, max(0, 1 - abs(Double(self.audioRecorder.averagePower(forChannel: 0)) / 50) ))
                if self.prevAudioPower == nil {
                    self.prevAudioPower = power
                    return
                }
                if let prevAudioPower = self.prevAudioPower, prevAudioPower < 0.25 && power < 0.175 {
                    print("Started using CHAT GPT")
                    self.finishCaptureAudio(image:image)
                    return
                }
                self.prevAudioPower = power
            })
            
        } catch {
            resetValues()
            state = .error(error)
        }
    }
    
    func finishCaptureAudio(image: UIImage) {
        resetValues()
        do {
            let data = try Data(contentsOf: captureURL)
            processingSpeechTask = processSpeechTask(audioData: data, image: image)
        } catch {
            state = .error(error)
            resetValues()
        }
    }
    
    func sendPromptWithImage(apiKey: String, prompt: String, image: UIImage) async throws -> String {
        // Encode the UIImage to Base64
        let base64Image = try encodeUIImageToBase64(image: image)
        let imageUrl = "data:image/png;base64,\(base64Image)"

        // Construct the request payload
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",  // Update to the correct model name
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ],
                [
                    "role": "user",
                    "content": [
                        ["type": "image_url", "image_url": ["url": imageUrl]]
                    ]
                ]
            ]
        ]

        // Convert the request body to JSON
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])

        // Prepare the HTTP request
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw NSError(domain: "OpenAIAPIError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        // Perform the API call
        let (data, response) = try await URLSession.shared.data(for: request)

        // Check the HTTP response status
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw NSError(domain: "OpenAIAPIError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server: \(statusCode)"])
        }

        // Parse the response JSON
        guard
            let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let choices = responseObject["choices"] as? [[String: Any]],
            let firstChoice = choices.first,
            let message = firstChoice["message"] as? [String: Any],
            let content = message["content"] as? String
        else {
            throw NSError(domain: "OpenAIAPIError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }

        return content
    }

    // Helper function to encode UIImage to Base64
    func encodeUIImageToBase64(image: UIImage) throws -> String {
        guard let imageData = image.pngData() else {
            throw NSError(domain: "ImageEncodingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode image"])
        }
        return imageData.base64EncodedString()
    }
    
    func processSpeechTask(audioData: Data, image: UIImage) -> Task<Void, Never> {
        Task { @MainActor [unowned self] in
            do {
                self.state = .processingSpeech
                let prompt = try await client.generateAudioTransciptions(audioData: audioData)
                print("Prompt received: \(prompt)")
                try Task.checkCancellation()
                let imageData = image.pngData() // Convert UIImage to Data
                guard let imageData else {
                    throw NSError(domain: "ImageConversionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert UIImage to data."])
                }
                let responseText = try await sendPromptWithImage(apiKey: "", prompt: prompt, image: image)
                print("Response received for prompt '\(prompt)': \(responseText)")
                try Task.checkCancellation()
                let speechData = try await client.generateSpeechFrom(input: responseText, voice: .init(rawValue: selectedVoice.rawValue) ?? .alloy)
                
                try Task.checkCancellation()
                try self.playAudio(data: speechData)
            } catch {
                if Task.isCancelled { return }
                state = .error(error)
                resetValues()
            }
        }
    }
    
    func processSpeechTask(audioData: Data) -> Task<Void, Never> {
        Task { @MainActor [unowned self] in
            do {
                self.state = .processingSpeech
                let prompt = try await client.generateAudioTransciptions(audioData: audioData)
                print("prompt received : " + prompt)
                try Task.checkCancellation()
                let responseText = try await client.promptChatGPT(prompt: prompt)
                print(prompt + " response received : " + responseText)
                try Task.checkCancellation()
                let data = try await client.generateSpeechFrom(input: responseText, voice:
                        .init(rawValue: selectedVoice.rawValue) ?? .alloy)
                
                try Task.checkCancellation()
                try self.playAudio(data: data)
            } catch {
                if Task.isCancelled { return }
                state = .error(error)
                resetValues()
            }
        }
    }
    
    func playAudio(data: Data) throws {
        self.state = .playingSpeech
        audioPlayer = try AVAudioPlayer(data: data)
        audioPlayer.isMeteringEnabled = true
        audioPlayer.delegate = self
        audioPlayer.play()
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [unowned self]_ in
            guard self.audioPlayer != nil else { return }
            self.audioPlayer.updateMeters()
            let power = min(1, max(0, 1 - abs(Double(self.audioPlayer.averagePower(forChannel: 0)) / 160) ))
            self.audioPower = power
        })
    }
    
    func cancelRecording() {
        resetValues()
        state = .idle
    }
    
    func cancelProcessingTask() {
        processingSpeechTask?.cancel()
        processingSpeechTask = nil
        resetValues()
        state = .idle
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            resetValues()
            state = .idle
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        resetValues()
        state = .idle
    }
    
    func resetValues() {
        audioPower = 0
        prevAudioPower = nil
        audioRecorder?.stop()
        audioRecorder = nil
        audioPlayer?.stop()
        audioPlayer = nil
        recordingTimer?.invalidate()
        recordingTimer = nil
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
}
