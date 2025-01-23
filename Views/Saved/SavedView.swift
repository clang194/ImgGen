import SwiftUI

struct SavedView: View {
    
    @EnvironmentObject var router: Router
    @ObservedObject var viewModel = SavedViewModel.shared //todo shared
    
    @State var showingClearAlert: Bool = false
    @State private var expandedSections: [String: Bool] = [:]
    
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                LazyVStack(spacing: 8){
//                    SearchBar(searchText: $searchText)
                    ForEach(viewModel.savedThreads.indices, id: \.self) { index in
                        let thread = viewModel.savedThreads[index]
                        let post = thread.posts.first
                        if let post = post {
                            CatalogRowView(viewModel: PostRowViewModel(thread: thread, post: post, router: router))
                                .id(post.no)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 10) // choose the corner radius value you want
//                                        .stroke((highlightedIndex == index) ? Color.yellow.opacity(0.5) : Color.clear, lineWidth: (highlightedIndex == index) ? 6 : 0)
//                                )
//                                .animation(.easeInOut(duration: 1), value: highlightedIndex)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .navigationBarTitle("Bookmarks")
        }
    }
}

//struct HistoryListView_Previews: PreviewProvider {
//    static var previews: some View {
//        HistoryView()
//    }
//}
