//
//  HTTPStatus.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2021/9/8.
//

import Network

// MARK: - HTTPService.Status -

public extension HTTPService
{
    enum Status
    {
        case suspend
        
        case waitting(Error)
        
        case runing
        
        case failed(Error)
    }
}

public extension HTTPService.Status
{
    init(_ state: NWListener.State)
    {
        switch state {
        case .setup, .cancelled:
            self = .suspend
            
        case .ready:
            self = .runing
            
        case let .failed(error):
            self = .failed(error)
            
        case let .waiting(error):
            self = .waitting(error)
            
        @unknown default:
            fatalError()
        }
    }
}

extension HTTPService.Status: CustomStringConvertible
{
    public var description: String {
        
        var description: String
        
        switch self {
        case .suspend:
            description = "suspend"
            
        case .waitting:
            description = "waiting"
            
        case .runing:
            description = "runing"
            
        case .failed:
            description = "failed"
        }
        
        return description
    }
}

extension HTTPService.Status: Equatable
{
    public static func == (lhs: HTTPService.Status, rhs: HTTPService.Status) -> Bool
    {
        lhs.description == rhs.description
    }
}

// MARK: - HTTPConnection.State -

public extension HTTPConnection
{
    enum State
    {
        /// The initial state prior to start
        case setup
        
        /// Waiting connections have not yet been started, or do not have a viable network
        case waiting(NWError)
        
        /// Preparing connections are actively establishing the connection
        case preparing
        
        /// Ready connections can send and receive data
        case ready
        
        /// Failed connections are disconnected and can no longer send or receive data
        case failed(NWError)
        
        /// Cancelled connections have been invalidated by the client and will send no more events
        case cancelled
    }
}

public extension HTTPConnection.State
{
    init(_ state: NWConnection.State)
    {
        switch state {
        case .setup:
            self = .setup
            
        case let .waiting(error):
            self = .waiting(error)
            
        case .preparing:
            self = .preparing
            
        case .ready:
            self = .ready
            
        case let .failed(error):
            self = .failed(error)
            
        case .cancelled:
            self = .cancelled
            
        @unknown default:
            fatalError()
        }
    }
}

extension HTTPConnection.State: Equatable
{
    public static func == (lhs: HTTPConnection.State, rhs: HTTPConnection.State) -> Bool
    {
        var result: Bool = false
        
        switch (lhs, rhs) {
        case (.setup, .setup):
            result = true
            
        case let (.waiting(lError), .waiting(rError)) where lError == rError:
            result = true
            
        case (.preparing, .preparing):
            result = true
            
        case (.ready, .ready):
            result = true
            
        case let (.failed(lError), .failed(rError)) where lError == rError:
            result = true
            
        case (.cancelled, .cancelled):
            result = true
            
        default:
            result = false
        }
        
        return result
    }
}
