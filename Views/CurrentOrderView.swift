import SwiftUI

struct CurrentOrderView: View {
    let order: Order
    let onComplete: () -> Void
    
    @State private var timeRemaining: TimeInterval = 900 // 15 минут
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Заказ №\(order.id)")
                .font(.title)
            
            GroupBox("Информация о заказе") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Адрес: \(order.address)")
                    Text("Клиент: \(order.firstName) \(order.lastName ?? "")")
                    Text("Телефон: \(order.phone)")
                    if let comment = order.comment {
                        Text("Комментарий: \(comment)")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            GroupBox("Состав заказа") {
                ForEach(order.products) { product in
                    HStack {
                        Text("\(product.formattedCount)x")
                        Text("Товар #\(product.productId)")
                        Spacer()
                        Text("\(Utils.formatPrice(product.price)) ₸")
                    }
                }
            }
            
            Spacer()
            
            if timeRemaining > 0 {
                Text("До возможности завершения: \(Int(timeRemaining)) сек.")
                    .foregroundColor(.secondary)
            } else {
                Button(action: onComplete) {
                    Text("Завершить доставку")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
    }
}
