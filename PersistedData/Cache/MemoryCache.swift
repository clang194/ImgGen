import Foundation

class MemoryCache {
    private let cache: NSCache<NSURL, NSData>

    init() {
        self.cache = NSCache<NSURL, NSData>()
    }

    func store(data: Data, for url: URL) {
        self.cache.setObject(data as NSData, forKey: url as NSURL)
    }

    func retrieveData(for url: URL) -> Data? {
        return self.cache.object(forKey: url as NSURL) as Data?
    }

    func isCached(url: URL) -> Bool {
        return self.cache.object(forKey: url as NSURL) != nil
    }

    func removeData(for url: URL) {
        self.cache.removeObject(forKey: url as NSURL)
    }

    func removeAll() {
        self.cache.removeAllObjects()
    }
}
