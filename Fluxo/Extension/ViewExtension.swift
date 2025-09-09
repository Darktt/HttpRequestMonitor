//
//  ViewExtension.swift
//
//  Created by Eden on 2025/8/25.
//  
//

import SwiftUI

public
extension View
{
    var eraseToAnyView: AnyView {
        
        AnyView(self)
    }
    
    nonisolated
    func disableFullScreen() -> some View
    {
        if #available(macOS 15.0, *) {
            
            return self.windowFullScreenBehavior(.disabled)
        }
        
        self.disableFullScreenIn15Early()
        
        return self
    }
}

private
extension View
{
    nonisolated
    func disableFullScreenIn15Early()
    {
        DispatchQueue.main.async {
            
            let application = NSApplication.shared
            if let window = application.windows.first {
                
                window.collectionBehavior.remove(.fullScreenPrimary)
            }
        }
    }
}
