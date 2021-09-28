//
//  HTTPConnection.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2021/9/8.
//

import Foundation
import Network

public class HTTPConnection
{
    //The TCP maximum package size is 64K 65536
    public let MTU: Int = 65536
    
    public let identifier: String = UUID().uuidString
    
    public let connection: NWConnection
    
    public var receiveRequestHandler: HTTPService.ReceiveRequestHandler?
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public init(_ connection: NWConnection)
    {
        self.connection = connection
    }
    
    public func start(queue: DispatchQueue = .main)
    {
        print("Starting connect the connection...")
        
        self.connection.stateUpdateHandler = self.connectionStateChange
        
        self.handleReceive()
        self.connection.start(queue: queue)
    }
    
    public func cancel()
    {
        print("Canceling connect the connection...")
        
        self.connection.stateUpdateHandler = nil
        self.connection.pathUpdateHandler = nil
        self.connection.cancel()
    }
    
    public func send(_ data: Data)
    {
        let complation: NWConnection.SendCompletion = .contentProcessed {
            
            guard let error = $0 else {
                
                return
            }
            
            print("Connection: \(self.connection), content peocessed with error: \(error)")
        }
        
        self.connection.send(content: data, completion: complation)
    }
}

private extension HTTPConnection
{
    func connectionStateChange(to state: NWConnection.State)
    {
        switch state {
        
        case .setup:
            print("Connection: \(self.connection) in setup.")
        
        case .waiting(let error):
            print("Connection: \(self.connection) is waiting with error: \(error)")
            
        case .preparing:
            print("Connection: \(self.connection) is preparing.")
            
        case .ready:
            print("Connection: \(self.connection) is ready.")
            
        case .failed(let error):
            print("Connection: \(self.connection), failed to start with error: \(error)")
            
        case .cancelled:
            print("Connection: \(self.connection) is canceled.")
            
        @unknown
        default:
            fatalError()
        }
    }
    
    func handleReceive()
    {
        self.connection.receive(minimumIncompleteLength: 1, maximumLength: self.MTU) {
            
            if let data: Data = $0, let httpMessage = HTTPMessage.request(withData: data) {
                
                if let string = String(data: data, encoding: .utf8) {
                    
                    print("Request data: \(string)")
                }
                
                print("Did receive request: \(httpMessage)")
                
                if let handler: HTTPService.ReceiveRequestHandler = self.receiveRequestHandler {
                    
                    handler(httpMessage)
                }
                
                let response: HTTPMessage = self.makeResponse(fromRequest: httpMessage)
                
                self.sendResponse(response)
            }
            
            if !$2, let error = $3 {
                
                print("\(error)")
            }
        }
    }
    
    func makeResponse(fromRequest request: HTTPMessage) -> HTTPMessage
    {
        guard request.requestURL?.path == "/",
              let method: HTTPMethod = request.requestMethod else {
            
            let response = HTTPMessage.response(statusCode: .badRequest, htmlString: "<h1>Bad Request</h1>")
            
            return response
        }
        
        let response = HTTPMessage.response(statusCode: .ok, htmlString: "<h1>Hello world!</h1><br/><p>Method: \(method.rawValue)</p>")
        
        return response
    }
    
    func sendResponse(_ response: HTTPMessage)
    {
        guard let data: Data = response.data else {
            
            return
        }
        
        self.send(data)
    }
}
