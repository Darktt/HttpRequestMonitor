//
//  RootToolBar.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2021/9/15.
//

import UIKit

#if targetEnvironment(macCatalyst)

private struct TouchBarIdentifier
{
    static let startServer: NSTouchBarItem.Identifier = NSTouchBarItem.Identifier(MenuManager.identifier + ".startServer")
    
    static let stopServer: NSTouchBarItem.Identifier = NSTouchBarItem.Identifier(MenuManager.identifier + ".stopServer")
    
    static let allIdentifiers: Array<NSTouchBarItem.Identifier> = [TouchBarIdentifier.startServer, TouchBarIdentifier.stopServer]
}

extension RootViewController: NSTouchBarDelegate
{
    override
    public func makeTouchBar() -> NSTouchBar? {
        
        let touchBar = NSTouchBar().fluent
                        .delegate(self)
                        .defaultItemIdentifiers(TouchBarIdentifier.allIdentifiers)
                        .subject
        
        return touchBar
    }
    
    public func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem?
    {
        var touchBarItem: NSTouchBarItem? = nil
        
        if identifier == TouchBarIdentifier.startServer,
           let image = UIImage(systemName: "arrowtriangle.right.fill") {
            
            touchBarItem = NSButtonTouchBarItem(identifier: identifier, title: "Start server", image: image, target: self, action: Selector(("startServerAction:"))).fluent
                                .bezelColor(.systemBlue)
                                .subject
        }
        
        if identifier == TouchBarIdentifier.stopServer,
           let image = UIImage(systemName: "stop.fill") {
            
            touchBarItem = NSButtonTouchBarItem(identifier: identifier, title: "Stop server", image: image, target: self, action: Selector(("stopServerAction:"))).fluent
                                .bezelColor(.systemRed)
                                .subject
        }
        
        return touchBarItem
    }
}

#endif
