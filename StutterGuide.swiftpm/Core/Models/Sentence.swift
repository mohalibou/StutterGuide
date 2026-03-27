import Foundation

struct Sentence: Identifiable, Hashable, Codable {
    var id = UUID()
    var text: String
    var difficulty: Difficulty
    
    init(text: String, difficulty: Difficulty) {
        self.text = text
        self.difficulty = difficulty
    }
    
    enum Difficulty: String, Codable, CaseIterable {
        case easy
        case medium
        case hard
        
        var displayName: String {
            rawValue.capitalized
        }
        
        var promptDescription: String {
            switch self {
            case .easy: "(Easy) 3 to 5 common, everyday words. Simple subject-verb or subject-verb-object structure. No difficult sounds."
            case .medium: "(Medium) 6 to 8 words. A complete thought with some descriptive language. Positive and relatable topic."
            case .hard: "(Hard) 9 to 12 words, OR a tongue-twister with repeating sounds. Can include alliteration. Still age-appropriate."
            }
        }
    }
}

// MARK: - Fallback Library (used when Foundation Models is unavailable)
extension Sentence {
    static let fallbackLibrary: [Sentence] = [
        // Easy (3-5 words)
        Sentence(text: "I like cats.", difficulty: .easy),
        Sentence(text: "The sun is warm.", difficulty: .easy),
        Sentence(text: "We can read together.", difficulty: .easy),
        Sentence(text: "My dog is happy.", difficulty: .easy),
        Sentence(text: "I love pizza.", difficulty: .easy),
        Sentence(text: "The sky is blue.", difficulty: .easy),
        Sentence(text: "Birds sing in trees.", difficulty: .easy),
        Sentence(text: "I can do this.", difficulty: .easy),
        Sentence(text: "Rain makes puddles.", difficulty: .easy),
        Sentence(text: "We play outside.", difficulty: .easy),
        Sentence(text: "Stars shine at night.", difficulty: .easy),
        Sentence(text: "I feel brave today.", difficulty: .easy),
        Sentence(text: "The moon is bright.", difficulty: .easy),
        Sentence(text: "Flowers smell nice.", difficulty: .easy),
        Sentence(text: "I draw pictures.", difficulty: .easy),
        Sentence(text: "The water is cool.", difficulty: .easy),
        Sentence(text: "Books are my friends.", difficulty: .easy),
        Sentence(text: "I am growing tall.", difficulty: .easy),
        Sentence(text: "Music makes me smile.", difficulty: .easy),
        Sentence(text: "The wind blows softly.", difficulty: .easy),
        
        // Medium (6-8 words)
        Sentence(text: "The happy dog played in the park.", difficulty: .medium),
        Sentence(text: "My sister made pancakes for breakfast.", difficulty: .medium),
        Sentence(text: "We built a tall tower with blocks.", difficulty: .medium),
        Sentence(text: "I helped my mom bake cookies today.", difficulty: .medium),
        Sentence(text: "The friendly cat sleeps on my bed.", difficulty: .medium),
        Sentence(text: "We went to the beach last summer.", difficulty: .medium),
        Sentence(text: "I practice reading every single night.", difficulty: .medium),
        Sentence(text: "The rainbow appeared after the big storm.", difficulty: .medium),
        Sentence(text: "My best friend and I ride bikes.", difficulty: .medium),
        Sentence(text: "I can tie my shoes all by myself.", difficulty: .medium),
        Sentence(text: "The library has so many great books.", difficulty: .medium),
        Sentence(text: "We planted seeds in the garden yesterday.", difficulty: .medium),
        Sentence(text: "I learned to swim in the pool.", difficulty: .medium),
        Sentence(text: "The stars twinkle brightly in the sky.", difficulty: .medium),
        Sentence(text: "My teacher reads us fun stories daily.", difficulty: .medium),
        Sentence(text: "I can count all the way to one hundred.", difficulty: .medium),
        Sentence(text: "The ice cream truck came down our street.", difficulty: .medium),
        Sentence(text: "We made a fort with blankets and pillows.", difficulty: .medium),
        Sentence(text: "I drew a picture of my whole family.", difficulty: .medium),
        Sentence(text: "The playground is my favorite place to go.", difficulty: .medium),
        
        // Hard (9-12 words or tongue twisters)
        Sentence(text: "She sells seashells by the seashore.", difficulty: .hard),
        Sentence(text: "The purple butterfly floated above the flowers.", difficulty: .hard),
        Sentence(text: "Friendly dolphins swam beside our little boat.", difficulty: .hard),
        Sentence(text: "Today I can speak with calm, steady breaths.", difficulty: .hard),
        Sentence(text: "Peter Piper picked a peck of pickled peppers.", difficulty: .hard),
        Sentence(text: "The cheerful children chose chocolate chip cookies for their special snack.", difficulty: .hard),
        Sentence(text: "I believe I can accomplish anything when I practice every single day.", difficulty: .hard),
        Sentence(text: "The bright yellow butterfly landed softly on the beautiful blooming sunflower.", difficulty: .hard),
        Sentence(text: "Betty Botter bought some butter but the butter was bitter.", difficulty: .hard),
        Sentence(text: "My grandmother's garden grows gorgeous green vegetables all summer long.", difficulty: .hard),
        Sentence(text: "The curious kitten carefully climbed the colorful climbing tree.", difficulty: .hard),
        Sentence(text: "Six silly sisters sat silently sipping sweet strawberry smoothies together.", difficulty: .hard),
        Sentence(text: "I discovered that practicing my reading helps me become a better speaker.", difficulty: .hard),
        Sentence(text: "The talented artist painted pretty purple and pink patterns on paper.", difficulty: .hard),
        Sentence(text: "Round and round the rugged rocks the ragged rascal ran.", difficulty: .hard),
        Sentence(text: "My adventurous older brother built an incredible fort in our backyard.", difficulty: .hard),
        Sentence(text: "Five friendly frogs found fresh fruit floating freely in the flowing fountain.", difficulty: .hard),
        Sentence(text: "Speaking smoothly takes patience, practice, and believing in yourself every single day.", difficulty: .hard),
        Sentence(text: "The magnificent magician made marvelous magic with mirrors and mysterious tricks.", difficulty: .hard),
        Sentence(text: "I am proud of myself for trying my best even when things feel difficult.", difficulty: .hard)
    ]
    
    static func fallback(for difficulty: Difficulty) -> Sentence {
        fallbackLibrary
            .filter { $0.difficulty == difficulty }
            .randomElement()
        ?? fallbackLibrary.randomElement()
        ?? Sentence(text: "I can do this.", difficulty: .easy)
    }
}
