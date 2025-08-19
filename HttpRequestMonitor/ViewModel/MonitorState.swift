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
    
    public private(set)
    var requests: Array<HTTPMessage> = []
    
    public
    var error: MonitorError?
    
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
    }
    
    public mutating
    func addRequest(_ requests: HTTPMessage)
    {
        guard !self.requests.isEmpty else {
          
            self.requests.append(requests)
            return
        }
        
        self.requests.insert(requests, at: 0)
    }
}
