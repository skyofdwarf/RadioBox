import UIKit
import RadioBrowser
import Then

extension UIApplication {
    static let coordinator = AppCoordinator()
    static let model = AppModel(coordinator: coordinator)
    
    var window: UIWindow { Self.coordinator.window }
    
    func start() {
        UIApplication.model.send(action: .start)
    }
}

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
