//
//  HTTPService.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2021/9/8.
//

import Network

public class HTTPService
{
    public typealias StatusUpdateHandler = ((HTTPService.Status) -> Void)
    
    public typealias ReceiveRequestHandler = ((HTTPMessage) -> Void)
    
    // MARK: - Properties -
    
    public private(set) var port: NWEndpoint.Port
    
    public private(set) var status: Status = .suspend
    
    public var statusUpdateHandler: StatusUpdateHandler?
    
    public var receiveRequestHandler: ReceiveRequestHandler?
    
    private var listener: NWListener?
    
    private var connections: Dictionary<String, HTTPConnection> = [:]
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public init(port: NWEndpoint.Port) throws
    {
        self.port = port
        try self.setupListener()
    }
    
    public func start(queue: DispatchQueue = .main)
    {
        print("Starting service...")
        
        try? self.setupListener()
        self.listener?.stateUpdateHandler = self.serviceStateUpdate
        self.listener?.newConnectionHandler = self.connectionHandler
        
        self.listener?.start(queue: queue)
    }
    
    public func cancel()
    {
        print("Cancelling service...")
        
        self.connections.values.forEach({ $0.cancel() })
        self.connections.removeAll()
        self.listener?.cancel()
        self.listener = nil
    }
}

private extension HTTPService
{
    func setupListener() throws
    {
        guard self.listener == nil else {
            
            return
        }
        
        let listener = try NWListener(using: .tcp, on: self.port)
        
        self.listener = listener
    }
    
    func logState(_ state: NWListener.State)
    {
        switch state {
        
        case .setup:
            print("Service setup.")
            
        case .waiting(let error):
            print("Service waiting to start with error: \(error)")
            
        case .ready:
            print("Service is ready.")
            
        case .failed(let error):
            print("Failed to start service, error: \(error)")
            
        case .cancelled:
            print("Serivce is cancelled.")
            
        @unknown
        default:
            fatalError()
        }
    }
    
    func serviceStateUpdate(to state: NWListener.State)
    {
        self.logState(state)
        
        guard let handler: StatusUpdateHandler = self.statusUpdateHandler else {
            
            return
        }
        
        let status = Status(state)
        
        handler(status)
        
        self.status = status
    }
    
    func connectionHandler(_ connection: NWConnection)
    {
        let httpConnection = HTTPConnection(connection)
        httpConnection.receiveRequestHandler = self.receiveRequestHandler
        httpConnection.start(queue: self.listener?.queue ?? .main)
        
        self.connections[httpConnection.identifier] = httpConnection
    }
}
