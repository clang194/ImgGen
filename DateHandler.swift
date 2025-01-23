import Foundation

class DateHandler {
    
    static func formatAsMMMMddyyyy(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
    
    static func formatHistoryElement(from date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.second, .minute, .hour, .day, .month, .year], from: date, to: now)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        
        if let days = components.day, days >= 1 {
            return dateFormatter.string(from: date)
        } else {
            return timeFormatter.string(from: date) + " today"
        }
    }
    
    static func formatPostElement(from unixTimestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: unixTimestamp)
        let now = Date()
        let components = Calendar.current.dateComponents([.second, .minute, .hour, .day, .month, .year], from: date, to: now)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"

        if let days = components.day, days >= 1 {
            return dateFormatter.string(from: date)
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "\(hours) hour ago" : "\(hours) hours ago"
        } else if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "\(minutes) minute ago" : "\(minutes) minutes ago"
        } else if let seconds = components.second, seconds > 0 {
            return seconds == 1 ? "\(seconds) second ago" : "\(seconds) seconds ago"
        } else {
            return "Just now"
        }
    }
}
