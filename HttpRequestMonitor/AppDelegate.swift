//
//  AppDelegate.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2021/9/8.
//

import UIKit

public enum ActionType: String
{
    case startAction = "Start action"
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate
{
    private var menuManager: MenuManager?
    
    override func buildMenu(with builder: UIMenuBuilder)
    {
        super.buildMenu(with: builder)
        
        guard builder.system == .main else {
            
            return
        }
        
        let manager = MenuManager(with: builder)
        
        self.menuManager = manager
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
        // Setup app quick actions.
        
        let startIcon = UIApplicationShortcutIcon(systemImageName: "arrowtriangle.right.fill")
        let startAction = UIApplicationShortcutItem(type: ActionType.startAction.rawValue, localizedTitle: "Start server", localizedSubtitle: nil, icon: startIcon)
        
        application.shortcutItems = [startAction]
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration
    {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>)
    {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void)
    {
        guard let actionType = ActionType(rawValue: shortcutItem.type), actionType == .startAction else {
            
            completionHandler(false)
            return
        }
        
        NotificationCenter.default.post(name: RootViewController.startServerNoticationName, object: nil)
    }
}
