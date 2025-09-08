//
//  HttpRequestMonitorCommands.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2025/9/8.
//

import SwiftUI

public
struct HttpRequestMonitorCommands: Commands
{
    @StateObject
    public
    var store: MonitorStore
    
    private
    var state: MonitorState {
        
        self.store.state
    }
    
    public
    var body: some Commands {
        
        // 工具選單
        CommandMenu("Tools") {
            
            // 開始/停止監控
            self.startStopMenuItems()
            
            Divider()
            
            // 清除資料
            self.clearDataMenuItem()
        }
    }
}

// MARK: - Private Methods -

private
extension HttpRequestMonitorCommands
{
    // 開始/停止選單項目
    @ViewBuilder
    func startStopMenuItems() -> some View
    {
        if self.state.httpStatus == .suspend {
            
            Button("Start Monitor") {
                
                let action: MonitorAction = .startMonitor
                self.store.dispatch(action)
            }
            .keyboardShortcut("r", modifiers: [.command])
            
        } else {
            
            Button("Stop Monitor") {
                
                let action: MonitorAction = .stopMonitor
                self.store.dispatch(action)
            }
            .keyboardShortcut("r", modifiers: [.command])
        }
    }
    
    func clearDataMenuItem() -> some View
    {
        Button("Clean Requests") {
            
            let action: MonitorAction = .cleanRequests
            kMonitorStore.dispatch(action)
        }
        .keyboardShortcut("k", modifiers: [.command])
        .disabled(self.state.requests.isEmpty)
    }
}
