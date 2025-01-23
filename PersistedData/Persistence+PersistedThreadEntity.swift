import Foundation
import CoreData

extension PersistentThreadEntity {

    func load(from thread: ThreadModel) {
        self.id = Int64(thread.id)
        self.board = thread.boardName
        self.lastScrollIndex = Int64(thread.lastScrollIndex)
        self.lastOpened = thread.lastOpened
        self.hiddenPostIds = NSSet(array: thread.hiddenPostIds.map { no in
            let postIdentifier = PostIdentifierEntity(context: self.managedObjectContext!)
            postIdentifier.no = Int64(no)
            return postIdentifier
        })
        self.seenPostIds = NSSet(array: thread.seenPostIds.map { no in
            let postIdentifier = PostIdentifierEntity(context: self.managedObjectContext!)
            postIdentifier.no = Int64(no)
            return postIdentifier
        })
        self.savedTime = thread.savedTime

        for post in thread.posts {
            let fetchRequest: NSFetchRequest<PostEntity> = NSFetchRequest(entityName: "PostEntity")
            fetchRequest.predicate = NSPredicate(format: "no == %d", post.no)

            do {
                let results = try self.managedObjectContext?.fetch(fetchRequest)
                if let existingPost = results?.first {
                    existingPost.load(from: post)
                } else {
                    // Check if postEntity already exists in PersistentThreadEntity's posts before inserting a new one
                    if let postsSet = self.posts as? Set<PostEntity>, !postsSet.contains(where: { $0.no == post.no }) {
                        let postEntity = NSEntityDescription.insertNewObject(forEntityName: "PostEntity", into: self.managedObjectContext!) as! PostEntity
                        postEntity.load(from: post)
                        self.addToPosts(postEntity)
                    }
                }
            } catch {
                AppLogger.error("Failed to fetch post: \(error)")
            }
        }

    }
    
    func toPersistentThread() -> ThreadModel {
        let thread = ThreadModel(boardName: self.board ?? "") //reimplement ""
        thread.lastScrollIndex = Int(self.lastScrollIndex)
        thread.lastOpened = self.lastOpened
        thread.hiddenPostIds = Set(self.hiddenPostIds?.compactMap { Int(($0 as? PostIdentifierEntity)?.no ?? 0) } ?? [])
        thread.seenPostIds = Set(seenPostIds?.compactMap { Int(($0 as? PostIdentifierEntity)?.no ?? 0) } ?? [])
        thread.savedTime = self.savedTime
        if let posts = self.posts as? Set<PostEntity> {
            thread.posts = posts.sorted(by: { $0.no < $1.no }).map { $0.toPost() }
        }
        return thread
    }
}

extension Persistence { //Thread
    
    func getThread(board: String, id: Int64) -> ThreadModel? {
        let fetchRequest: NSFetchRequest<PersistentThreadEntity> = NSFetchRequest(entityName: "PersistentThreadEntity")
        fetchRequest.predicate = NSPredicate(format: "board == %@ AND id == %d", board, id)
        
        do {
            let results = try self.context.fetch(fetchRequest)
            guard let entity = results.first else { return nil }
            return entity.toPersistentThread()
        } catch {
            AppLogger.error("Failed to fetch thread: \(error)")
            return nil
        }
    }
    
    func saveThread(thread: ThreadModel) {
        // First, attempt to fetch any existing threads with the same ID
        let fetchRequest: NSFetchRequest<PersistentThreadEntity> = NSFetchRequest(entityName: "PersistentThreadEntity")
        fetchRequest.predicate = NSPredicate(format: "board == %@ AND id == %d", thread.boardName, thread.id)

        do {
            let results = try self.context.fetch(fetchRequest)
            if let existingThread = results.first {
                //print("updated properties")
                // If an existing thread was found, update its properties instead of creating a new object
                existingThread.load(from: thread)
            } else {
                // If no existing thread was found, insert a new one
                let threadEntity = NSEntityDescription.insertNewObject(forEntityName: "PersistentThreadEntity", into: self.context) as! PersistentThreadEntity
                threadEntity.load(from: thread)
            }

            self.save()
        } catch {
            AppLogger.error("Failed to fetch thread: \(error)")
        }
    }
    
