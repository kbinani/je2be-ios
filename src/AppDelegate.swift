import UIKit

@UIApplicationMain
class AppDelegate: UIResponder {
    var window: UIWindow?
}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let config = BugsnagConfiguration.loadConfig()
        if (Bundle.main.infoDictionary?["JE2BE_BUILD_CONFIGURATION"] as? String) == "Debug" {
            config.releaseStage = "development"
        } else {
            config.releaseStage = "release"
        }
        Bugsnag.start(with: config)
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        window.rootViewController = MainViewController()
        window.makeKeyAndVisible()
        return true
    }
}
