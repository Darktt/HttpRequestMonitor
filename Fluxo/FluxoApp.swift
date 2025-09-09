//
//  FluxoApp.swift
//  Fluxo
//
//  Created by Eden on 2025/8/19.
//

import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate
{
    func applicationDidFinishLaunching(_ notification: Notification)
    {
        NSWindow.allowsAutomaticWindowTabbing = false
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool
    {
        true
    }
}

@main
public
struct FluxoApp: App
{
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    private
    var appDelegate: AppDelegate
    
    public
    var body: some Scene {
        
        WindowGroup {
            
            MainView()
                .environmentObject(kMonitorStore)
                .disableFullScreen()
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
        .windowResizability(.contentMinSize)
        .commands {
            
            ToolsCommands(store: kMonitorStore)
        }
    }
    
    public
    init()
    {
        
    }
}
