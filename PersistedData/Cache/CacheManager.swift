import Foundation

class CacheManager {
    private let memoryCache: MemoryCache
    private let diskCache: DiskCache

    init() {
        self.memoryCache = MemoryCache()
        self.diskCache = DiskCache()
    }

    func store(data: Data, for url: URL) throws {
        self.memoryCache.store(data: data, for: url)
        try self.diskCache.store(data: data, for: url)
    }

    func retrieveData(for url: URL) throws -> Data? {
        if let data = memoryCache.retrieveData(for: url) {
            return data
        } else if let data = try diskCache.retrieveData(for: url) {
            // Also add to memory cache for next time
            memoryCache.store(data: data, for: url)
            return data
        } else {
            return nil
        }
    }

    func localUrl(for remoteURL: URL) throws -> URL {
        let localURL = diskCache.url(for: remoteURL)
        return localURL
    }

    func removeData(for url: URL) throws {
        self.memoryCache.removeData(for: url)
        try self.diskCache.removeData(for: url)
    }

    func removeAll() throws {
        self.memoryCache.removeAll()
        try self.diskCache.removeAll()
    }
    
    func isCached(url: URL) -> Bool {
        return memoryCache.isCached(url: url) || diskCache.isCached(url: url)
    }
}
