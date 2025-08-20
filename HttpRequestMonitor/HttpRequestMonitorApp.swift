//
//  HttpRequestMonitorApp.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2025/8/19.
//

import SwiftUI

@main
public
struct HttpRequestMonitorApp: App
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
    }
    
    public
    init()
    {
        
    }
}
