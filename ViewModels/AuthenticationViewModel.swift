import Foundation
import FirebaseAuth
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var phoneNumber = ""
    @Published var verificationCode = ""
    @Published var verificationId: String?
    @Published var isAuthenticated = false
    @Published var error: Error?
    @Published var isLoading = false
    
    func sendVerificationCode() {
        isLoading = true
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.error = error
                    return
                }
                self?.verificationId = verificationID
            }
        }
    }
    
    func verifyCode() {
        guard let verificationId = verificationId else { return }
        isLoading = true
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationId,
            verificationCode: verificationCode
        )
        
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.error = error
                    return
                }
                self?.isAuthenticated = true
            }
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        isAuthenticated = false
    }
}
