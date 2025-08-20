//
//  MainView.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2025/8/19.
//

import SwiftUI

public
struct MainView: View
{
    @EnvironmentObject
    var store: MonitorStore
    
    var state: MonitorState {
        
        self.store.state
    }
    
    public
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0.0) {
            
            self.functionBar()
            
            self.buttonView()
        }
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
    
    func buttonView() -> some View {
        
        GeometryReader {
            
            geometry in
            
            HStack(alignment: .top, spacing: 2.0) {
                
                RequestListView(requests: self.state.requests)
                    .onSelected {
                        
                        request in
                        
                        let action = MonitorAction.selectRequest(request)
                        
                        self.store.dispatch(action)
                    }
                    .frame(width: geometry.size.width * 0.3)
                
                Divider()
                
                DetailView(request: self.state.selectedRequest)
                    .frame(width: geometry.size.width * 0.7)
            }
        }
    }
}

#Preview {
    
    MainView()
        .environmentObject(kMonitorStore)
}
