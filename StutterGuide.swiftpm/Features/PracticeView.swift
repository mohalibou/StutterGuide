import SwiftData
import SwiftUI

struct PracticeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PracticeManager.self) private var practiceManager
    
    @State private var showCompletionOverlay = false
    @State private var overlayWasSmooth = false
    
    var body: some View {
        @Bindable var practiceManager = practiceManager
        
        ScrollView {
            VStack(spacing: 20) {
                BreathingCharacter(
                    isActive: practiceManager.isListening,
                    celebrationTick: practiceManager.celebrationTick
                )
                
                PracticeCard(title: "Read This Sentence") {
                    SentenceView(
                        currentSentence: practiceManager.currentSentence,
                        isGenerating: practiceManager.isGeneratingSentence
                    )
                }
                
                if !practiceManager.isListening && !practiceManager.didCompleteCurrentAttempt {
                    TipCard(
                        title: "Try This",
                        message: "When you say a sentence in full, try repeating a word in the sentence twice to see how the app notices word repetitions."
                    )
                    .transition(.scale.combined(with: .opacity))
                }
                
                PracticeCard(title: "What I Hear") {
                    TranscriptView(
                        transcript: practiceManager.visualTranscript,
                        detectedHesitation: practiceManager.detectedHesitation,
                        isListening: practiceManager.isListening
                    )
                }
                
                PracticeCard(title: "Coaching Tips", backgroundColor: AppTheme.success.opacity(0.35)) {
                    StatusView(
                        statusMessage: practiceManager.statusMessage,
                        detectedHesitation: practiceManager.detectedHesitation,
                        isListening: practiceManager.isListening
                    )
                }
                
                if practiceManager.isListening {
                    AppButton(type: .stopListening) {
                        practiceManager.stopPractice(saveProgress: true)
                    }
                } else if practiceManager.didCompleteCurrentAttempt && !practiceManager.completedSmoothly {
                    AppButton(type: .tryAgainTogether) {
                        Task { await practiceManager.startPractice(using: modelContext) }
                    }
                } else {
                    AppButton(type: .startPractice) {
                        Task { await practiceManager.startPractice(using: modelContext) }
                    }
                    .disabled(practiceManager.isGeneratingSentence)
                }
                
                VStack(alignment: .leading) {
                    Text("Create New Sentence")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundStyle(AppTheme.text.opacity(0.75))
                    
                    HStack {
                        AppButton(type: .newSentenceEasy) {
                            practiceManager.nextSentence(difficulty: .easy)
                        }
                        AppButton(type: .newSentenceMedium) {
                            practiceManager.nextSentence(difficulty: .medium)
                        }
                        AppButton(type: .newSentenceHard) {
                            practiceManager.nextSentence(difficulty: .hard)
                        }
                    }
                    .disabled(practiceManager.isListening || practiceManager.isGeneratingSentence)
                }
                
                PracticeCard(title: "Today's Practice") {
                    DailyProgressBar(
                        dailyGoal: practiceManager.dailyGoal,
                        smoothCount: practiceManager.todaysSmoothCount,
                        attemptCount: practiceManager.todaysAttemptCount
                    )
                    if practiceManager.todaysAttemptCount >= practiceManager.dailyGoal {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                            Text("Goal Complete!")
                                .font(.system(.caption, design: .rounded, weight: .bold))
                        }
                        .foregroundStyle(AppTheme.success)
                    } else {
                        Text("\(practiceManager.todaysAttemptCount)/\(practiceManager.dailyGoal)")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundStyle(AppTheme.text.opacity(0.6))
                    }
                }
            }
            .padding(24)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Practice")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Practice Setup", isPresented: $practiceManager.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(practiceManager.alertMessage)
        }
        .onChange(of: practiceManager.didCompleteCurrentAttempt) { _, completed in
            guard completed else { return }
            overlayWasSmooth = practiceManager.completedSmoothly
            withAnimation(.easeIn(duration: 0.2)) {
                showCompletionOverlay = true
            }
        }
        .overlay {
            if showCompletionOverlay {
                CompletionOverlayView(wasSmooth: overlayWasSmooth) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showCompletionOverlay = false
                    }
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            practiceManager.refreshTodaysProgress(from: modelContext)
        }
        .onDisappear {
            practiceManager.stopPractice(saveProgress: false)
            showCompletionOverlay = false
        }
    }
}

private struct CompletionOverlayView: View {
    let wasSmooth: Bool
    let onDismiss: () -> Void
    
