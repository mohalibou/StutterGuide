import SwiftUI

struct TipCard: View {
    let title: String
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(AppTheme.primary)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundStyle(AppTheme.text.opacity(0.7))
                
                Text(message)
                    .font(.system(.callout, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.text.opacity(0.75))
            }
        }
        .padding(14)
        .background(AppTheme.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.primary.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        TipCard(
            title: "Practice Tip",
            message: "Read smoothly for success, or try 'the the dog' to see gentle coaching."
        )
        
        TipCard(
            title: "Quick Tip",
            message: "Take deep breaths before you start reading."
        )
    }
    .padding()
    .background(AppTheme.background)
}
