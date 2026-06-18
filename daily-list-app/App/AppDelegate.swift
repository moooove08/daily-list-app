import UIKit


class AppMain: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isHidden = true
    }
    
    override var prefersStatusBarHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var shouldAutorotate: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    
}
    

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = AppMain(rootViewController: RootViewController()) 
        window?.makeKeyAndVisible()
        return true
    }
}
