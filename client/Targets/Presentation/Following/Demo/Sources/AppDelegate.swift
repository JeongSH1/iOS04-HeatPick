import UIKit
import ModernRIBs
import CoreKit
import NetworkAPIKit
import BasePresentation
import DomainInterfaces
import DomainUseCases
import DataRepositories

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var launchRouter: DemoRootRouter?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        let router = DemoRootBuilder(dependency: DemoRootComponent()).build()
        router.listener = self
        self.launchRouter = router
        router.launch(from: window)
        return true
    }
}

extension AppDelegate: DemoRootRouterListener {
    func demoRootRouterDidBecomeActive() {
        launchRouter?.attach(execute: { viewController in
        // 라우팅 로직 추가
        })
    }
}
