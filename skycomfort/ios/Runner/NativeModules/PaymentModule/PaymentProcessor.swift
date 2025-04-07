import Foundation
import Flutter

class PaymentProcessor: NSObject {
    // MARK: - Properties
    private let secureStorage = SecurePaymentStorage()
    
    // MARK: - Public Methods
    
    /// Process a payment with the provided details
    /// - Parameters:
    ///   - cardNumber: The credit card number
    ///   - expiryDate: The expiry date in MM/YY format
    ///   - cvv: The card verification value
    ///   - cardholderName: The name of the cardholder
    ///   - amount: The payment amount
    ///   - saveCard: Whether to save the card for future use
    ///   - completion: The completion handler with result
    func processPayment(
        cardNumber: String,
        expiryDate: String,
        cvv: String,
        cardholderName: String,
        amount: Double,
        saveCard: Bool,
        completion: @escaping (Result<PaymentResult, PaymentError>) -> Void
    ) {
        // In a real implementation, this would connect to a payment gateway
        // For demo purposes, we'll simulate a successful payment
        
        DispatchQueue.global().async {
            // Simulate network delay
            Thread.sleep(forTimeInterval: 1.0)
            
            // Validate card details
            guard self.validateCardDetails(
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cvv: cvv,
                cardholderName: cardholderName
            ) else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidCardDetails))
                }
                return
            }
            
            // Save card if requested
            if saveCard {
                let lastFourDigits = String(cardNumber.suffix(4))
                self.secureStorage.saveCard(
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardholderName: cardholderName,
                    lastFourDigits: lastFourDigits
                )
            }
            
            // Generate transaction ID
            let transactionId = "TR\(Int.random(in: 100000...999999))"
            let timestamp = Date()
            
            // Create payment result
            let result = PaymentResult(
                transactionId: transactionId,
                timestamp: timestamp,
                amount: amount,
                last4Digits: String(cardNumber.suffix(4)),
                success: true
            )
            
            // Return success
            DispatchQueue.main.async {
                completion(.success(result))
            }
        }
    }
    
    /// Process a payment with a saved card
    /// - Parameters:
    ///   - cardId: The identifier for the saved card
    ///   - amount: The payment amount
    ///   - completion: The completion handler with result
    func processPaymentWithSavedCard(
        cardId: String,
        amount: Double,
        completion: @escaping (Result<PaymentResult, PaymentError>) -> Void
    ) {
        DispatchQueue.global().async {
            // Simulate network delay
            Thread.sleep(forTimeInterval: 1.0)
            
            // Retrieve card from secure storage
            guard let cardDetails = self.secureStorage.getCard(withId: cardId) else {
                DispatchQueue.main.async {
                    completion(.failure(.cardNotFound))
                }
                return
            }
            
            // Generate transaction ID
            let transactionId = "TR\(Int.random(in: 100000...999999))"
            let timestamp = Date()
            
            // Create payment result
            let result = PaymentResult(
                transactionId: transactionId,
                timestamp: timestamp,
                amount: amount,
                last4Digits: cardDetails.lastFourDigits,
                success: true
            )
            
            // Return success
            DispatchQueue.main.async {
                completion(.success(result))
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func validateCardDetails(
        cardNumber: String,
        expiryDate: String,
        cvv: String,
        cardholderName: String
    ) -> Bool {
        // In a real app, this would perform actual validation
        // This is a simplified version for demo purposes
        
        // Check if card number is valid (simple check for demo)
        let sanitizedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        guard sanitizedCardNumber.count >= 13 && sanitizedCardNumber.count <= 19 else {
            return false
        }
        
        // Check if expiry date is valid (format MM/YY)
        let expiryComponents = expiryDate.split(separator: "/")
        guard expiryComponents.count == 2,
              let month = Int(expiryComponents[0]),
              let year = Int(expiryComponents[1]),
              month >= 1 && month <= 12,
              year >= 23 // 2023
        else {
            return false
        }
        
        // Check if CVV is valid (3-4 digits)
        guard cvv.count >= 3 && cvv.count <= 4,
              Int(cvv) != nil
        else {
            return false
        }
        
        // Check if cardholder name is not empty
        guard !cardholderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        return true
    }
}

// MARK: - Payment Result
struct PaymentResult {
    let transactionId: String
    let timestamp: Date
    let amount: Double
    let last4Digits: String
    let success: Bool
}

// MARK: - Payment Error
enum PaymentError: Error {
    case invalidCardDetails
    case processingFailed
    case cardNotFound
    case networkError
    case serverError
    
    var message: String {
        switch self {
        case .invalidCardDetails:
            return "Invalid card details. Please check and try again."
        case .processingFailed:
            return "Payment processing failed. Please try again."
        case .cardNotFound:
            return "Saved card not found."
        case .networkError:
            return "Network error. Please check your connection."
        case .serverError:
            return "Server error. Please try again later."
        }
    }
}

// MARK: - Saved Card
struct SavedCard {
    let id: String
    let lastFourDigits: String
    let expiryDate: String
    let cardholderName: String
    let cardNumber: String // In real app, this would be encrypted/tokenized
}

// MARK: - Secure Payment Storage
class SecurePaymentStorage {
    private var savedCards: [String: SavedCard] = [:]
    
    func saveCard(cardNumber: String, expiryDate: String, cardholderName: String, lastFourDigits: String) {
        let cardId = UUID().uuidString
        let card = SavedCard(
            id: cardId,
            lastFourDigits: lastFourDigits,
            expiryDate: expiryDate,
            cardholderName: cardholderName,
            cardNumber: cardNumber // In real app, would be encrypted
        )
        
        savedCards[cardId] = card
    }
    
    func getCard(withId id: String) -> SavedCard? {
        return savedCards[id]
    }
    
    func getAllSavedCards() -> [SavedCard] {
        return Array(savedCards.values)
    }
    
    func deleteCard(withId id: String) {
        savedCards.removeValue(forKey: id)
    }
} 