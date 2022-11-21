import UIKit
import RadioBrowser
import Then

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIApplication.coordinator.window

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        UIApplication.shared.start()
        
        return true
    }
}
