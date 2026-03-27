import SwiftUI

@main
struct StutterGuideApp: App {
    @AppStorage("showingOnboarding") var showOnboarding = true

    @State private var progressManager: ProgressManager
    @State private var speechManager: SpeechManager
    @State private var sentenceManager: SentenceManager
    @State private var practiceManager: PracticeManager

    init() {
        let speech = SpeechManager()
        let sentences = SentenceManager()
        let practice = PracticeManager(speechManager: speech, sentenceManager: sentences)
        let progress = ProgressManager()

        _speechManager = State(initialValue: speech)
        _sentenceManager = State(initialValue: sentences)
        _practiceManager = State(initialValue: practice)
        _progressManager = State(initialValue: progress)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(progressManager)
                .environment(speechManager)
                .environment(sentenceManager)
                .environment(practiceManager)
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView()
                }
                .transaction { transaction in
                    if showOnboarding {
                        transaction.disablesAnimations = true
                    }
                }
                .task {
                    practiceManager.prepareFirstSentence()
                }
        }
        .modelContainer(for: [PracticeSession.self])
    }
}
