//
//  MonitorState.swift
//
//  Created by Eden on 2025/8/19.
//  
//

import Foundation
import SwiftUICore

public
struct MonitorState
{
    // MARK: - Properties -
    
    public
    let portNumber: UInt16 = 3000
    
    public
    let ipAddress: String? = getIPAddress()
    
    public private(set)
    var httpService: HTTPService?
    
    public
    var httpStatus: HTTPService.Status = .suspend {
        
        willSet {
            
            switch newValue {
                
                case .suspend:
                    self.status = "Service is suspended"
                
                case .waitting(_):
                    self.status = "Service is waiting"
                
                case .runing:
                    self.status = "Service is running"
                
                case .failed(let error as NSError):
                    self.error = (error.code, error.localizedDescription)
                    self.status = "Service failed"
            }
        }
    }
    
    public
    var status: LocalizedStringKey = "Service is suspended"
    
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
        self.selectedRequest = nil
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
            self.selectedRequest = request
            return
        }
        
        self.requests.insert(request, at: 0)
    }
}
