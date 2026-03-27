import Foundation

#if canImport(FoundationModels)
import FoundationModels

// MARK: - Generable Response Type

@Generable
struct GeneratedSentenceResponse {
    @Guide(description: "A single, complete practice sentence for a child aged 6–12 who stutters. Must be positive, encouraging, and age-appropriate. No scary, sad, or complex topics.")
    var text: String
}
#endif

@Observable
@MainActor
final class SentenceManager {
    
    enum GeneratorState {
        case idle
        case generating
        case unavailable
    }
    
    private(set) var state: GeneratorState = .idle
    private(set) var lastError: String?
    
    let isAvailable: Bool
    
#if canImport(FoundationModels)
    private var session: LanguageModelSession?
#endif
    private var generationCount = 0
    
    init() {
#if canImport(FoundationModels)
        self.isAvailable = SystemLanguageModel.default.isAvailable
#else
        self.isAvailable = false
#endif
    }
    
    func generateSentence(difficulty: Sentence.Difficulty) async -> Sentence {
        guard isAvailable else {
            return .fallback(for: difficulty)
        }
        
        state = .generating
        lastError = nil
        
        do {
            let sentence = try await generate(difficulty: difficulty)
            state = .idle
            return sentence
        } catch {
            state = .idle
            lastError = error.localizedDescription
            return .fallback(for: difficulty)
        }
    }
    
    // MARK: - Private Generation
    
    private func generate(difficulty: Sentence.Difficulty) async throws -> Sentence {
#if canImport(FoundationModels)
        generationCount += 1
        if generationCount % 10 == 0 {
            session = nil
        }
        
        if session == nil {
            session = LanguageModelSession(model: .default)
        }
        
        guard let session else {
            throw GenerationError.sessionUnavailable
        }
        
        let prompt = buildPrompt(for: difficulty)
        
        let response = try await session.respond(
            to: prompt,
            generating: GeneratedSentenceResponse.self
        )
        
        let text = response.content.text
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard text.count >= 5 else {
            throw GenerationError.invalidResponse
        }
        
        return Sentence(text: text, difficulty: difficulty)
#else
        throw GenerationError.sessionUnavailable
#endif
    }
    
    private func buildPrompt(for difficulty: Sentence.Difficulty) -> String {
        """
        You are helping a child aged 3–6 who stutters practice reading aloud.
        
        Generate exactly ONE short practice sentence at this difficulty level:
        \(difficulty.promptDescription)
        
        Rules:
        - The sentence must be cheerful, positive, and encouraging
        - Use simple, common vocabulary a child would know
        - No scary, violent, sad, or confusing topics
        - Do NOT include quotation marks, explanations, or any text other than the sentence itself
        - End with a period
        
        Examples of good sentences:
        Easy: "My dog is soft."
        Easy: "I like my red hat."
        Easy: "The sun is bright."
        Easy: "Dad makes soup."
        Medium: "We played outside after school today."
        Medium: "The puppy ran across the green grass."
        Medium: "I cleaned my room all by myself."
        Medium: "The team worked together to win."
        Hard: "The bouncy bunny hopped between the bright blue flowers."
        Hard: "The cheerful children carefully painted a colorful mural."
        Hard: "The rainbow stretched across the wide blue sky."
        Hard: "Our family happily gathered for dinner together."
        
        Generate one new sentence now:
        """
    }
    
    // MARK: - Errors
    
    enum GenerationError: LocalizedError {
        case sessionUnavailable
        case invalidResponse
        
        var errorDescription: String? {
            switch self {
            case .sessionUnavailable:
                return "Language model session could not be created."
            case .invalidResponse:
                return "Generated sentence was invalid."
            }
        }
    }
}
