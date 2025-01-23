import Foundation
import CoreData

class HistoryManager: ObservableObject {
    static let shared = HistoryManager()

    @Published var historyThreads: [ThreadModel] = []
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: nil)
        self.historyThreads = fetchHistoryThreads()
    }
    
    @objc private func contextObjectsDidChange(_ notification: Notification) {
        self.historyThreads = fetchHistoryThreads()
    }
    
    func fetchHistoryThreads() -> [ThreadModel] {
        let fetchRequest: NSFetchRequest<PersistentThreadEntity> = PersistentThreadEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "lastOpened != NULL")
        
        do {
            let results = try Persistence.shared.context.fetch(fetchRequest)
            return results.map { $0.toPersistentThread() }
        } catch {
            AppLogger.error("Failed to fetch viewed threads: \(error)")
            return []
        }
    }
}
