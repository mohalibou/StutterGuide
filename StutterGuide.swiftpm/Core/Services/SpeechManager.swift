import AVFoundation
import Foundation
import Speech

@Observable
final class SpeechManager {
    enum ServiceError: LocalizedError {
        case recognizerUnavailable
        case onDeviceUnavailable
        case audioSetupFailed
        case recognitionFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .recognizerUnavailable:
                return "Speech recognition is not available on this device."
            case .onDeviceUnavailable:
                return "On-device speech recognition is required. Please go to Settings → General → Language & Region and ensure English is downloaded for offline use."
            case .audioSetupFailed:
                return "Could not set up audio input. Please check your microphone."
            case .recognitionFailed(let detail):
                return "Speech recognition stopped: \(detail)"
            }
        }
    }
    
    struct TranscriptionSegment {
        let substring: String
    }
    
    struct TranscriptionResult {
        let formattedString: String
        let segments: [TranscriptionSegment]
    }
    
    private let recognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var isStoppingIntentionally = false
    
    var isOnDeviceAvailable: Bool {
        recognizer?.supportsOnDeviceRecognition ?? false
    }
    
    init(locale: Locale = Locale(identifier: "en-US")) {
        self.recognizer = SFSpeechRecognizer(locale: locale)
    }
    
    func requestPermissions() async -> Bool {
        let micGranted = await requestMicrophonePermission()
        let speechGranted = await requestSpeechPermission()
        
        return micGranted && speechGranted
    }
    
    func startRecognition(
        onTranscript: @escaping @MainActor (TranscriptionResult) -> Void,
        onError: @escaping @MainActor (ServiceError) -> Void
    ) throws {
        guard let recognizer, recognizer.isAvailable else {
            throw ServiceError.recognizerUnavailable
        }
        
        guard recognizer.supportsOnDeviceRecognition else {
            throw ServiceError.onDeviceUnavailable
        }
        
        stopRecognition()
        isStoppingIntentionally = false
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(
            .playAndRecord,
            mode: .measurement,
            options: [.duckOthers, .defaultToSpeaker]
        )
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.addsPunctuation = false
        request.requiresOnDeviceRecognition = true
        recognitionRequest = request
        
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        guard inputFormat.sampleRate > 0 else {
            throw ServiceError.audioSetupFailed
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { buffer, _ in
            request.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            if let result = result {
                let transcription = result.bestTranscription
                let formattedString = transcription.formattedString
                
                let segments = transcription.segments.map { segment in
                    TranscriptionSegment(substring: segment.substring)
                }
                
                let transcriptionResult = TranscriptionResult(
                    formattedString: formattedString,
                    segments: segments
                )
                
                Task { @MainActor in
                    onTranscript(transcriptionResult)
                }
            }
            
            if let error {
                guard self?.isStoppingIntentionally != true else { return }
                
                Task { @MainActor in
                    onError(.recognitionFailed(error.localizedDescription))
                }
                self?.stopRecognition()
            }
        }
    }
    
    func stopRecognition() {
        isStoppingIntentionally = true
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
    }
    
    private func requestSpeechPermission() async -> Bool {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { status in
                    continuation.resume(returning: status == .authorized)
                }
            }
        default:
            return false
        }
    }
    
    private func requestMicrophonePermission() async -> Bool {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            return true
        case .undetermined:
            return await AVAudioApplication.requestRecordPermission()
        default:
            return false
        }
    }
}
