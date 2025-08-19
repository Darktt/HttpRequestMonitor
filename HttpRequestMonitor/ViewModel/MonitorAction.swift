//
//  MonitorAction.swift
//
//  Created by Eden on 2025/8/19.
//  
//

import Foundation

public
enum MonitorAction
{
    case startMonitor
    
    case startMonitorResponse(HTTPService)
    
    case updateStatus(HTTPService.Status)
    
    case receiveRequest(HTTPMessage)
    
    case stopMonitor
    
    case stopMonitorResponse
    
    case cleanRequests
    
    case error(MonitorError)
}
