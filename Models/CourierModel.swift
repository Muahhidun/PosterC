import Foundation
import FirebaseFirestoreSwift

struct Courier: Codable, Identifiable {
    @DocumentID var id: String?
    let phoneNumber: String
    var isAvailable: Bool
    var currentOrderId: Int?
    var lastOrderCompletionTime: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case phoneNumber = "phone_number"
        case isAvailable = "is_available"
        case currentOrderId = "current_order_id"
        case lastOrderCompletionTime = "last_order_completion_time"
    }
}
