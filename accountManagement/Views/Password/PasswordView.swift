import SwiftUI
import LocalAuthentication
import SwiftData

struct PasswordView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var password = ""
    @State private var isUnlocked = false
    @State private var showError = false
    @State private var showChangePassword = false
    @State private var showEnablePassword = false
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingChangePasswordAlert = false
    @State private var changePasswordAlertMessage = ""
    @State private var showingEnablePasswordAlert = false
    @State private var enablePasswordAlertMessage = ""
    @State private var useBiometrics = false
    @State private var isPasswordEnabled = PasswordManager.shared.isPasswordEnabled()
    
    var body: some View {
        Group {
            if !isPasswordEnabled {
                ContentView(viewModel: TransactionViewModel(modelContext: modelContext))
            } else if isUnlocked {
                ContentView(viewModel: TransactionViewModel(modelContext: modelContext))
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                    
                    Text("Giriş Yapın")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    SecureField("Şifre", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 50)
                        .keyboardType(.numberPad)
                    
                    Button(action: validatePassword) {
                        Text("Giriş")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 50)
                    
                    if showError {
                        Text("Hatalı şifre!")
                            .foregroundColor(.red)
                    }
                    /*
                    if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                        Button(action: authenticateWithBiometrics) {
                            Image(systemName: LAContext().biometryType == .faceID ? "faceid" : "touchid")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        }
                        .padding(.top)
                    }
                    */
                }
            }
        }
        .sheet(isPresented: $showChangePassword) {
            NavigationView {
                Form {
                    Section(header: Text("Mevcut Şifre")) {
                        SecureField("Mevcut Şifre", text: $currentPassword)
                            .keyboardType(.numberPad)
                    }
                    
                    Section(header: Text("Yeni Şifre")) {
                        SecureField("Yeni Şifre", text: $newPassword)
                            .keyboardType(.numberPad)
                        SecureField("Şifreyi Tekrar Girin", text: $confirmPassword)
                            .keyboardType(.numberPad)
                    }
                }
                .navigationTitle("Şifre Değiştir")
                .navigationBarItems(
                    leading: Button("İptal") {
                        resetPasswordFields()
                        showChangePassword = false
                    },
                    trailing: Button("Kaydet") {
                        validateAndChangePassword()
                    }
                )
                .alert(isPresented: $showingChangePasswordAlert) {
                    Alert(
                        title: Text("Hata"),
                        message: Text(changePasswordAlertMessage),
                        dismissButton: .default(Text("Tamam"))
                    )
                }
            }
        }
        .sheet(isPresented: $showEnablePassword) {
            NavigationView {
                Form {
                    Section(header: Text("Yeni Şifre")) {
                        SecureField("Yeni Şifre", text: $newPassword)
                            .keyboardType(.numberPad)
                        SecureField("Şifreyi Tekrar Girin", text: $confirmPassword)
                            .keyboardType(.numberPad)
                    }
                }
                .navigationTitle("Şifre Oluştur")
                .navigationBarItems(
                    leading: Button("İptal") {
                        resetPasswordFields()
                        showEnablePassword = false
                    },
                    trailing: Button("Kaydet") {
                        validateAndEnablePassword()
                    }
                )
                .alert(isPresented: $showingEnablePasswordAlert) {
                    Alert(
                        title: Text("Hata"),
                        message: Text(enablePasswordAlertMessage),
                        dismissButton: .default(Text("Tamam"))
                    )
                }
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Bilgi"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
        }
        .onAppear {
            setupNotifications()
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name("ShowChangePassword"),
            object: nil,
            queue: .main) { _ in
                showChangePassword = true
            }
        
        NotificationCenter.default.addObserver(
            forName: Notification.Name("ShowEnablePassword"),
            object: nil,
            queue: .main) { _ in
                showEnablePassword = true
            }
    }
    
    private func validatePassword() {
        if PasswordManager.shared.validatePassword(password) {
            withAnimation {
                isUnlocked = true
                password = ""
            }
        } else {
            showError = true
            password = ""
        }
    }
    
    private func validateAndChangePassword() {
        if !PasswordManager.shared.validatePassword(currentPassword) {
            changePasswordAlertMessage = "Mevcut şifre yanlış"
            showingChangePasswordAlert = true
            currentPassword = ""
            return
        }
        
        if newPassword.isEmpty {
            changePasswordAlertMessage = "Yeni şifre boş olamaz"
            showingChangePasswordAlert = true
            return
        }
        
        if newPassword != confirmPassword {
            changePasswordAlertMessage = "Şifreler eşleşmiyor"
            showingChangePasswordAlert = true
            newPassword = ""
            confirmPassword = ""
            return
        }
        
        PasswordManager.shared.setPassword(newPassword)
        resetPasswordFields()
        showChangePassword = false
        alertMessage = "Şifre başarıyla değiştirildi"
        showingAlert = true
    }
    
    private func validateAndEnablePassword() {
        if newPassword.isEmpty {
            enablePasswordAlertMessage = "Yeni şifre boş olamaz"
            showingEnablePasswordAlert = true
            return
        }
        
        if newPassword != confirmPassword {
            enablePasswordAlertMessage = "Şifreler eşleşmiyor"
            showingEnablePasswordAlert = true
            newPassword = ""
            confirmPassword = ""
            return
        }
        
        PasswordManager.shared.setPassword(newPassword)
        PasswordManager.shared.setPasswordEnabled(true)
        isPasswordEnabled = true
        resetPasswordFields()
        showEnablePassword = false
        alertMessage = "Şifre koruması aktifleştirildi"
        showingAlert = true
    }
    
    private func resetPasswordFields() {
        currentPassword = ""
        newPassword = ""
        confirmPassword = ""
    }
    
    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Uygulamaya giriş yapmak için kimlik doğrulama gerekli"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if success {
                        withAnimation {
                            isUnlocked = true
                        }
                    }
                }
            }
        }
    }
}
