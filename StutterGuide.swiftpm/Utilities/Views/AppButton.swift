import SwiftUI

struct AppButton: View {
    
    var type: ButtonType
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Label(type.text, systemImage: type.symbol)
                .font(.system(.title2, design: .rounded, weight: type.weight))
                .foregroundStyle(type.foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 74)
                .background(type.backgroundColor, in: .rect(cornerRadius: 24, style: .continuous))
                .overlay {
                    if let borderColor = type.borderColor {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(borderColor, lineWidth: 1)
                    }
                }
        }
    }
    
    enum ButtonType: Hashable {
        case getStarted
        case viewProgress
        case startPractice
        case stopListening
        case newSentenceEasy
        case newSentenceMedium
        case newSentenceHard
        case tryAgainTogether
        
        var text: String {
            switch self {
            case .getStarted: "Get Started"
            case .viewProgress: "View Progress"
            case .startPractice: "Start Practice"
            case .stopListening: "Stop Listening"
            case .newSentenceEasy: "New (Easy)"
            case .newSentenceMedium: "New (Medium)"
            case .newSentenceHard: "New (Hard)"
            case .tryAgainTogether: "Try Again Together"
            }
        }
        
        var symbol: String {
            switch self {
            case .getStarted: "play.fill"
            case .viewProgress: "chart.bar.fill"
            case .startPractice: "mic.fill"
            case .stopListening: "stop.fill"
            case .newSentenceEasy: "arrow.clockwise"
            case .newSentenceMedium: "arrow.clockwise"
            case .newSentenceHard: "arrow.clockwise"
            case .tryAgainTogether: "heart.fill"
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .getStarted: .white
            case .viewProgress: AppTheme.text
            case .startPractice: .white
            case .stopListening: .white
            case .newSentenceEasy: AppTheme.text
            case .newSentenceMedium: AppTheme.text
            case .newSentenceHard: AppTheme.text
            case .tryAgainTogether: AppTheme.text
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .getStarted: AppTheme.primary
            case .viewProgress: AppTheme.accent
            case .startPractice: AppTheme.primary
            case .stopListening: Color.orange
            case .newSentenceEasy: .white
            case .newSentenceMedium: .white
            case .newSentenceHard: .white
            case .tryAgainTogether: AppTheme.accent.opacity(0.85)
            }
        }
        
        var borderColor: Color? {
            switch self {
            case .getStarted: nil
            case .viewProgress: nil
            case .startPractice: nil
            case .stopListening: nil
            case .newSentenceEasy: AppTheme.primary.opacity(0.2)
            case .newSentenceMedium: AppTheme.primary.opacity(0.2)
            case .newSentenceHard: AppTheme.primary.opacity(0.2)
            case .tryAgainTogether: nil
            }
        }
        
        var style: Font.TextStyle {
            switch self {
            case .getStarted: .title2
            case .viewProgress: .title3
            case .startPractice: .title2
            case .stopListening: .title2
            case .newSentenceEasy: .title3
            case .newSentenceMedium: .title3
            case .newSentenceHard: .title3
            case .tryAgainTogether: .title2
            }
        }
        
        var weight: Font.Weight {
            switch self {
            case .getStarted: .bold
            case .viewProgress: .semibold
            case .startPractice: .bold
            case .stopListening: .bold
            case .newSentenceEasy: .semibold
            case .newSentenceMedium: .semibold
            case .newSentenceHard: .semibold
            case .tryAgainTogether: .semibold
            }
        }
    }
}

#Preview {
    VStack {
        AppButton(type: .getStarted) { }
        AppButton(type: .viewProgress) { }
        AppButton(type: .startPractice) { }
        AppButton(type: .newSentenceEasy) { }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(AppTheme.background.ignoresSafeArea())
    
}

