import Foundation
import Flutter

class PaymentChannel {
    private let methodChannel: FlutterMethodChannel
    private let paymentProcessor = PaymentProcessor()
    
    init(messenger: FlutterBinaryMessenger) {
        methodChannel = FlutterMethodChannel(name: "com.skycomfort.payment", binaryMessenger: messenger)
        setupMethodCallHandler()
    }
    
    private func setupMethodCallHandler() {
        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            
            print("PaymentChannel received method call: \(call.method)")
            
            switch call.method {
            case "processPayment":
                self.handleProcessPayment(call, result)
            case "processPaymentWithSavedCard":
                self.handleProcessPaymentWithSavedCard(call, result)
            case "getSavedCards":
                self.handleGetSavedCards(result)
            case "deleteSavedCard":
                self.handleDeleteSavedCard(call, result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func handleProcessPayment(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        print("Handling processPayment")
        guard let args = call.arguments as? [String: Any],
              let cardNumber = args["cardNumber"] as? String,
              let expiryDate = args["expiryDate"] as? String,
              let cvv = args["cvv"] as? String,
              let cardholderName = args["cardholderName"] as? String,
              let amount = args["amount"] as? Double,
              let saveCard = args["saveCard"] as? Bool else {
            print("Invalid arguments for processPayment")
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        print("Processing payment with card: \(cardNumber.suffix(4))")
        
        paymentProcessor.processPayment(
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cvv: cvv,
            cardholderName: cardholderName,
            amount: amount,
            saveCard: saveCard
        ) { processResult in
            switch processResult {
            case .success(let paymentResult):
                print("Payment successful with transaction ID: \(paymentResult.transactionId)")
                let responseDict: [String: Any] = [
                    "success": true,
                    "transactionId": paymentResult.transactionId,
                    "timestamp": Int(paymentResult.timestamp.timeIntervalSince1970 * 1000),
                    "amount": paymentResult.amount,
                    "last4Digits": paymentResult.last4Digits
                ]
                result(responseDict)
                
            case .failure(let error):
                print("Payment failed: \(error.message)")
                result(FlutterError(code: "PAYMENT_ERROR", message: error.message, details: nil))
            }
        }
    }
    
    private func handleProcessPaymentWithSavedCard(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        print("Handling processPaymentWithSavedCard")
        guard let args = call.arguments as? [String: Any],
              let cardId = args["cardId"] as? String,
              let amount = args["amount"] as? Double else {
            print("Invalid arguments for processPaymentWithSavedCard")
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        print("Processing payment with saved card ID: \(cardId)")
        
        paymentProcessor.processPaymentWithSavedCard(
            cardId: cardId,
            amount: amount
        ) { processResult in
            switch processResult {
            case .success(let paymentResult):
                print("Payment successful with transaction ID: \(paymentResult.transactionId)")
                let responseDict: [String: Any] = [
                    "success": true,
                    "transactionId": paymentResult.transactionId,
                    "timestamp": Int(paymentResult.timestamp.timeIntervalSince1970 * 1000),
                    "amount": paymentResult.amount,
                    "last4Digits": paymentResult.last4Digits
                ]
                result(responseDict)
                
            case .failure(let error):
                print("Payment failed: \(error.message)")
                result(FlutterError(code: "PAYMENT_ERROR", message: error.message, details: nil))
            }
        }
    }
    
    private func handleGetSavedCards(_ result: @escaping FlutterResult) {
        print("Handling getSavedCards")
        let cards = paymentProcessor.secureStorage.getAllSavedCards()
        let cardsArray = cards.map { card -> [String: Any] in
            return [
                "id": card.id,
                "lastFourDigits": card.lastFourDigits,
                "expiryDate": card.expiryDate,
                "cardholderName": card.cardholderName
            ]
        }
        
        result(cardsArray)
    }
    
    private func handleDeleteSavedCard(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        print("Handling deleteSavedCard")
        guard let args = call.arguments as? [String: Any],
              let cardId = args["cardId"] as? String else {
            print("Invalid arguments for deleteSavedCard")
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        paymentProcessor.secureStorage.deleteCard(withId: cardId)
        result(true)
    }
} 