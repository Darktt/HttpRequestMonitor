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
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    self.buttons()
                }
                .padding(.allEdge(10.0))
                
                Divider()
            }
            .padding(.top, 22.0)
        }
    }
}

// MARK: - Private Methods -

private
extension FunctionBar
{
    func buttons() -> some View
    {
        HStack(spacing: 12.0) {
            
            if !self.state.requests.isEmpty {
                
                FunctionBarButton(icon: "trash", label: "清除") {
                    
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
            FunctionBarButton(icon: "stop.fill", label: "停止") {
                
                let action: MonitorAction = .stopMonitor
                
                self.actionHandler(action)
            }
        } else {
            
            // Start Monitor Button
            FunctionBarButton(icon: "play.fill", label: "啟動") {
                
                let action: MonitorAction = .startMonitor
                
                self.actionHandler(action)
            }
        }
    }
}

// 新增現代化按鈕元件
private
struct FunctionBarButton: View
{
    let icon: String
    
    let label: String
    
    let action: () -> Void
    
    @State
    private
    var isHover = false
    
    var body: some View {
        
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                Text(label)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 14)
            .background(isHover ? Color.accentColor.opacity(0.18) : Color.clear)
            .foregroundColor(isHover ? .accentColor : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: isHover ? .accentColor.opacity(0.08) : .clear, radius: 4, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover {
            hover in
            
            isHover = hover
        }
        .animation(.easeInOut(duration: 0.18), value: isHover)
    }
}
