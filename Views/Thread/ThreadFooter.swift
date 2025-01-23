import SwiftUI

struct ThreadFooter: View {
    
    @EnvironmentObject var threadViewModel: ThreadViewModel
    @EnvironmentObject var inlineViewModel: InlineViewModel
    
    let viewModel: PostRowViewModel
    
    var body: some View {
        let thread = viewModel.thread
        let post = viewModel.post
        if let replies = thread.replies[post.no] {
            let replyCount = replies.count
            Button(action: {
                inlineViewModel.showReplies(thread: thread, to: post)
            }) {
                Text("\(replyCount) \(replyCount == 1 ? "Reply" : "Replies")")
                    .font(Font.system(size: 16))
                    .foregroundColor(Color.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 12)
                    .contentShape(Rectangle())
                    .padding(.bottom, 8)
            }
    }
    }
}
