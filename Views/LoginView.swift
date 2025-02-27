import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.verificationId == nil {
                    // Экран ввода номера телефона
                    TextField("Номер телефона", text: $viewModel.phoneNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.phonePad)
                    
                    Button("Получить код") {
                        viewModel.sendVerificationCode()
                    }
                    .disabled(viewModel.phoneNumber.isEmpty || viewModel.isLoading)
                } else {
                    // Экран ввода кода
                    TextField("Код из SMS", text: $viewModel.verificationCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                    
                    Button("Войти") {
                        viewModel.verifyCode()
                    }
                    .disabled(viewModel.verificationCode.isEmpty || viewModel.isLoading)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                }
                
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .navigationTitle("Вход для курьера")
        }
    }
}
