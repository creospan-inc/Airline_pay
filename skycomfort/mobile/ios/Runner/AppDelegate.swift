import UIKit
import Flutter

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    // Keep strong references to method channel handlers
    private var paymentChannel: PaymentChannel?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        
        // Setup method channels
        setupMethodChannels(controller)
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func setupMethodChannels(_ controller: FlutterViewController) {
        // Initialize payment channel
        paymentChannel = PaymentChannel(messenger: controller.binaryMessenger)
    }
}
