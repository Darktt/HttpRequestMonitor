//
//  MenuManager.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2021/9/14.
//

import UIKit

private let kIdentifier: String = "com.darktt.personal.company"

public class MenuManager
{
    // MARK: - Properties -
    
    private lazy var noticationCenter: NotificationCenter = {
        
        NotificationCenter.default
    }()
    
    // MARK: - Methods -
    
    public static func startKeyCommand(action: Selector) -> UIKeyCommand
    {
        let startTitle: String = "Start server…"
        let startKeyCommand = UIKeyCommand(title: startTitle, action: action, input: "s", modifierFlags: .command)
        
        return startKeyCommand
    }
    
    public static func stopKeyCommand(action: Selector) -> UIKeyCommand
    {
        let stopTitle: String = "Stop server…"
        let stopKeyCommand = UIKeyCommand(title: stopTitle, action: action, input: "x", modifierFlags: .command)
        
        return stopKeyCommand
    }
    
    // MARK: Initial Method
    
    public init(with builder: UIMenuBuilder)
    {
        let startMenu: UIMenu = self.startMenu()
        let stopMenu: UIMenu = self.stopMenu()
        
        builder.remove(menu: .format)
        builder.remove(menu: .view)
        builder.remove(menu: .window)
        
        builder.insertChild(startMenu, atStartOfMenu: .file)
        builder.insertChild(stopMenu, atStartOfMenu: .file)
    }
}

// MARK: - Actions -

private extension MenuManager
{
    @objc
    func startServiceAction(_ sender: UIKeyCommand)
    {
        self.noticationCenter.post(name: MenuManager.NotificationName.startServerNotificationName, object: nil)
    }
    
    @objc
    func stopServerAction(_ sender: UIKeyCommand)
    {
        self.noticationCenter.post(name: MenuManager.NotificationName.stopServerNotificationName, object: nil)
    }
}

// MARK: - Private Methods -

private extension MenuManager
{
    func startMenu() -> UIMenu
    {
        let startKeyCommand: UIKeyCommand = MenuManager.startKeyCommand(action: #selector(self.startServiceAction(_:)))
        let startServerMenu = UIMenu(title: "", image: nil, identifier: MenuManager.Identifier.startMenu, options: .displayInline, children: [startKeyCommand])
        
        return startServerMenu
    }
    
    func stopMenu() -> UIMenu
    {
        let stopKeyCommand: UIKeyCommand = MenuManager.stopKeyCommand(action: #selector(self.stopServerAction(_:)))
        let stopServerMenu = UIMenu(title: "", image: nil, identifier: MenuManager.Identifier.stopMenu, options: .displayInline, children: [stopKeyCommand])
        
        return stopServerMenu
    }
}

// MARK: - MenuManager.Identifier -

private extension MenuManager
{
    struct Identifier
    {
        static let startMenu: UIMenu.Identifier = UIMenu.Identifier(kIdentifier + ".startServer")
        
        static let stopMenu: UIMenu.Identifier = UIMenu.Identifier(kIdentifier + ".stopServer")
    }
}

// MARK: - MenuManager.NotificationName -

public extension MenuManager
{
    struct NotificationName
    {
        static let startServerNotificationName: Notification.Name = Notification.Name("MenuManager.NotificationName.startServer")
        
        static let stopServerNotificationName: Notification.Name = Notification.Name("MenuManager.NotificationName.stopServer")
    }
}
