import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("showingOnboarding") private var showOnboarding = true
    
    @State private var currentPage = 0
    private let totalPages = 3
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    WelcomePage().tag(0)
                    
                    EducationPage().tag(1)
                    
                    PrivacyPage().tag(2)
                }
                .accessibilityElement(children: .combine)
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                VStack(spacing: 20) {
                    PageIndicator(currentPage: currentPage, totalPages: totalPages)
                    
                    if currentPage == totalPages - 1 {
                        AppButton(type: .getStarted) {
                            completeOnboarding()
                        }
                        .padding(.horizontal, 24)
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        } label: {
                            Text("Next")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 74)
                                .background(AppTheme.primary, in: .rect(cornerRadius: 24, style: .continuous))
                        }
                        .padding(.horizontal, 24)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
    }
    
    private func completeOnboarding() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            showOnboarding = false
        }
        dismiss()
    }
}

// MARK: - Welcome Page
private struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            BreathingCharacter(isActive: true, celebrationTick: 0)
                .scaleEffect(0.9)
            
            VStack(spacing: 16) {
                Text("Welcome to\nStutterGuide")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.text)
                
                Text("Build awareness of word repetitions. Practice reading aloud and notice when you repeat words.")
                    .font(.system(.title2, design: .rounded, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.text.opacity(0.75))
                    .padding(.horizontal, 32)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

private struct EducationPage: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("What Are Word\nRepetitions?")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.text)
                    
                    Text("Word repetitions happen when you say the same word multiple times in a row.")
                        .font(.system(.title3, design: .rounded, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.text.opacity(0.75))
                        .padding(.horizontal, 20)
                }
                .padding(.top, 40)
                
                VStack(spacing: 24) {
                    FeatureCard(
                        icon: "quote.opening",
                        color: AppTheme.accent,
                        title: "Examples",
                        description: "Saying 'I I want to go' or 'the the dog is happy' are examples of repeating words. This is a common stuttering pattern."
                    )
                    
                    FeatureCard(
                        icon: "eye.fill",
                        color: AppTheme.primary,
                        title: "Building Awareness",
                        description: "Many people who stutter don't realize when repetitions happen. This app helps you notice them in real-time as you read."
                    )
                    
                    FeatureCard(
                        icon: "mic.fill",
                        color: AppTheme.success,
                        title: "How It Works",
                        description: "Read practice sentences aloud. When you repeat a word, you'll see 'the → the' with gentle coaching to slow down and breathe."
                    )
                    
                    FeatureCard(
                        icon: "chart.bar.fill",
                        color: AppTheme.primary.opacity(0.8),
                        title: "Track Progress",
                        description: "See how many times you read smoothly without word repetitions. Watch your awareness grow over time."
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
    }
}

private struct PrivacyPage: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 110, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppTheme.primary, AppTheme.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.bottom, 10)
                .accessibilityHidden(true)
            
            VStack(spacing: 16) {
                Text("Your Privacy\nMatters")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.text)
                
                VStack(spacing: 20) {
                    PrivacyPoint(
                        icon: "waveform",
                        text: "Audio is processed live on your device using Apple's Speech framework"
                    )
                    
                    PrivacyPoint(
                        icon: "xmark.circle.fill",
                        text: "No recordings are ever saved or stored anywhere"
                    )
                    
                    PrivacyPoint(
                        icon: "network.slash",
                        text: "Everything works offline, no internet connection needed"
                    )
                    
                    PrivacyPoint(
                        icon: "hand.raised.fill",
                        text: "Your practice sessions stay completely private on your device"
                    )
                }
                .padding(.horizontal, 32)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

private struct FeatureCard: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(.title, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(AppTheme.text)
                
                Text(description)
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.text.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(AppTheme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(color.opacity(0.2), lineWidth: 1.5)
        )
        .accessibilityElement(children: .combine)
    }
}

private struct PrivacyPoint: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(.title3, weight: .semibold))
                .foregroundStyle(AppTheme.success)
                .frame(width: 24)
                .accessibilityHidden(true)
            
            Text(text)
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(AppTheme.text.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct PageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? AppTheme.primary : AppTheme.primary.opacity(0.3))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
        .padding(.bottom, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(currentPage + 1) of \(totalPages)")
    }
}

#Preview {
    OnboardingView()
}
