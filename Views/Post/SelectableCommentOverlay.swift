import SwiftUI

struct SelectableCommentOverlay: View {
    @EnvironmentObject var appStateManager: AppStateManager
    @State var dragOffset: CGFloat = .zero
    
    func hide() -> Void {
        appStateManager.showingTextSheet = false
    }
    
    var body: some View {
        GeometryReader { geometry in
            if appStateManager.showingTextSheet {
                SwipeableOverlayView(dragOffset: $dragOffset, geometry: geometry, onDismiss: hide, onBackgroundTap: hide, backgroundOpacity: 0.75) {
                    ZStack {
                        Color.clear
                            .frame(maxHeight: .infinity)
                        SelectableCommentView()
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

//#Preview {
//    SelectableCommentOverlay()
//}
