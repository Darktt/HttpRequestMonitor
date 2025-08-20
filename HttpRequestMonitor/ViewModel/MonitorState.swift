//
//  MonitorState.swift
//
//  Created by Eden on 2025/8/19.
//  
//

import Foundation

public
struct MonitorState
{
    // MARK: - Properties -
    
    public
    let portNumber: UInt16 = 3000
    
    public private(set)
    var httpService: HTTPService?
    
    public
    var httpStatus: HTTPService.Status = .suspend
    
    public
    var status: String {
        
        switch self.httpStatus {
        case .suspend:
            "Service is suspended"
            
        case .waitting(let error):
            "Service is waiting: \(error.localizedDescription)"
            
        case .runing:
            "Service is running"
            
        case .failed(let error):
            "Service failed: \(error.localizedDescription)"
        }
    }
    
    public private(set)
    var requests: Array<Request> = []
    
    public
    var error: MonitorError?
    
    public
    var selectedRequest: Request?
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public
    init()
    {
        
    }
    
    public mutating
    func setHTTPService(_ service: HTTPService?)
    {
        self.httpService = service
        self.requests = []
    }
    
    public mutating
    func cleanRequests()
    {
        self.requests.removeAll()
        self.selectedRequest = nil
    }
    
    public mutating
    func addRequest(_ request: HTTPMessage)
    {
        let request = Request(message: request)
        
        guard !self.requests.isEmpty else {
            
            self.requests.append(request)
            return
        }
        
        self.requests.insert(request, at: 0)
    }
}
