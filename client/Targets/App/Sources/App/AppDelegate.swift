import UIKit
import Combine
import ModernRIBs

import FoundationKit
import DataRepositories
import NMapsMap

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private var launchRouter: LaunchRouting?
    private var cancellables = Set<AnyCancellable>()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NMFAuthManager.shared().clientId = Secret.naverMapClientID.value
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        let router = makeRootBuilder().build()
        self.launchRouter = router
        launchRouter?.launch(from: window)
        receiveSignOut()
        return true
    }
    
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let code = url.absoluteString.components(separatedBy: "code=").last {
            GithubLoginRepository.shared.requestToken(with: code)
        }
        
        return true
    }
    
}

private extension AppDelegate {
    
    func makeRootBuilder() -> AppRootBuilder {
        return AppRootBuilder(dependency: AppComponent())
    }
    
    func resetAppRoot() {
        guard let window else { return }
        window.rootViewController = nil
        launchRouter = nil
        let router = makeRootBuilder().build()
        self.launchRouter = router
        launchRouter?.launch(from: window)
    }
    
    func receiveSignOut() {
        SignoutService.shared.signOutCompleted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSignOutCompleted in
                guard let self else { return }
                resetAppRoot()
            }
            .store(in: &cancellables)
    }
    
}
