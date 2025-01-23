import os

class AppLogger {
    private static let logger = Logger(subsystem: "com.yourCompany.yourApp", category: "Default")

    static func info(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }

    static func debug(_ message: String) {
        logger.debug("\(message, privacy: .public)")
    }

    static func error(_ message: String) {
        logger.error("\(message, privacy: .public)")
    }
}
