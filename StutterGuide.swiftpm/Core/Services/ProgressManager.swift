import Foundation

struct DailySmoothProgress: Identifiable {
    let id = UUID()
    let date: Date
    let dayLabel: String
    let smoothCount: Int
}

@Observable
@MainActor
final class ProgressManager {
    private(set) var smoothThisWeek = 0
    private(set) var totalPracticeSeconds = 0
    private(set) var streakDays = 0
    private(set) var weeklyProgress: [DailySmoothProgress] = []
    private(set) var recentSessions: [PracticeSession] = []
    
    func refresh(with sessions: [PracticeSession]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        
        var smoothPerDay: [Date: Int] = [:]
        for session in sessions where session.wasSmooth {
            let day = calendar.startOfDay(for: session.date)
            smoothPerDay[day, default: 0] += 1
        }
        
        var bars: [DailySmoothProgress] = []
        for dayOffset in stride(from: 6, through: 0, by: -1) {
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                continue
            }
            
            let label = day.formatted(.dateTime.weekday(.abbreviated))
            bars.append(
                DailySmoothProgress(
                    date: day,
                    dayLabel: label,
                    smoothCount: smoothPerDay[day, default: 0]
                )
            )
        }
        
        weeklyProgress = bars
        smoothThisWeek = bars.reduce(0) { $0 + $1.smoothCount }
        totalPracticeSeconds = sessions.reduce(0) { $0 + $1.durationSeconds }
        streakDays = calculateStreakDays(from: sessions, calendar: calendar, today: today)
        recentSessions = Array(
            sessions.sorted { $0.date > $1.date }
                .prefix(5)
        )
    }
    
    var totalPracticeLabel: String {
        let hours = totalPracticeSeconds / 3600
        let minutes = (totalPracticeSeconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
    
    
    
    private func calculateStreakDays(from sessions: [PracticeSession], calendar: Calendar, today: Date) -> Int {
        let practicedDays = Set(sessions.map { calendar.startOfDay(for: $0.date) })
        
        var streak = 0
        var cursor = today
        
        while practicedDays.contains(cursor) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }
            cursor = previousDay
        }
        
        return streak
    }
}
