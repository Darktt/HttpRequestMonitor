//
//  HTTPConnection.swift
//  Fluxo
//
//  Created by Eden on 2021/9/8.
//

import Foundation
import Network

public
class HTTPConnection
{
    //The TCP maximum package size is 64K 65536
    public
    let MTU: Int = 65536
    
    public
    let identifier: String = UUID().uuidString
    
    public
    let connection: NWConnection
    
    public
    var receiveRequestHandler: HTTPService.ReceiveRequestHandler?
    
    public
    var errorHandler: HTTPService.ErrorHandler?
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public
    init(_ connection: NWConnection)
    {
        self.connection = connection
    }
    
    public
    func start(queue: DispatchQueue = .main)
    {
        print("Starting connect the connection...")
        
        self.connection.stateUpdateHandler = self.connectionStateChange
        
        self.handleReceive()
        self.connection.start(queue: queue)
    }
    
    public
    func cancel()
    {
        print("Canceling connect the connection...")
        
        self.connection.stateUpdateHandler = nil
        self.connection.pathUpdateHandler = nil
        self.connection.cancel()
    }
}

private
extension HTTPConnection
{
    func connectionStateChange(to state: NWConnection.State)
    {
        switch state {
        
        case .setup:
            print("ℹ️ Connection: \(self.connection) in setup.")
        
        case .waiting(let error):
            print("ℹ️ Connection: \(self.connection) is waiting with error: \(error)")
            
        case .preparing:
            print("ℹ️ Connection: \(self.connection) is preparing.")
            
        case .ready:
            print("ℹ️ Connection: \(self.connection) is ready.")
            
        case .failed(let error):
            print("ℹ️ Connection: \(self.connection), failed to start with error: \(error)")
            
        case .cancelled:
            print("ℹ️ Connection: \(self.connection) is canceled.")
            
        @unknown
        default:
            fatalError()
        }
    }
    
    func handleReceive(_ request: HTTPMessage? = nil)
    {
        let request = request ?? HTTPMessage()
        
        let completion: @Sendable (Data?, NWConnection.ContentContext?, Bool, NWError?)  -> Void = {
            
            [weak self] data, _, isComplete, error in
            
            guard let self = self else {
                
                return
            }
            
            // 處理錯誤和連接狀態
            if let error: NWError = error {
                print("❌ Receive error: \(error)")
                
                // 如果是連接重置錯誤，不要嘗試繼續接收
                
                if error.errorCode == 54 {
                    
                    // ECONNRESET
                    print("ℹ️ Connection reset by peer, closing connection")
                    self.cancel()
                    return
                }
                
                self.errorHandler.unwrapped({ $0(error) })
                return
            }
            
            // 處理接收到的數據
            if let data = data, !data.isEmpty {
                
                if let string = String(data: data, encoding: .utf8) {
                    
                    print("ℹ️ Request data: \(string)")
                }
                
                request.appendData(data)
                
                if !self.isValidHTTPRequest(request) {
                    
                    print("❗️ Failed to parse HTTP message from data")
                    
                    let errorResponse = self.badRequestResponse()
                    
                    self.sendResponse(errorResponse) {
                        
                        self.cancel()
                    }
                    return
                }
                
                print("ℹ️ Request content size: \(request.contentSize)")
                print("➡️ Received data: \(data.count) bytes")
                print("➡️ Current size: \(request.contentSize) bytes")
                print("------------------")
            }
            
            let isComplete: Bool = isComplete || request.isComplete
            
            // 如果連接完成，關閉連接
            if isComplete {
                
                self.receiveRequestHandler.unwrapped({ $0(request) })
                
                let response = self.makeResponse(fromRequest: request)
                self.sendResponse(response) {
                    
                    print("ℹ️ Connection completed, closing")
                    self.cancel()
                }
                
            } else {
                
                // 只有在連接仍然活躍時才繼續接收
                self.handleReceive(request)
            }
        }
        
        self.connection.receive(minimumIncompleteLength: 1, maximumLength: self.MTU, completion: completion)
    }
    
    func isValidHTTPRequest(_ request: HTTPMessage) -> Bool
    {
        var isValid: Bool = (request.requestMethod != nil)
        
        return isValid
    }
    
    func makeResponse(fromRequest request: HTTPMessage) -> HTTPMessage
    {
        guard let method: HTTPMethod = request.requestMethod else {
            
            let response = HTTPMessage.response(statusCode: .badRequest, htmlString: "<h1>Bad Request</h1>")
            
            return response
        }
        
        let response = HTTPMessage.response(statusCode: .ok, htmlString: "<h1>Hello world!</h1><br/><p>Method: \(method.rawValue)</p>")
        
        return response
    }
    
    func badRequestResponse() -> HTTPMessage
    {
        let string = "<h1>400 Bad Request</h1><p>Invalid HTTP request format</p>"
        let response = HTTPMessage.response(statusCode: .badRequest, htmlString: string)
        
        return response
    }
    
    func sendResponse(_ response: HTTPMessage, completion: @escaping () -> Void)
    {
        guard let data: Data = response.data else {
            
            return
        }
        
        self.send(data, completion: completion)
    }
    
    func send(_ data: Data, completion: @escaping () -> Void)
    {
        let completion: NWConnection.SendCompletion = .contentProcessed {
            
            [unowned self] error in
            
            if let error: NWError = error {
                
                print("ℹ️ Connection: \(self.connection), content processed with error: \(error)")
                
                self.errorHandler.unwrapped({ $0(error) })
            }
            
            print("ℹ️ Response sent successfully")
            
            completion()
        }
        
        self.connection.send(content: data, contentContext: .finalMessage, completion: completion)
    }
}
