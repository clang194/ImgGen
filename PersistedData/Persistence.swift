import Foundation
import CoreData

final class Persistence {
    static let shared = Persistence()

    lazy var container: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Senkou")

        let storeDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!

        let localDescription = NSPersistentStoreDescription(url: storeDirectory.appendingPathComponent("Local.sqlite"))
        localDescription.configuration = "Local"
        localDescription.shouldMigrateStoreAutomatically = true
        localDescription.shouldInferMappingModelAutomatically = true
        
        container.persistentStoreDescriptions = [localDescription]

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                AppLogger.error("Error loading persistent stores \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    func save() {
//        if context.hasChanges {
//            // Log inserted objects
//            for object in context.insertedObjects {
//                print("Inserted object: \(object)")
//            }
//
//            // Log updated objects
//            for object in context.updatedObjects {
//                print("Updated object: \(object)")
//            }
//
//            // Log deleted objects
//            for object in context.deletedObjects {
//                print("Deleted object: \(object)")
//            }
//            
//            do {
//                try context.save()
//                print("Successfully saved viewContext.")
//            } catch {
//                print("Failed to save viewContext: \(error.localizedDescription)")
//                AppLogger.error("Failed to save viewContext: \(error.localizedDescription)")
//            }
//        }
        
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context // Assuming `mainContext` is your main thread context

        backgroundContext.perform {
            // Make changes to the background context here, if needed

            do {
                try backgroundContext.save()
                self.context.performAndWait {
                    do {
                        try self.context.save()
                    } catch {
                        print("Failed to save mainContext: \(error.localizedDescription)")
                    }
                }
            } catch {
                print("Failed to save backgroundContext: \(error.localizedDescription)")
            }
        }
    }
    
    func remove(_ object: NSManagedObject) {
        container.performBackgroundTask { context in
            let object = context.object(with: object.objectID)
            context.delete(object)
        }
    }

    func clear<T: NSManagedObject>(request: NSFetchRequest<T>, context: NSManagedObjectContext? = nil) {
        let context = context ?? self.context
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: (request as? NSFetchRequest<NSFetchRequestResult>)!)
        do {
            _ = try context.execute(deleteRequest)
        } catch {
            AppLogger.error("CoreDataManager.clear: \(error.localizedDescription)")
        }
    }
    
    func deletePersistentStore() {
        let storeDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let localUrl = storeDirectory.appendingPathComponent("Local.sqlite")

        do {
            try FileManager.default.removeItem(at: localUrl)
            print("Persistent Store successfully deleted.")
        } catch {
            print("Failed to delete Persistent Store: \(error.localizedDescription)")
            AppLogger.error("Failed to delete Persistent Store: \(error.localizedDescription)")
        }
    }
}
