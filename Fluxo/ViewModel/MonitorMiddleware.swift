//
//  MonitorMiddleware.swift
//
//  Created by Eden on 2025/8/19.
//  
//

import Foundation
import Network

@MainActor
public
let MonitorMiddleware: Middleware<MonitorState, MonitorAction> = {
    
    store in
    
    {
        next in
        
        {
            action in
            
            if case .startMonitor = action {
                
                let newAction = startMonitorAction(store.state.portNumber)
                
                next(newAction)
            }
            
            if case .stopMonitor = action {
                
                store.state.httpService?.cancel()
                let newAction = MonitorAction.stopMonitorResponse
                
                next(newAction)
            }
            
            next(action)
        }
    }
}

private
func startMonitorAction(_ portNumber: UInt16) -> MonitorAction
{
    do {
        
        let port = NWEndpoint.Port(integerLiteral: portNumber)
        let service = try HTTPService(port: port)
        service.statusUpdateHandler = serviceStatusUpdate(status:)
        service.receiveRequestHandler = receiveRequest(request:)
        service.start()
        
        let action = MonitorAction.startMonitorResponse(service)
        
        return action
    } catch {
        
        let nsError = error as NSError
        let error: MonitorError = (nsError.code, nsError.localizedDescription)
        
        let action = MonitorAction.error(error)
        
        return action
    }
}

private
func serviceStatusUpdate(status: HTTPService.Status)
{
    Task {
        @MainActor in
        
        let action = MonitorAction.updateStatus(status)
        
        kMonitorStore.dispatch(action)
    }
}

private
func receiveRequest(request: HTTPMessage)
{
    Task {
        @MainActor in
        
        let action = MonitorAction.receiveRequest(request)
        
        kMonitorStore.dispatch(action)
    }
}
