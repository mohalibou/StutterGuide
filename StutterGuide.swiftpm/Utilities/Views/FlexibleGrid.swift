import SwiftUI

struct FlexibleGrid<Content: View>: View {
    var columns: Int
    var spacing: CGFloat
    @ViewBuilder let content: Content
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns), spacing: spacing) {
            content
        }
    }
}
