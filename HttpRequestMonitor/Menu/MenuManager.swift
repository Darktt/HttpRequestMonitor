//
//  MenuManager.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2021/9/14.
//

import UIKit

public class MenuManager
{
    // MARK: - Properties -
    
    public static let identifier: String = "com.darktt.personal.company"
    
    // MARK: - Methods -
    
    public static func startKeyCommand(action: Selector) -> UIKeyCommand
    {
        let startTitle: String = "Start server"
        let startKeyCommand = UIKeyCommand(title: startTitle, action: action, input: "S", modifierFlags: .command)
        
        return startKeyCommand
    }
    
    public static func stopKeyCommand(action: Selector) -> UIKeyCommand
    {
        let stopTitle: String = "Stop server"
        let stopKeyCommand = UIKeyCommand(title: stopTitle, action: action, input: "S", modifierFlags: [.alternate, .command])
        
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
        
        builder.insertChild(stopMenu, atStartOfMenu: .file)
        builder.insertChild(startMenu, atStartOfMenu: .file)
    }
}

// MARK: - Private Methods -

private extension MenuManager
{
    func startMenu() -> UIMenu
    {
        let startKeyCommand: UIKeyCommand = MenuManager.startKeyCommand(action: Selector(("startServerAction:")))
        let startServerMenu = UIMenu(title: "", image: nil, identifier: MenuManager.Identifier.startMenu, options: .displayInline, children: [startKeyCommand])
        
        return startServerMenu
    }
    
    func stopMenu() -> UIMenu
    {
        let stopKeyCommand: UIKeyCommand = MenuManager.stopKeyCommand(action: Selector(("stopServerAction:")))
        let stopServerMenu = UIMenu(title: "", image: nil, identifier: MenuManager.Identifier.stopMenu, options: .displayInline, children: [stopKeyCommand])
        
        return stopServerMenu
    }
}

// MARK: - MenuManager.Identifier -

private extension MenuManager
{
    struct Identifier
    {
        static let startMenu: UIMenu.Identifier = UIMenu.Identifier(MenuManager.identifier + ".startServer")
        
        static let stopMenu: UIMenu.Identifier = UIMenu.Identifier(MenuManager.identifier + ".stopServer")
    }
}
