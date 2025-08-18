//
//  SceneDelegate.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2021/9/8.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate
{
    // MARK: - Properties -
    
    var window: UIWindow?
    
    var savedShortcutItem: UIApplicationShortcutItem?
    
    // MARK: - Methods -
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)
    {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else {
            
            return
        }
        
        let frame: CGRect = windowScene.coordinateSpace.bounds
        
        let rootViewController = RootViewController()
        
        let navigationController = UINavigationController(rootViewController: rootViewController)
        
        let splitController = UISplitViewController().fluent
                                .viewControllers([navigationController])
                                .presentsWithGesture(false)
                                .preferredDisplayMode(.oneBesideSecondary)
                                .primaryBackgroundStyle(.sidebar)
                                .subject
        
        splitController.showDetailViewController(navigationController, sender: nil)
        
        let window = UIWindow(frame: frame).fluent
                            .windowScene(windowScene)
                            .rootViewController(splitController)
                            .subject
        
        window.makeKeyAndVisible()
        
        self.window = window
        self.savedShortcutItem = connectionOptions.shortcutItem
    }
    
    func sceneDidDisconnect(_ scene: UIScene)
    {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene)
    {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        self.savedShortcutItem.unwrapped {
            
            self.handleSortcutItem($0)
            self.savedShortcutItem = nil
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene)
    {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene)
    {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene)
    {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void)
    {
        let result: Bool = self.handleSortcutItem(shortcutItem)
        
        completionHandler(result)
    }
}

// MARK: - Private Methods -

private
extension SceneDelegate
{
    @discardableResult
    func handleSortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool
    {
        guard let actionType = ActionType(rawValue: shortcutItem.type), actionType == .startAction else {
            
            return false
        }
        
        OperationQueue.main.addOperation {
            
            NotificationCenter.default.post(name: RootViewController.startServerNoticationName, object: nil)
        }
        
        return true
    }
}
