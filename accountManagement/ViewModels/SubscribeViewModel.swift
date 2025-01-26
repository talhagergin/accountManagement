import Foundation
import SwiftUI
import UserNotifications

class SubscriptionViewModel: ObservableObject {
    @Published var subscriptions: [Subscription] = []
    
    private let userDefaults = UserDefaults.standard
    private let subscriptionsKey = "savedSubscriptions"
    
    init() {
        loadSubscriptions()
        requestNotificationAuthorization()
        scheduleNotificationCheck()
        
    }
    
    func addSubscription(name: String, monthlyCost: Double, startDate: Date, paymentFrequency: PaymentFrequency, paymentCard: PaymentCard? = nil) {
        let nextPaymentDate = calculateNextPaymentDate(startDate: startDate, paymentFrequency: paymentFrequency)
        let newSubscription = Subscription(
            name: name,
            monthlyCost: monthlyCost,
            startDate: startDate,
            nextPaymentDate: nextPaymentDate,
            paymentFrequency: paymentFrequency,
            paymentCard: paymentCard
        )
        subscriptions.append(newSubscription)
        saveSubscriptions()
        checkAndSendNotifications()
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
    
    func reactivateSubscription(_ subscription: Subscription) {
        if let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) {
            var updatedSubscription = subscription
            updatedSubscription.isActive = true
            updatedSubscription.cancellationDate = nil
            updatedSubscription.nextPaymentDate = calculateNextPaymentDate(startDate: updatedSubscription.startDate, paymentFrequency: updatedSubscription.paymentFrequency)

            subscriptions[index] = updatedSubscription
            saveSubscriptions()
        }
    }
    
    func updateSubscription(subscription: Subscription, name: String, monthlyCost: Double, startDate: Date, paymentFrequency: PaymentFrequency, paymentCard: PaymentCard? = nil) {
        if let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) {
            var updatedSubscription = subscription
            updatedSubscription.name = name
            updatedSubscription.monthlyCost = monthlyCost
            updatedSubscription.startDate = startDate
            updatedSubscription.paymentFrequency = paymentFrequency
            updatedSubscription.nextPaymentDate = calculateNextPaymentDate(startDate: startDate, paymentFrequency: paymentFrequency)
            updatedSubscription.paymentCard = paymentCard
            subscriptions[index] = updatedSubscription
            saveSubscriptions()
        }
    }
    
    func deleteSubscription(_ subscription: Subscription){
        subscriptions.removeAll(where: {$0.id == subscription.id})
        saveSubscriptions()
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
    
    private func calculateNextPaymentDate(startDate: Date, paymentFrequency: PaymentFrequency) -> Date {
        var dateComponent = DateComponents()
        
        switch paymentFrequency {
        case .daily:
            dateComponent.day = 1
        case .weekly:
            dateComponent.day = 7
        case .monthly:
            dateComponent.month = 1
        case .quarterly:
            dateComponent.month = 3
        }
        
        return Calendar.current.date(byAdding: dateComponent, to: startDate) ?? startDate
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
    
    // MARK: - Notification Handling
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification authorization granted.")
            } else if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleNotificationCheck() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkAndSendNotifications()
        }
    }
    
    private func checkAndSendNotifications() {
        let now = Date()
        
        for (index, subscription) in subscriptions.enumerated() where subscription.isActive{
            // Check if next payment date is reached and no notification has been sent today
            if now >= subscription.nextPaymentDate && (subscription.notificationSentDate == nil || !Calendar.current.isDateInToday(subscription.notificationSentDate ?? now)){
                sendNotification(for: subscription)
                
                var updatedSubscription = subscription
                updatedSubscription.notificationSentDate = now
                updatedSubscription.nextPaymentDate = calculateNextPaymentDate(startDate: subscription.startDate, paymentFrequency: subscription.paymentFrequency)
                self.subscriptions[index] = updatedSubscription
                self.saveSubscriptions()
            }
        }
    }
    
    private func sendNotification(for subscription: Subscription) {
        let content = UNMutableNotificationContent()
        content.title = "Abonelik Ödeme Hatırlatması"
        content.body = "\(subscription.name) aboneliğinizin ödeme tarihi geldi."
        content.sound = .default
        
        // set notifaction hours
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error.localizedDescription)")
            } else {
                print("Notification sent for \(subscription.name)")
            }
        }
    }
}
