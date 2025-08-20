//
//  FunctionBar.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2025/8/20.
//

import SwiftUI

public
struct FunctionBar: View
{
    public
    var state: MonitorState
    
    public
    var actionHandler: (MonitorAction) -> Void
    
    public
    var body: some View {
        
        ZStack(alignment: .top) {
            
            VStack(alignment: .leading, spacing: 0.0) {
                
                HStack(spacing: 0.0) {
                    
                    Text(self.state.status)
                        .bold()
                    
                    Spacer()
                    
                    self.buttons()
                }
                .padding(.allEdge(10.0))
                
                Divider()
            }
            .padding(.top, 42.0)
        }
        .background(self.state.httpStatus == .runing ? Color.accentColor : Color.clear)
        .animation(.easeInOut(duration: 0.3), value: self.state.httpStatus)
    }
}

// MARK: - Private Methods -

private
extension FunctionBar
{
    func buttons() -> some View
    {
        HStack(spacing: 5.0) {
            
            if !self.state.requests.isEmpty {
                
                Image(systemName: "trash")
                    .foregroundColor(.white)
                    .onTapGesture {
                        
                        let action: MonitorAction = .cleanRequests
                        
                        self.actionHandler(action)
                    }
            }
            
            self.startStopButton()
        }
    }
    
    func startStopButton() -> some View
    {
        if self.state.httpStatus != .suspend {
            
            // Stop Monitor Button
            Image(systemName: "stop.fill")
                .foregroundColor(.white)
                .onTapGesture {
                    
                    let action: MonitorAction = .stopMonitor
                    
                    self.actionHandler(action)
                }
        } else {
            
            // Start Monitor Button
            Image(systemName: "play.fill")
                .foregroundColor(.accentColor)
                .onTapGesture {
                    
                    let action: MonitorAction = .startMonitor
                    
                    self.actionHandler(action)
                }
        }
    }
}
