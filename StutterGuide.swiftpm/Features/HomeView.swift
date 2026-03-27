import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PracticeSession.date, order: .reverse) private var sessions: [PracticeSession]
    
    private var smoothThisWeek: Int {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: .now) else {
            return sessions.filter { $0.wasSmooth }.count
        }
        
        return sessions.filter { session in
            session.wasSmooth && interval.contains(session.date)
        }.count
    }
    
    private var totalPracticeMinutes: Int {
        sessions.reduce(0) { $0 + $1.durationSeconds } / 60
    }
    
    @State private var showPracticeView: Bool = false
    @State private var showStatisticsView: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 26) {
                    VStack(spacing: 10) {
                        Text("StutterGuide")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundStyle(AppTheme.text)
                        
                        Text("Build awareness of word repetitions. Practice noticing when you repeat words as you read aloud.")
                            .font(.system(.title2, design: .rounded, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AppTheme.text.opacity(0.8))
                            .padding(.horizontal, 10)
                    }
                    
                    BreathingCharacter(isActive: true, celebrationTick: 0)
                    
                    HStack(spacing: 12) {
                        MiniCard(title: "Smooth This Week", value: "\(smoothThisWeek)")
                        MiniCard(title: "Practice Time", value: "\(totalPracticeMinutes)m")
                    }
                    
                    VStack(spacing: 14) {
                        AppButton(type: .getStarted) {
                            showPracticeView.toggle()
                        }
                        .accessibilityHint("Opens the reading practice session")
                        
                        AppButton(type: .viewProgress) {
                            showStatisticsView.toggle()
                        }
                        .accessibilityHint("Shows weekly progress and recent practice history")
                    }
                    
                    Text("Audio is processed live on your device and recordings are never saved.")
                        .font(.system(.callout, design: .rounded, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.text.opacity(0.7))
                        .padding(.horizontal, 18)
                }
                .padding(24)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showPracticeView) {
                PracticeView()
            }
            .navigationDestination(isPresented: $showStatisticsView) {
                StatisticsView()
            }
        }
    }
}
