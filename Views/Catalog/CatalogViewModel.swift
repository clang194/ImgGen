import Foundation
import SwiftUI

enum CatalogSortType {
    case datePosted
    case lastReplied
    case replyCount
    case imageCount
}

final class CatalogViewModel: ObservableObject {
    
    @Published var scrollToIndex: Int?
    @Published var threadState: ThreadState = .initial
    @Published var searchText: String = ""
    @Published var sortType: CatalogSortType = .lastReplied
    @Published var isAscending: Bool = false
    var board: String

    @Published var thread = ThreadModel()
    
    var filteredThread: ThreadModel {
        var posts = thread.posts
        
        if !searchText.isEmpty {
            posts.removeAll { !ContentFilter.contains(searchText, in: $0) }
        }
        
        switch sortType {
        case .datePosted:
            posts.sort {
                return $0.time > $1.time
            }
        case .lastReplied:
            posts.sort {
                let time0 = $0.last_replies?.last?.time ?? $0.time
                let time1 = $1.last_replies?.last?.time ?? $1.time
                return time0 > time1
            }
        case .replyCount:
            posts.sort {
                return $0.replies ?? 0 > $1.replies ?? 0
            }
        case .imageCount:
            posts.sort {
                return $0.images ?? 0 > $1.images ?? 0
            }
        }
        
        if isAscending {
            posts.reverse()
        }
        
        let filteredThread = ThreadModel(boardName: thread.boardName, posts: posts)
        return filteredThread
    }
    
    private var visiblePostIds = Set<Int>()
    
    init(board: String) {
        self.board = board
    }
    
    func reset(with board: String) {
        self.board = board
        self.threadState = .initial
    }
    
    @MainActor
    func loadThread() async {
        if case .loaded = threadState {
        } else {
            self.threadState = .loading
        }
        do {
            let fetchedThread = try await ChanAPI.fetchThreadOps(board: board)
            self.thread = fetchedThread
            self.threadState = .loaded(thread: fetchedThread)
        } catch {
            AppLogger.error("Failed to load thread: \(error)")
            self.threadState = .error(error: error)
        }
    }
}
