import Foundation
import SwiftData

@Observable
@MainActor
final class PracticeManager {
    private(set) var currentSentence: Sentence
    private(set) var transcript = ""
    private(set) var visualTranscript = ""
    private(set) var isListening = false
    private(set) var detectedHesitation = false
    private(set) var didCompleteCurrentAttempt = false
    private(set) var completedSmoothly = false
    private(set) var isGeneratingSentence = false
    private(set) var statusMessage = "Tap Start Practice, breathe slowly, and read at your own pace. I'll help you notice word repetitions."
    private(set) var celebrationTick = 0
    
    private(set) var todaysSmoothCount = 0
    private(set) var todaysAttemptCount = 0
    var dailyGoal: Int { 12 }
    
    var showAlert = false
    var alertMessage = ""
    
    private var startDate: Date?
    private var modelContext: ModelContext?
    private var hasSavedAttempt = false
    
    private var previousSegments: [SpeechManager.TranscriptionSegment] = []
    
    private let speechManager: SpeechManager
    private let sentenceManager: SentenceManager
    
    init(speechManager: SpeechManager, sentenceManager: SentenceManager) {
        self.speechManager = speechManager
        self.sentenceManager = sentenceManager
        self.currentSentence = .fallback(for: .easy)
    }
    
    // MARK: - Practice Control
    
    func startPractice(using context: ModelContext) async {
        if isListening { return }
        
        modelContext = context
        
        let granted = await Task { [speechManager] in
            await speechManager.requestPermissions()
        }.value
        
        guard granted else {
            alertMessage = "Please allow Speech Recognition and Microphone access in Settings so we can help with practice."
            showAlert = true
            return
        }
        
        resetAttemptState()
        startDate = .now
        isListening = true
        statusMessage = "Take a deep breath. Read at a steady pace and I'll watch for repeated words."
        
        do {
            try speechManager.startRecognition(
                onTranscript: handleTranscriptUpdate,
                onError: handleRecognitionError
            )
        } catch {
            isListening = false
            alertMessage = (error as? LocalizedError)?.errorDescription ?? "Unable to start speech recognition."
            showAlert = true
            statusMessage = "Let's try again in a quiet place."
        }
    }
    
    func stopPractice(saveProgress: Bool) {
        guard isListening else { return }
        
        speechManager.stopRecognition()
        isListening = false
        
        if saveProgress {
            finalizeAttempt(isSentenceCompleted: false)
        } else {
            statusMessage = "Practice paused. Tap Start Practice when you are ready."
        }
    }
    
    func nextSentence(difficulty: Sentence.Difficulty? = nil) {
        guard !isListening else { return }
        
        let targetDifficulty = difficulty ?? currentSentence.difficulty
        transcript = ""
        visualTranscript = ""
        detectedHesitation = false
        didCompleteCurrentAttempt = false
        completedSmoothly = false
        hasSavedAttempt = false
        previousSegments = []
        isGeneratingSentence = true
        statusMessage = "Getting your next sentence ready..."
        
        Task {
            currentSentence = await sentenceManager.generateSentence(difficulty: targetDifficulty)
            isGeneratingSentence = false
            statusMessage = "New sentence ready. Tap Start Practice."
        }
    }
    
    func prepareFirstSentence() {
        nextSentence(difficulty: .easy)
    }
    
    func refreshTodaysProgress(from context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let descriptor = FetchDescriptor<PracticeSession>(
            predicate: #Predicate<PracticeSession> { session in
                session.date >= today && session.date < tomorrow
            }
        )
        
        guard let sessions = try? context.fetch(descriptor) else {
            todaysAttemptCount = 0
            todaysSmoothCount = 0
            return
        }
        