    func removeThread(id: Int64, board: String) {
        let fetchRequest: NSFetchRequest<PersistentThreadEntity> = NSFetchRequest(entityName: "PersistentThreadEntity")
        fetchRequest.predicate = NSPredicate(format: "board == %@ AND id == %d", board, id)
        
        do {
            let results = try self.context.fetch(fetchRequest)
            for entity in results {
                self.context.delete(entity)
            }
            try self.context.save()
        } catch {
            AppLogger.error("Failed to delete thread: \(error)")
        }
    }
    
    func clearThreads() {
        let fetchRequest: NSFetchRequest<PersistentThreadEntity> = PersistentThreadEntity.fetchRequest()
        clear(request: fetchRequest, context: self.context)
        self.save()
    }
    
    // Clear any entity in a general way
    func clear<Entity: NSManagedObject>(request: NSFetchRequest<Entity>, context: NSManagedObjectContext) {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try context.execute(deleteRequest)
        } catch {
            AppLogger.error("Failed to clear Entity: \(error)")
        }
    }
}

//MODIFIERS
extension Persistence {
    func addPost(board: String, id: Int, post: Post) {
        //print("marking seen8")
        let persistentThread = getThread(board: board, id: Int64(id))
        if let thread = persistentThread {
            if let i = thread.posts.firstIndex(of: post) {
                thread.posts.insert(post, at: i)
            } else {
                thread.posts.append(post)
            }
            Persistence.shared.saveThread(thread: thread)
        }
    }
    
    func markPostAsSeen(board: String, id: Int, postId: Int) {
        //print("marking seen7")
        let persistentThread = getThread(board: board, id: Int64(id))
        if let thread = persistentThread {
            thread.seenPostIds.insert(postId)
            Persistence.shared.saveThread(thread: thread)
        }
    }
    
    func markPostAsUnseen(board: String, id: Int, postId: Int) {
        //print("marking seen")
        let persistentThread = getThread(board: board, id: Int64(id))
        if let thread = persistentThread {
            thread.seenPostIds.remove(postId)
            Persistence.shared.saveThread(thread: thread)
        }
    }
    
    func markPostAsHidden(board: String, id: Int, postId: Int) {
        //print("marking seen6")
        let persistentThread = getThread(board: board, id: Int64(id))
        if let thread = persistentThread {
            thread.hiddenPostIds.insert(postId)
            Persistence.shared.saveThread(thread: thread)
        }
    }
    
    func markPostAsUnhidden(board: String, id: Int, postId: Int) {
        //print("marking seen5")
        let persistentThread = getThread(board: board, id: Int64(id))
        if let thread = persistentThread {
            thread.hiddenPostIds.remove(postId)
            Persistence.shared.saveThread(thread: thread)
        }
    }
    
    func markThreadAsSaved(board: String, id: Int) {
        //print("marking seen4")
        let persistentThread = getThread(board: board, id: Int64(id))
        if let thread = persistentThread {
            thread.savedTime = .now
            Persistence.shared.saveThread(thread: thread)
        }
    }
    
    func markThreadAsUnsaved(board: String, id: Int) {
        //print("marking seen3")
        let persistentThread = getThread(board: board, id: Int64(id))
        if let thread = persistentThread {
            thread.savedTime = nil
            Persistence.shared.saveThread(thread: thread)
        }
    }
    
    func saveScrollIndex(board: String, id: Int, index: Int) {
        //print("marking seen2")
        let persistentThread = getThread(board: board, id: Int64(id))
        if let thread = persistentThread {
            thread.lastScrollIndex = index
            Persistence.shared.saveThread(thread: thread)
        }
    }
    
    func saveLastOpened(board: String, id: Int, date: Date) {
        //print("marking seen1")
        let persistentThread = getThread(board: board, id: Int64(id))
        if let thread = persistentThread {
            thread.lastOpened = date
            Persistence.shared.saveThread(thread: thread)
        }
    }
    
}

