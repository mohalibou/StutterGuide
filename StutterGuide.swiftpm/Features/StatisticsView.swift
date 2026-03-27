import Charts
import SwiftData
import SwiftUI

struct StatisticsView: View {
    @Query(sort: \PracticeSession.date, order: .reverse) private var sessions: [PracticeSession]
    @Environment(ProgressManager.self) private var progressManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                FlexibleGrid(columns: 2, spacing: 12) {
                    MiniCard(title: "Smooth This Week", value: "\(progressManager.smoothThisWeek)")
                    MiniCard(title: "Practice Time", value: progressManager.totalPracticeLabel)
                    MiniCard(title: "Current Streak", value: "\(progressManager.streakDays) days")
                    MiniCard(title: "Sessions", value: "\(sessions.count)")
                }
                
                BigCard(title: "Readings Without Word Repetitions (Last 7 Days)") {
                    WeeklySmoothChart(data: progressManager.weeklyProgress)
                }
                
                BigCard(title: "Recent Practice") {
                    RecentPracticeView(recentSessions: progressManager.recentSessions)
                }
            }
            .padding(24)
        }
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
        .background(AppTheme.background.ignoresSafeArea())
        .onAppear {
            progressManager.refresh(with: sessions)
        }
        .onChange(of: sessions) { _, updatedSessions in
            progressManager.refresh(with: updatedSessions)
        }
    }
}

#Preview {
    StatisticsView()
}

private struct WeeklySmoothChart: View {
    let data: [DailySmoothProgress]
    
    var body: some View {
        Chart {
            ForEach(data.isEmpty ? emptyData : data) { point in
                BarMark(
                    x: .value("Day", point.dayLabel),
                    y: .value("Count", point.smoothCount)
                )
                .cornerRadius(7)
                .foregroundStyle(
                    point.smoothCount == 0
                    ? AppTheme.primary.opacity(0.2)
                    : AppTheme.primary
                )
                .annotation(position: .top, spacing: 8) {
                    Text("\(point.smoothCount)")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(AppTheme.text.opacity(0.7))
                }
            }
        }
        .chartYScale(domain: 0...max((data.map(\.smoothCount).max() ?? 1), 1))
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(position: .bottom) { _ in
                AxisValueLabel()
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.text.opacity(0.75))
            }
        }
        .frame(height: 170)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Readings without word repetitions last 7 days")
        .accessibilityValue(data.isEmpty ? "No sessions yet" : "\(totalSmoothCount) smooth readings total")
    }
    
    private var totalSmoothCount: Int {
        data.map(\.smoothCount).reduce(0, +)
    }
    
    private var emptyData: [DailySmoothProgress] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let counts = [0, 0, 0, 0, 0, 0, 0]
        return (0..<7).compactMap { index in
            guard let day = calendar.date(byAdding: .day, value: -6 + index, to: today) else { return nil }
            return DailySmoothProgress(
                date: day,
                dayLabel: day.formatted(.dateTime.weekday(.abbreviated)),
                smoothCount: counts[index]
            )
        }
    }
}

private struct RecentPracticeView: View {
    
    var recentSessions: [PracticeSession]
    
    var body: some View {
        if recentSessions.isEmpty {
            Text("No sessions yet. Start a practice and your progress will show here.")
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(AppTheme.text.opacity(0.7))
        } else {
            ForEach(recentSessions) { session in
                HStack(spacing: 12) {
                    Image(systemName: session.wasSmooth ? "checkmark.circle.fill" : "heart.circle.fill")
                        .foregroundStyle(session.wasSmooth ? AppTheme.success : AppTheme.accent)
                        .font(.title2)
                        .accessibilityHidden(true)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.sentence)
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .foregroundStyle(AppTheme.text)
                            .lineLimit(2)
                        
                        Text("\(session.date.formatted(date: .abbreviated, time: .shortened)) - \(formattedDuration(seconds: session.durationSeconds))")
                            .font(.system(.footnote, design: .rounded, weight: .medium))
                            .foregroundStyle(AppTheme.text.opacity(0.65))
                    }
                    
                    Spacer(minLength: 0)
                }
                .padding(12)
                .background(AppTheme.background, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .accessibilityElement(children: .combine)
            }
        }
    }
    
    func formattedDuration(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        if minutes == 0 {
            return "\(remainingSeconds)s"
        }
        
        if remainingSeconds == 0 {
            return "\(minutes)m"
        }
        
        return "\(minutes)m \(remainingSeconds)s"
    }
}
