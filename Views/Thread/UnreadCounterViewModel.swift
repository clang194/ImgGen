import Foundation

class UnreadCounterViewModel: ObservableObject {
    @Published var seenPostIds: Set<Int> = []
    @Published var totalCount: Int = 0
    
    var unseenCount: Int {
        let seen = seenPostIds.count
        return totalCount - seen
    }
}
