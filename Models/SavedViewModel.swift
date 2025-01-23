import Foundation
import CoreData

class SavedViewModel: ObservableObject {
    static let shared = SavedViewModel()

    @Published var savedThreads: [ThreadModel] = []
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: nil)
        self.savedThreads = fetchSavedThreads()
    }
    
    @objc private func contextObjectsDidChange(_ notification: Notification) {
        self.savedThreads = fetchSavedThreads()
    }
    
    func fetchSavedThreads() -> [ThreadModel] {
        let fetchRequest: NSFetchRequest<PersistentThreadEntity> = PersistentThreadEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "savedTime != NULL")
        
        do {
            let results = try Persistence.shared.context.fetch(fetchRequest)
            return results.map { $0.toPersistentThread() }
        } catch {
            AppLogger.error("Failed to fetch viewed threads: \(error)")
            return []
        }
    }
}
