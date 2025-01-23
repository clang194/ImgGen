import SwiftUI

struct HistoryView: View {
    
    @EnvironmentObject var router: Router
    @ObservedObject var viewModel = HistoryManager.shared
    
    @State var showingClearAlert: Bool = false
    @State private var expandedSections: [String: Bool] = [:]
    
    var body: some View {
        ScrollViewReader { scrollView in
            //ScrollView {
                List {
//                    SearchBar(searchText: $searchText)
                    ForEach(viewModel.historyThreads.indices, id: \.self) { index in
                        let thread = viewModel.historyThreads[index]
                        let post = thread.posts.first
                        if let post = post {
                            VStack {
                                CompactPostRowView(viewModel: PostRowViewModel(thread: thread, post: post, router: router))
                                    .id(post.no)
                                Divider()
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 10) // choose the corner radius value you want
//                                        .stroke((highlightedIndex == index) ? Color.yellow.opacity(0.5) : Color.clear, lineWidth: (highlightedIndex == index) ? 6 : 0)
//                                )
//                                .animation(.easeInOut(duration: 1), value: highlightedIndex)
                        }
                    }
                }
                .listStyle(.plain)
                .padding(.horizontal, 10)
                .navigationBarTitle("History")
        }
    }
}

struct HistoryListView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
