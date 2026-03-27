import SwiftUI

struct DailyProgressBar: View {
    let dailyGoal: Int
    let smoothCount: Int
    let attemptCount: Int
    
    private var circles: [CircleState] {
        var result: [CircleState] = []
        
        for _ in 0..<smoothCount {
            result.append(.smooth)
        }
        
        let nonSmoothAttempts = attemptCount - smoothCount
        for _ in 0..<nonSmoothAttempts {
            result.append(.attempted)
        }
        
        let remaining = max(0, dailyGoal - attemptCount)
        for _ in 0..<remaining {
            result.append(.empty)
        }
        
        return result
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(circles.enumerated()), id: \.offset) { index, state in
                    CircleIndicator(state: state)
                        .transition(.scale.combined(with: .opacity))
                        .id(index)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
        }
        .frame(height: 60)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Daily progress")
        .accessibilityValue("\(attemptCount) of \(dailyGoal) practice attempts completed. \(smoothCount) were smooth.")
    }
    
    enum CircleState {
        case smooth
        case attempted
        case empty
    }
}

private struct CircleIndicator: View {
    let state: DailyProgressBar.CircleState
    
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 44, height: 44)
                .overlay(
                    Circle()
                        .stroke(borderColor, lineWidth: strokeWidth)
                )
            
            if let icon = iconName {
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
        }
        .scaleEffect(appeared ? 1.0 : 0.3)
        .opacity(appeared ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
    
    private var backgroundColor: Color {
        switch state {
        case .smooth:
            return AppTheme.success.opacity(0.2)
        case .attempted:
            return AppTheme.accent.opacity(0.2)
        case .empty:
            return AppTheme.card
        }
    }
    
    private var borderColor: Color {
        switch state {
        case .smooth:
            return AppTheme.success.opacity(0.5)
        case .attempted:
            return AppTheme.accent.opacity(0.5)
        case .empty:
            return AppTheme.primary.opacity(0.2)
        }
    }
    
    private var strokeWidth: CGFloat {
        switch state {
        case .smooth, .attempted:
            return 2.5
        case .empty:
            return 1.5
        }
    }
    
    private var iconName: String? {
        switch state {
        case .smooth:
            return "checkmark.circle.fill"
        case .attempted:
            return "heart.circle.fill"
        case .empty:
            return nil
        }
    }
    
    private var iconColor: Color {
        switch state {
        case .smooth:
            return AppTheme.success
        case .attempted:
            return AppTheme.accent
        case .empty:
            return .clear
        }
    }
    
    private var iconSize: CGFloat {
        switch state {
        case .smooth, .attempted:
            return 24
        case .empty:
            return 0
        }
    }
}

#Preview {
    VStack(spacing: 32) {
        VStack(alignment: .leading, spacing: 8) {
            Text("Just Started")
                .font(.caption)
                .foregroundStyle(.secondary)
            DailyProgressBar(dailyGoal: 12, smoothCount: 1, attemptCount: 2)
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Making Progress")
                .font(.caption)
                .foregroundStyle(.secondary)
            DailyProgressBar(dailyGoal: 12, smoothCount: 4, attemptCount: 7)
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Almost There!")
                .font(.caption)
                .foregroundStyle(.secondary)
            DailyProgressBar(dailyGoal: 12, smoothCount: 8, attemptCount: 10)
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Goal Completed!")
                .font(.caption)
                .foregroundStyle(.secondary)
            DailyProgressBar(dailyGoal: 12, smoothCount: 10, attemptCount: 12)
        }
    }
    .padding()
    .background(AppTheme.background)
}
