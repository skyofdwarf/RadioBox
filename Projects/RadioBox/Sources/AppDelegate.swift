import UIKit
import RadioBrowser

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = UIViewController()
        viewController.view.backgroundColor = .white
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        
        let addrs1 = try? DNSLookup.lookup(hostname: "all.api.radio-browser.info")
        print("lookup: \(addrs1)")
        
        let addrs2 = try? DNSLookup.lookup(hostname: "www.naver.com")
        print("lookup: \(addrs2)")
        
        return true
    }

}
