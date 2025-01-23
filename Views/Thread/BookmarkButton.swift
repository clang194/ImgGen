import SwiftUI

struct BookmarkButton: View {
    
    @ObservedObject var viewModel: ThreadViewModel
    
    var body: some View {
        
        Button(action: {
            if viewModel.saved {
                viewModel.markUnsaved()
                print("marked unsaved")
            } else {
                viewModel.markSaved()
                print("marked saved")
            }
        }, label: {
            Image(systemName: (viewModel.saved) ? "bookmark.fill" : "bookmark")
        })
    }
}

//#Preview {
//    BookmarkButton()
//}
