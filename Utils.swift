import Foundation

struct Utils {
    static func formatPrice(_ price: Int) -> String {
        let priceInMainUnit = Double(price) / 100.0
        return String(format: "%.2f", priceInMainUnit)
    }
    
    static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
}