    @State private var symbolScale: CGFloat = 0.1
    @State private var symbolOpacity: CGFloat = 0
    @State private var ring1Scale: CGFloat = 0.6
    @State private var ring2Scale: CGFloat = 0.6
    @State private var ring1Opacity: CGFloat = 0.7
    @State private var ring2Opacity: CGFloat = 0.5
    @State private var glowOpacity: CGFloat = 0
    
    private var glowColor: Color {
        wasSmooth ? AppTheme.success : AppTheme.accent
    }
    
    private var symbolName: String {
        wasSmooth ? "checkmark.circle.fill" : "heart.fill"
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.65))
                .ignoresSafeArea()
            
            RadialGradient(
                colors: [
                    glowColor.opacity(0.75),
                    glowColor.opacity(0.35),
                    .clear
                ],
                center: .center,
                startRadius: 40,
                endRadius: 280
            )
            .ignoresSafeArea()
            .opacity(glowOpacity)
            
            Circle()
                .stroke(glowColor.opacity(ring1Opacity), lineWidth: 3)
                .frame(width: 200, height: 200)
                .scaleEffect(ring1Scale)
            
            Circle()
                .stroke(glowColor.opacity(ring2Opacity), lineWidth: 2)
                .frame(width: 200, height: 200)
                .scaleEffect(ring2Scale)
            
            Image(systemName: symbolName)
                .font(.system(size: 100, weight: .medium))
                .foregroundStyle(glowColor)
                .shadow(color: glowColor.opacity(0.8), radius: 30)
                .shadow(color: glowColor.opacity(0.4), radius: 60)
                .scaleEffect(symbolScale)
                .opacity(symbolOpacity)
        }
        .onTapGesture {
            onDismiss()
        }
        .onAppear {
            animateIn()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                onDismiss()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(wasSmooth ? "No word repetitions detected" : "Good effort, keep practicing")
        .accessibilityHint("Double tap to dismiss")
        .accessibilityAddTraits(.isButton)
    }
    
    private func animateIn() {
        let generator = UIImpactFeedbackGenerator(style: wasSmooth ? .heavy : .medium)
        generator.impactOccurred()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.55)) {
            symbolScale = 1.0
            symbolOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.4)) {
            glowOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 1.2)) {
            ring1Scale = 2.2
            ring1Opacity = 0
        }
        
        withAnimation(.easeOut(duration: 1.2).delay(0.2)) {
            ring2Scale = 2.6
            ring2Opacity = 0
        }
    }
}

private struct SentenceView: View {
    let currentSentence: Sentence
    let isGenerating: Bool
    
    var body: some View {
        if isGenerating {
            HStack(spacing: 12) {
                ProgressView()
                    .tint(AppTheme.primary)
                    .accessibilityLabel("Finding your next sentence")
                Text("Finding your next sentence...")
                    .font(.system(.title3, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.text.opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .accessibilityElement(children: .combine)
        } else {
            Text(currentSentence.text)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.text)
                .minimumScaleFactor(0.6)
                .lineSpacing(5)
                .multilineTextAlignment(.leading)
            
            Text(currentSentence.difficulty.displayName)
                .font(.system(.footnote, design: .rounded, weight: .bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppTheme.accent.opacity(0.8), in: Capsule())
                .foregroundStyle(AppTheme.text)
        }
    }
}

private struct TranscriptView: View {
    let transcript: String
    let detectedHesitation: Bool
    let isListening: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(transcript.isEmpty ? "Your words will appear here as you read." : transcript)
                .font(.system(.title2, design: .rounded, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(AppTheme.primary.opacity(0.08), in: .rect(cornerRadius: 18, style: .continuous))
                .foregroundStyle(AppTheme.text)
                .minimumScaleFactor(0.75)
                .lineLimit(4)
                .accessibilityLabel("Spoken words")
                .accessibilityValue(transcript.isEmpty ? "No transcript yet" : transcript)
            
            if detectedHesitation && isListening {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption)
                        .foregroundStyle(AppTheme.accent)
                    Text("I noticed a word repetition — that's what we're practicing!")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(AppTheme.text.opacity(0.75))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.accent.opacity(0.15), in: Capsule())
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

private struct StatusView: View {
    let statusMessage: String
    let detectedHesitation: Bool
    let isListening: Bool
    
    var body: some View {
        Text(statusMessage)
            .font(.system(.title2, design: .rounded, weight: .medium))
            .foregroundStyle(AppTheme.text)
            .minimumScaleFactor(0.75)
        
        if detectedHesitation && isListening {
            Text("Building awareness is the first step. You're doing great!")
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(AppTheme.text.opacity(0.75))
        }
    }
}

#Preview {
    PracticeView()
}