        todaysAttemptCount = sessions.count
        todaysSmoothCount = sessions.filter { $0.wasSmooth }.count
    }

    private func detectHesitantSpeech(
        newSegments: [SpeechManager.TranscriptionSegment],
        previousSegments: [SpeechManager.TranscriptionSegment]
    ) -> Bool {
        
        guard newSegments.count >= 2 else { return false }
        
        let recentSegments = Array(newSegments.suffix(6))
        
        for i in 0..<(recentSegments.count - 1) {
            let currentWord = recentSegments[i].substring.lowercased().trimmingCharacters(in: .whitespaces)
            let nextWord = recentSegments[i + 1].substring.lowercased().trimmingCharacters(in: .whitespaces)
            
            if currentWord == nextWord && !currentWord.isEmpty && currentWord.count >= 2 {
                return true
            }
        }
        
        return false
    }
    
    private func buildVisualTranscript(from segments: [SpeechManager.TranscriptionSegment]) -> String {
        guard !segments.isEmpty else { return "" }
        
        var result: [String] = []
        var previousWord = ""
        
        for segment in segments {
            let word = segment.substring.trimmingCharacters(in: .whitespaces)
            
            if word.lowercased() == previousWord.lowercased() && !word.isEmpty {
                result.append("→ \(word)")
            } else {
                result.append(word)
                previousWord = word
            }
        }
        
        return result.joined(separator: " ")
    }
    
    // MARK: - Handlers
    
    private func handleTranscriptUpdate(_ result: SpeechManager.TranscriptionResult) {
        let newSegments = result.segments
        
        let hesitationDetected = detectHesitantSpeech(
            newSegments: newSegments,
            previousSegments: previousSegments
        )
        
        transcript = result.formattedString
        visualTranscript = buildVisualTranscript(from: newSegments)
        
        if hesitationDetected {
            detectedHesitation = true
        }
        
        previousSegments = newSegments
        
        guard !didCompleteCurrentAttempt else { return }
        
        if didReadTargetSentence(in: result.formattedString) {
            finalizeAttempt(isSentenceCompleted: true)
        }
    }
    
    private func handleRecognitionError(_ error: SpeechManager.ServiceError) {
        if didCompleteCurrentAttempt { return }
        
        alertMessage = error.errorDescription ?? "Speech recognition stopped unexpectedly."
        showAlert = true
        stopPractice(saveProgress: false)
    }
    
    private func finalizeAttempt(isSentenceCompleted: Bool) {
        guard !hasSavedAttempt else { return }
        
        speechManager.stopRecognition()
        isListening = false
        
        let cleanedTranscript = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedTranscript.isEmpty else {
            statusMessage = "I couldn't hear enough speech. Let's try again together."
            return
        }
        
        hasSavedAttempt = true
        didCompleteCurrentAttempt = isSentenceCompleted
        
        let wasSmooth = isSentenceCompleted && !detectedHesitation
        completedSmoothly = wasSmooth
        
        let duration = max(Int(Date().timeIntervalSince(startDate ?? .now)), 1)
        
        saveSession(
            sentence: currentSentence.text,
            transcript: cleanedTranscript,
            wasSmooth: wasSmooth,
            detectedHesitation: detectedHesitation,
            durationSeconds: duration
        )
        
        if wasSmooth {
            celebrationTick += 1
            statusMessage = "No word repetitions! You read that smoothly!"
        } else if isSentenceCompleted {
            statusMessage = "I noticed some repeated words. Let's try again with slow, steady breathing."
        } else {
            statusMessage = "Practice saved. Tap Start Practice to continue."
        }
    }
    
    private func didReadTargetSentence(in transcription: String) -> Bool {
        let transcriptWords = normalizedWords(from: transcription)
        let targetWords = normalizedWords(from: currentSentence.text)
        
        guard !transcriptWords.isEmpty, !targetWords.isEmpty else { return false }
        
        var targetIndex = 0
        
        for word in transcriptWords {
            if targetIndex < targetWords.count && word == targetWords[targetIndex] {
                targetIndex += 1
            }
        }
        
        return targetIndex == targetWords.count
    }
    
    private func normalizedWords(from text: String) -> [String] {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
    }
    
    private func resetAttemptState() {
        transcript = ""
        visualTranscript = ""
        detectedHesitation = false
        didCompleteCurrentAttempt = false
        completedSmoothly = false
        hasSavedAttempt = false
        previousSegments = []
    }
    
    private func saveSession(
        sentence: String,
        transcript: String,
        wasSmooth: Bool,
        detectedHesitation: Bool,
        durationSeconds: Int
    ) {
        guard let modelContext else { return }
        
        let session = PracticeSession(
            date: .now,
            sentence: sentence,
            wasSmooth: wasSmooth,
            durationSeconds: durationSeconds,
            detectedHesitation: detectedHesitation,
            transcript: transcript
        )
        
        modelContext.insert(session)
        
        do {
            try modelContext.save()
            refreshTodaysProgress(from: modelContext)
        } catch {
            print("Failed to save practice session: \(error.localizedDescription)")
        }
    }
}
