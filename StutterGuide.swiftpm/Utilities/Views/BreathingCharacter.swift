import SwiftUI

struct BreathingCharacter: View {
    let isActive: Bool
    let celebrationTick: Int
    
    @State private var breatheIn = false
    @State private var showSparkles = false
    
    var body: some View {
        ZStack {
            if showSparkles {
                ForEach(0..<8, id: \.self) { index in
                    Image(systemName: "sparkle")
                        .font(.system(.callout, weight: .bold))
                        .foregroundStyle(AppTheme.accent)
                        .offset(sparkleOffset(for: index))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppTheme.accent.opacity(0.65), AppTheme.primary.opacity(0.7)],
                        center: .center,
                        startRadius: 16,
                        endRadius: 95
                    )
                )
                .overlay(
                    Circle()
                        .stroke(AppTheme.primary.opacity(0.45), lineWidth: 5)
                )
            
            Image(systemName: "face.smiling")
                .font(.system(.largeTitle, weight: .medium))
                .foregroundStyle(.white.opacity(0.95))
        }
        .frame(width: 190, height: 190)
        .scaleEffect(currentScale)
        .shadow(color: AppTheme.primary.opacity(0.25), radius: 16, y: 8)
        .animation(
            isActive ? .easeInOut(duration: 2.0).repeatForever(autoreverses: true) : .easeInOut(duration: 0.2),
            value: breatheIn
        )
        .onAppear {
            breatheIn = isActive
        }
        .onChange(of: isActive) { _, active in
            breatheIn = active
        }
        .onChange(of: celebrationTick) {
            triggerCelebration()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Breathing companion")
        .accessibilityValue(isActive ? "Breathing in and out" : "Waiting for practice")
    }
    
    private var currentScale: CGFloat {
        guard isActive else {
            return 1.0
        }
        return breatheIn ? 1.08 : 0.90
    }
    
    private func sparkleOffset(for index: Int) -> CGSize {
        let angle = Double(index) * (.pi * 2 / 8)
        return CGSize(width: cos(angle) * 92, height: sin(angle) * 92)
    }
    
    private func triggerCelebration() {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.65)) {
            showSparkles = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.easeOut(duration: 0.2)) {
                showSparkles = false
            }
        }
    }
}
