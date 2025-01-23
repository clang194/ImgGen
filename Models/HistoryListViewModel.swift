import Foundation
import Combine

class HistoryViewModel: ObservableObject {
    
    @Published var threads: [Thread] = []
    //@Published var groupedThreads: [String: [Thread]] = [:]
    @Published var filteredGroupedThreads: [String: [Thread]] = [:]
    @Published var state: State = State.initial
    @Published var groupType = GroupingType.byDate
    private var cancellables = Set<AnyCancellable>()
    let dateFormatter = DateFormatter()
    
    @Published var searchText: String = ""
    
    enum State {
        case initial, loading, loaded, error
    }
    
    enum GroupingType {
        case byDate, byBoard
    }

    enum SortingType {
        case ascending, descending
    }
    
    init() {
        ThreadHistoryManager.shared.$updated.sink { [weak self] _ in
            self?.updateHistory()
        }.store(in: &cancellables)
        
        Publishers.CombineLatest($threads, $searchText)
            .map { (threads, searchText) in
                let grouped = self.groupThreads(threads)
                let filtered = self.filterGroupedThreads(grouped, searchText: searchText)
                return filtered
            }
            .assign(to: &$filteredGroupedThreads)
    }
    
    func updateHistory() {
        self.loadHistoryThreads()
    }
    
    private func filterGroupedThreads(_ groupedThreads: [String: [Thread]], searchText: String) -> [String: [Thread]] {
        return applyFilters(to: groupedThreads, searchText: searchText)
    }
    
    func applyFilters(to groupedThreads: [String: [Thread]], searchText: String) -> [String: [Thread]] {
        var filteredThreads: [String: [Thread]] = [:]

        for (key, threads) in groupedThreads {
            let filtered = threads.filter { thread in
                if let op = thread.op {
                    return op.contains(searchText)
                } else {
                    return false
                }
            }

            if !filtered.isEmpty {
                filteredThreads[key] = filtered
            }
        }

        return filteredThreads
    }

    
    func sortByDate() -> [String: [Thread]]{
        let sortedObjects = threads.sorted { $0.op?.time ?? 0 > $1.op?.time ?? 0 }
        return Dictionary(grouping: sortedObjects) { thread in
            return DateHandler.formatAsYyyyMmDd(from: Double(thread.op?.time ?? 0))
        }
    }
    
    func sortByBoard() -> [String: [Thread]] {
        let sortedObjects = threads.sorted { $0.boardName < $1.boardName }
        return Dictionary(grouping: sortedObjects) { object in
            return String(object.boardName)
        }
    }
    
    func groupThreads(_ threads: [Thread]) -> [String: [Thread]] {
        switch groupType {
        case .byDate:
            return sortByDate()
        case .byBoard:
            return sortByBoard()
        }
    }
    
    func loadHistoryThreads() {
        self.state = .loading
        print(self.state)
        
        ThreadHistoryManager.shared.loadVisitedThreads { result in
            switch result {
            case .success(let threads):
                print("sucess")
                self.threads = threads
                self.state = .loaded
                print("threads \(threads)")
            case .failure(let error):
                print("Error loading saved threads: \(error)")
                self.state = .error
            }
        }
    }
}
