import UIKit

@UIApplicationMain
class AppDelegate: UIResponder {
    var window: UIWindow?
}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Bugsnag.start()

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        window.rootViewController = MainViewController()
        window.makeKeyAndVisible()
        return true
    }
}
