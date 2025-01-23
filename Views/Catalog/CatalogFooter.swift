import SwiftUI

struct CatalogFooter: View {
    
    @EnvironmentObject var inlineViewModel: InlineViewModel
    
    let viewModel: PostRowViewModel
    
    var body: some View {
        let thread = viewModel.thread
        let post = viewModel.post
        Button(action: {
            inlineViewModel.showRecent(thread: thread, post: post)
        }) {
            if let replies = post.replies, let images = post.images {
                HStack(spacing: 7) {
                    HStack(spacing: 5) {
                        Text(String(replies))
                        Image(systemName: "ellipsis.message")
                        Text(String(images))
                        Image(systemName: "photo.on.rectangle.angled")
                    }
                    Text("-")
                    Text("View recent replies")
                }
                    .font(Font.system(size: 16))
                    .foregroundColor(Color.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 12)
                    .contentShape(Rectangle())
            }
        }
    }
}
