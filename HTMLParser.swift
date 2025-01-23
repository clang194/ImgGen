import Foundation
import SwiftSoup
import SwiftUI

class HTMLParser {
    var comment: String

    init(comment: String) {
        self.comment = comment
    }
    
    enum DecodedLink {
        case reply(id: Int)
        case thread(board: String, id: Int)
        case catalog(board: String, searchTerm: String)
        case normal
    }
    
    func parseHTML() throws -> AttributedString {
        let cleanedComment = comment.replacingOccurrences(of: "<wbr>", with: "")
        let document = try SwiftSoup.parseBodyFragment(cleanedComment)
        let body = document.body()
        var attributedString = AttributedString()
        if let body = body {
            addElement(body, to: &attributedString)
        }
        return attributedString
    }
    
    private func addElement(_ element: Element, to attributedString: inout AttributedString) {
        for child in element.childNodesCopy() {
            if let childElement = child as? Element {
                if childElement.tagName().lowercased() == "br" {
                    attributedString.append(AttributedString("\n"))
                } else {
                    addElement(childElement, to: &attributedString)
                }
            } else if let textNode = child as? TextNode, !textNode.isBlank() {
                let text = textNode.text()
                var attributedText = AttributedString(text)
                let urlPattern = #"(http|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?"#
                let urlRegex = try! NSRegularExpression(pattern: urlPattern)
                let urlRange = NSRange(text.startIndex..<text.endIndex, in: text)
                let matches = urlRegex.matches(in: text, options: [], range: urlRange)

                if !matches.isEmpty {
                    let match = matches.first!
                    let urlNSRange = match.range
                    let urlRange = Range(urlNSRange, in: text)!
                    let urlString = String(text[urlRange])

                    let markdownString = "[\(urlString)](\(urlString))"
                    attributedText = try! AttributedString(markdown: markdownString)
                    attributedText.underlineStyle = .single
                    attributedString.append(attributedText)
                } else {
                    let text = textNode.text()
                    var attributedText = AttributedString(text)

                    switch element.tagName().lowercased() {
                    case "b":
                        attributedText.inlinePresentationIntent = .stronglyEmphasized
                    case "i":
                        attributedText.inlinePresentationIntent = .emphasized
                    case "span":
                        attributedText.foregroundColor = Color("Default Scheme/Greentext")
                    case "a":
                        let href: String = try! element.attr("href")
                        do {
                            let decodedLink = try decodeHref(href: href)
                            switch decodedLink {
                            case .reply(let id):
                                let modifiedUrlString = "dango://reply/\(id)"
                                let markdownString = "[\(text)](\(modifiedUrlString))"
                                attributedText = try! AttributedString(markdown: markdownString)
                                attributedText.foregroundColor = Color.blue
                                attributedText.underlineStyle = .single
                            case .thread(let board, let id):
                                let modifiedUrlString = "dango://thread/\(board)/\(id)"
                                let markdownString = "[\(text)](\(modifiedUrlString))"
                                attributedText = try! AttributedString(markdown: markdownString)
                                attributedText.foregroundColor = Color.red
                                attributedText.underlineStyle = .single
                            case .catalog(let board, let searchTerm):
                                let modifiedUrlString = "dango://catalog/\(board)/\(searchTerm)"
                                let markdownString = "[\(text)](\(modifiedUrlString))"
                                attributedText = try! AttributedString(markdown: markdownString)
                                attributedText.foregroundColor = Color.red
                                attributedText.underlineStyle = .single
                            default:
                                break
                            }
                        } catch {
                            AppLogger.error("Failed to decode URL")
                        }
                        
                    default:
                        attributedText.font = UIFont.systemFont(ofSize: 16)
                        attributedText.foregroundColor = Color.primary
                    }
                    attributedText.font = UIFont.systemFont(ofSize: 16)
                    attributedString.append(attributedText)
                }
            }
            if (try? element.nextElementSibling()) != nil {
                attributedString.append(AttributedString("\n"))
            }
        }
    }
        
    func decodeHref(href: String) throws -> DecodedLink {
        let decodedHref = href.removingPercentEncoding ?? ""
        let replyRegex = try NSRegularExpression(pattern: "^#p(\\d+)$")
        let threadRegex = try NSRegularExpression(pattern: "/(\\w+)/thread/(\\d+)")
        let boardRegex = try NSRegularExpression(pattern: "//boards\\.4chan\\.org/(\\w+)/")
        let catalogSearchRegex = try NSRegularExpression(pattern: "//boards\\.4channel\\.org/(\\w+)/catalog#s=(\\w+)")
        
        if let threadMatch = threadRegex.firstMatch(in: decodedHref, options: [], range: NSRange(location: 0, length: decodedHref.count)) {
            //thread link
            let boardRange = Range(threadMatch.range(at: 1), in: decodedHref)!
            let idRange = Range(threadMatch.range(at: 2), in: decodedHref)!
            let board = String(decodedHref[boardRange])
            let id = Int(decodedHref[idRange])!
            return DecodedLink.thread(board: board, id: id)
        } else if let boardMatch = boardRegex.firstMatch(in: decodedHref, options: [], range: NSRange(location: 0, length: decodedHref.count)) {
            //board link
            let boardRange = Range(boardMatch.range(at: 1), in: decodedHref)!
            let board = String(decodedHref[boardRange])
            return DecodedLink.catalog(board: board, searchTerm: "")
        } else if let replyMatch = replyRegex.firstMatch(in: decodedHref, options: [], range: NSRange(location: 0, length: decodedHref.count)) {
            //reply link
            let idRange = Range(replyMatch.range(at: 1), in: decodedHref)!
            let id = Int(decodedHref[idRange])!
            return DecodedLink.reply(id: id)
        } else if let catalogMatch = catalogSearchRegex.firstMatch(in: decodedHref, options: [], range: NSRange(location: 0, length: decodedHref.count)) {
            //catalog search link
            let boardRange = Range(catalogMatch.range(at: 1), in: decodedHref)!
            let searchTermRange = Range(catalogMatch.range(at: 2), in: decodedHref)!
            let board = String(decodedHref[boardRange])
            let searchTerm = String(decodedHref[searchTermRange])
            return DecodedLink.catalog(board: board, searchTerm: searchTerm)
        } else {
            return DecodedLink.normal
        }
    }
}
