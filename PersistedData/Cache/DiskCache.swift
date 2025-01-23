import Foundation

class DiskCache {
    private let cacheDirectoryURL: URL

    init() {
        let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        cacheDirectoryURL = URL(fileURLWithPath: cacheDirectory).appendingPathComponent("ImageCache")
        try? FileManager.default.createDirectory(at: cacheDirectoryURL, withIntermediateDirectories: true, attributes: nil)
    }

    func store(data: Data, for url: URL) throws {
        let fileURL = cacheDirectoryURL.appendingPathComponent(url.lastPathComponent)
        try data.write(to: fileURL)
    }

    func retrieveData(for url: URL) throws -> Data? {
        let fileURL = cacheDirectoryURL.appendingPathComponent(url.lastPathComponent)
        return try? Data(contentsOf: fileURL)
    }
    
    func url(for remoteURL: URL) -> URL {
        let localURL = cacheDirectoryURL.appendingPathComponent(remoteURL.lastPathComponent)
        return localURL
    }

    func isCached(url: URL) -> Bool {
        let fileURL = cacheDirectoryURL.appendingPathComponent(url.lastPathComponent)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    func removeData(for url: URL) throws {
        let fileURL = cacheDirectoryURL.appendingPathComponent(url.lastPathComponent)
        try FileManager.default.removeItem(at: fileURL)
    }

    func removeAll() throws {
        try FileManager.default.removeItem(at: cacheDirectoryURL)
        try FileManager.default.createDirectory(at: cacheDirectoryURL, withIntermediateDirectories: true, attributes: nil)
    }
}
