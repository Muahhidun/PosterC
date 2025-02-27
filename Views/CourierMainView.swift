import SwiftUI

struct CourierMainView: View {
    @StateObject private var viewModel = CourierViewModel()
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if let currentOrder = viewModel.currentOrder {
                    // Экран текущего заказа
                    CurrentOrderView(order: currentOrder, onComplete: {
                        viewModel.completeOrder()
                    })
                } else {
                    // Список доступных заказов
                    List(viewModel.availableOrders) { order in
                        OrderCell(order: order) {
                            viewModel.acceptOrder(order)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.currentOrder != nil ? "Текущий заказ" : "Доступные заказы")
            .toolbar {
                Button("Выйти") {
                    authViewModel.signOut()
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert("Ошибка", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
        }
        .onAppear {
            viewModel.startListening()
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
}

struct OrderCell: View {
    let order: Order
    let onAccept: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Заказ №\(order.id)")
                .font(.headline)
            Text(order.address)
                .font(.subheadline)
            
            Button("Принять заказ") {
                onAccept()
            }
            .padding(.top)
        }
        .padding()
    }
}
