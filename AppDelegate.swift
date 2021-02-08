import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Get View Controllers
        guard let splitViewController = window?.rootViewController as? UISplitViewController,
            let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
            let masterViewController = leftNavController.topViewController as? Boilerplates,
            let detailViewController = splitViewController.viewControllers.last as? Response
            else { fatalError() }
        
        // Set responseBuilder delegate so responses update in detail view
        masterViewController.responseBuilder = detailViewController
        
        // Activate Local-iCloud syncing library
        MKiCloudSync.start(withPrefix: "sync")
        
        return true
    }
}
