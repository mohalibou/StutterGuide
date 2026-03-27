import Foundation
import SwiftData

@Model
final class PracticeSession {
    var id = UUID()
    var date: Date
    var sentence: String
    var wasSmooth: Bool
    var durationSeconds: Int
    var detectedHesitation: Bool
    var transcript: String
    
    init(
        date: Date = .now,
        sentence: String,
        wasSmooth: Bool,
        durationSeconds: Int,
        detectedHesitation: Bool,
        transcript: String
    ) {
        self.date = date
        self.sentence = sentence
        self.wasSmooth = wasSmooth
        self.durationSeconds = durationSeconds
        self.detectedHesitation = detectedHesitation
        self.transcript = transcript
    }
}
