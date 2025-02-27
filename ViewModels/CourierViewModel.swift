import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class CourierViewModel: ObservableObject {
    @Published var availableOrders: [Order] = []
    @Published var currentOrder: Order?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    func startListening() {
        guard let userId = userId else { return }
        
        // Слушаем изменения в доступных заказах
        listener = db.collection("orders")
            .whereField("status", isEqualTo: "available")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    self?.error = error
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self?.availableOrders = documents.compactMap { document in
                    try? document.data(as: Order.self)
                }
            }
    }
    
    func acceptOrder(_ order: Order) {
        guard let userId = userId else { return }
        isLoading = true
        
        // Проверяем, не взял ли уже кто-то заказ
        db.collection("orders").document(String(order.id)).getDocument { [weak self] document, error in
            guard let document = document,
                  let order = try? document.data(as: Order.self),
                  order.status == "available" else {
                self?.isLoading = false
                self?.error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Заказ уже взят другим курьером"])
                return
            }
            
            // Обновляем статус заказа
            let batch = self?.db.batch()
            let orderRef = self?.db.collection("orders").document(String(order.id))
            batch?.updateData([
                "status": "in_progress",
                "courier_id": userId,
                "accepted_at": FieldValue.serverTimestamp()
            ], forDocument: orderRef!)
            
            // Обновляем статус курьера
            let courierRef = self?.db.collection("couriers").document(userId)
            batch?.updateData([
                "is_available": false,
                "current_order_id": order.id
            ], forDocument: courierRef!)
            
            batch?.commit { error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.error = error
                    } else {
                        self?.currentOrder = order
                    }
                }
            }
        }
    }
    
    func completeOrder() {
        guard let userId = userId,
              let currentOrder = currentOrder else { return }
        
        // Проверяем прошло ли 15 минут
        guard let acceptedAt = currentOrder.acceptedAt,
              Date().timeIntervalSince(acceptedAt) >= 900 else {
            error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нельзя завершить заказ раньше чем через 15 минут"])
            return
        }
        
        isLoading = true
        
        let batch = db.batch()
        
        // Обновляем статус заказа
        let orderRef = db.collection("orders").document(String(currentOrder.id))
        batch.updateData([
            "status": "completed",
            "completed_at": FieldValue.serverTimestamp()
        ], forDocument: orderRef)
        
        // Обновляем статус курьера
        let courierRef = db.collection("couriers").document(userId)
        batch.updateData([
            "is_available": true,
            "current_order_id": nil,
            "last_order_completion_time": FieldValue.serverTimestamp()
        ], forDocument: courierRef)
        
        batch.commit { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.error = error
                } else {
                    self?.currentOrder = nil
                }
            }
        }
    }
    
    func stopListening() {
        listener?.remove()
    }
}
