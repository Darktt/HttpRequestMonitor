//
//  MonitorStore.swift
//
//  Created by Eden on 2025/8/19.
//  
//

import UIKit

private
func kReducer(state: MonitorState, action: MonitorAction) -> MonitorState {
    
    var newState = state
    newState.error = nil
    
    if case let .startMonitorResponse(service) = action {
        
        newState.setHTTPService(service)
    }
    
    if case .stopMonitorResponse = action {
        
        newState.setHTTPService(nil)
    }
    
    if case let .updateStatus(status) = action {
        
        newState.httpStatus = status
    }
    
    if case let .receiveRequest(request) = action {
        
        newState.addRequest(request)
    }
    
    if case .cleanRequests = action {
        
        newState.cleanRequests()
    }
    
    if case let .error(monitorError) = action {
        
        newState.error = monitorError
    }
    
    return newState
}

public
typealias MonitorStore = Store<MonitorState, MonitorAction>

@MainActor
let kMonitorStore = MonitorStore(initialState: MonitorState(),
                           reducer: kReducer,
                            middlewares: [
                                
                                MonitorMiddleware
                            ]
)
