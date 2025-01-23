import Foundation
import SwiftUI

class SubscriptionViewModel: ObservableObject {
    @Published var subscriptions: [Subscription] = []
    
    private let userDefaults = UserDefaults.standard
    private let subscriptionsKey = "savedSubscriptions"
    
    init() {
        loadSubscriptions()
    }
    
    func addSubscription(name: String, monthlyCost: Double, startDate: Date, nextPaymentDate: Date) {
        let newSubscription = Subscription(
            name: name,
            monthlyCost: monthlyCost,
            startDate: startDate,
            nextPaymentDate: nextPaymentDate
        )
        subscriptions.append(newSubscription)
        saveSubscriptions()
    }
    
    func cancelSubscription(_ subscription: Subscription) {
        if let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) {
            var updatedSubscription = subscription
            updatedSubscription.isActive = false
            updatedSubscription.cancellationDate = Date()
            subscriptions[index] = updatedSubscription
            saveSubscriptions()
        }
    }
    
    func getActiveSubscriptions() -> [Subscription] {
        return subscriptions.filter { $0.isActive }
    }
    
    func getInactiveSubscriptions() -> [Subscription] {
        return subscriptions.filter { !$0.isActive }
    }
    
    func getTotalMonthlyCost() -> Double {
        return getActiveSubscriptions()
            .reduce(0) { $0 + $1.monthlyCost }
    }
    
    private func saveSubscriptions() {
        if let encoded = try? JSONEncoder().encode(subscriptions) {
            userDefaults.set(encoded, forKey: subscriptionsKey)
        }
    }
    
    private func loadSubscriptions() {
        if let data = userDefaults.data(forKey: subscriptionsKey),
           let decoded = try? JSONDecoder().decode([Subscription].self, from: data) {
            subscriptions = decoded
        }
    }
}
