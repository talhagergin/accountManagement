import Foundation

class PasswordManager {
    private static let passwordKey = "app_password"
    private static let isFirstLaunchKey = "is_first_launch"
    private static let isPasswordEnabledKey = "is_password_enabled"
    
    static let shared = PasswordManager()
    private let userDefaults = UserDefaults.standard
    
    private init() {
        if !userDefaults.bool(forKey: Self.isFirstLaunchKey) {
            setPassword("1234")
            setPasswordEnabled(true)
            userDefaults.set(true, forKey: Self.isFirstLaunchKey)
        }
    }
    
    func validatePassword(_ password: String) -> Bool {
        return password == getPassword()
    }
    
    func setPassword(_ password: String) {
        userDefaults.set(password, forKey: Self.passwordKey)
    }
    
    func isPasswordEnabled() -> Bool {
        return userDefaults.bool(forKey: Self.isPasswordEnabledKey)
    }
    
    func setPasswordEnabled(_ enabled: Bool) {
        userDefaults.set(enabled, forKey: Self.isPasswordEnabledKey)
    }
    
    private func getPassword() -> String {
        return userDefaults.string(forKey: Self.passwordKey) ?? "1234"
    }
}
