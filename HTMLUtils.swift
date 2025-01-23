import Foundation
import SwiftSoup

func decodeHTMLEntities(in html: String) -> String {
    do {
        let decoded = try Entities.unescape(html)
        return decoded
    } catch Exception.Error(_, let message) {
        print(message)
    } catch {
        AppLogger.error("Failed to decode HTML entities")
    }
    return html
}
