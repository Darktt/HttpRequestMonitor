//
//  MainView.swift
//  Fluxo
//
//  Created by Eden on 2025/8/19.
//

import SwiftUI

public
struct MainView: View
{
    @EnvironmentObject
    private
    var store: MonitorStore
    
    private
    var state: MonitorState {
        
        self.store.state
    }
    
    @State
    private
    var isShowingErrorAlert: Bool = false
    
    public
    var body: some View {
        
        ZStack {
            // 背景色，支援 Light/Dark Mode
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0.0) {
                
                self.functionBar()
                
                self.bottomView()
                
                if self.state.httpStatus == .runing {
                    
                    StatusBar(self.ipAddress())
                        .background(.ultraThinMaterial)
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .alert("Error", isPresented: self.$isShowingErrorAlert) {
            
            Button("OK", role: .cancel) {
                
                self.isShowingErrorAlert = false
            }
        } message: {
            
            Text(self.state.error?.message ?? "Unknown Error")
        }
        .onChange(of: self.state.error != nil) {
            
            _, newValue in
            
            self.isShowingErrorAlert = newValue
        }
        .edgesIgnoringSafeArea(.top)
        .animation(.easeInOut(duration: 0.3), value: self.state.httpStatus)
    }
}

// MARK: - Private Methods -

private
extension MainView
{
    func functionBar() -> some View {
        
        FunctionBar(state: self.state) {
            
            action in
            
            self.store.dispatch(action)
        }
    }
    
    func bottomView() -> some View {
        
        GeometryReader {
            
            geometry in
            
            HStack(alignment: .top, spacing: 0.0) {
                
                let selectedRequest: Request? = self.state.selectedRequest
                
                // Sidebar（RequestListView）
                RequestListView(requests: self.state.requests, selected: selectedRequest)
                    .onSelected {
                        
                        request in
                        
                        let action = MonitorAction.selectRequest(request)
                        
                        self.store.dispatch(action)
                    }
                    .frame(width: geometry.size.width * 0.3)
                
                // 分隔線
                Rectangle()
                    .fill(Color.secondary.opacity(0.15))
                    .frame(width: 1)
                    .padding(.vertical, 8)
                
                // Content（DetailView）
                DetailView(request: selectedRequest)
                    .clipShape(RoundedRectangle(cornerRadius: 8.0, style: .continuous))
                    .padding([.leading, .bottom], 5)
                    .padding(.trailing, 7)
                    .frame(width: geometry.size.width * 0.7)
            }
        }
        .padding(.top, 4)
    }
    
    func ipAddress() -> String {
        
        let ipAddress: String = self.state.ipAddress.map {
            
            ipAddress in
            
            ", http://\(ipAddress):\(self.state.portNumber)"
        } ?? ""
        
        return "http://localhost:\(self.state.portNumber)" + ipAddress
    }
}

#Preview {
    
    MainView()
        .environmentObject(kMonitorStore)
}
