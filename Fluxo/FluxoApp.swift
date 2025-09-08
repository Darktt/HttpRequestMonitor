//
//  FluxoApp.swift
//  Fluxo
//
//  Created by Eden on 2025/8/19.
//

import SwiftUI

@main
public
struct FluxoApp: App
{
    public
    var body: some Scene {
        
        WindowGroup {
            
            MainView()
                .environmentObject(kMonitorStore)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
        .windowResizability(.contentSize)
        .commands {
            
            ToolsCommands(store: kMonitorStore)
        }
    }
    
    public
    init()
    {
        
    }
}
