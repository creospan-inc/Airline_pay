import Foundation

// Simplified PaymentProcessor for demo purposes
class PaymentProcessor {
    let secureStorage = SecureStorage()
    
    func processPayment(
        cardNumber: String,
        expiryDate: String,
        cvv: String,
        cardholderName: String,
        amount: Double,
        saveCard: Bool,
        completion: @escaping (Result<PaymentResult, PaymentError>) -> Void
    ) {
        // Simulate network delay (1 second)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Always succeed for demo purposes
            let result = PaymentResult(
                transactionId: "tx_\(Int.random(in: 10000...99999))",
                timestamp: Date(),
                amount: amount,
                last4Digits: String(cardNumber.suffix(4))
            )
            completion(.success(result))
        }
    }
    
    func processPaymentWithSavedCard(
        cardId: String,
        amount: Double,
        completion: @escaping (Result<PaymentResult, PaymentError>) -> Void
    ) {
        // Simulate network delay (1 second)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Always succeed for demo purposes
            let result = PaymentResult(
                transactionId: "tx_\(Int.random(in: 10000...99999))",
                timestamp: Date(),
                amount: amount,
                last4Digits: "1234"
            )
            completion(.success(result))
        }
    }
}

// Simple model classes
struct PaymentResult {
    let transactionId: String
    let timestamp: Date
    let amount: Double
    let last4Digits: String
}

struct PaymentError: Error {
    let code: String
    let message: String
}

class SecureStorage {
    func getAllSavedCards() -> [SavedCard] {
        return [
            SavedCard(
                id: "card_mock_123",
                lastFourDigits: "1234",
                expiryDate: "12/25",
                cardholderName: "Test User"
            )
        ]
    }
    
    func deleteCard(withId cardId: String) {
        // Mock implementation - do nothing
    }
}

struct SavedCard {
    let id: String
    let lastFourDigits: String
    let expiryDate: String
    let cardholderName: String
} 