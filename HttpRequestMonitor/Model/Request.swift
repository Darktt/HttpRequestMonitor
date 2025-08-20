//
//  Request.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2025/8/19.
//

import Foundation

private
let kGetRequestDataString: String = """
    GET /login?account=some HTTP/1.1
    Host: localhost:3000
    Accept-Encoding: gzip, deflate
    Accept: */*
    User-Agent: Rested/2009 CFNetwork/1240.0.4 Darwin/20.6.0
    Accept-Language: zh-tw
    token: 1ABC20F8-F0A6-44B6-8DF4-2A0CA5498B0D
    Connection: keep-alive
    """

private
let kPostRequestDataString: String = """
    POST /account HTTP/1.1
    Host: localhost:3000
    Content-Type: application/json
    Connection: keep-alive
    Accept: */*
    User-Agent: Rested/2009 CFNetwork/1240.0.4 Darwin/20.6.0
    Accept-Language: zh-tw
    Accept-Encoding: gzip, deflate
    Content-Length: 53
    
    {
      "token": "1ABC20F8-F0A6-44B6-8DF4-2A0CA5498B0D"
    }
    """

public
let kDummyRequests: Array<Request> = [
    
    Request(dataString: kGetRequestDataString),
    Request(dataString: kPostRequestDataString)
]

public
struct Request
{
    // MARK: - Properties -
    
    public
    let id: UUID = UUID()
    
    public
    var rootUrl: String {
        
        self.message.rootURL?.absoluteString ?? ""
    }
    
    public
    var requestMethod: String {
        
        self.message.requestMethod?.rawValue ?? ""
    }
    
    public private(set)
    var queryItems: Array<URLQueryItem> = []
    
    public private(set)
    var requestHeaders: Array<HTTPHeader> = []
    
    public private(set)
    var requestBody: String = ""
    
    private
    let message: HTTPMessage
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public
    init(message: HTTPMessage)
    {
        self.message = message
        self.parseMessage()
    }
    
    fileprivate
    init(dataString: String)
    {
        let requestData: Data = dataString.data(using: .utf8)!
        let message = HTTPMessage.request(withData: requestData)!
        
        self.message = message
        self.parseMessage()
    }
}

// MARK: - Private Methods -

private
extension Request
{
    mutating
    func parseMessage()
    {
        let queryItems: Array<URLQueryItem> = {
            
            guard let url: URL = self.message.requestURL,
                  let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
                  let queryItems: Array<URLQueryItem> = urlComponents.queryItems else {
                
                return []
            }
            
            return queryItems
        }()
        let headers: Array<HTTPHeader> = self.message.httpHeaders().sorted()
        let body: String = {
            
            guard let data = self.message.body,
                  let bodyString: String = String(data: data, encoding: .utf8) else {
                
                return ""
            }
            
            return bodyString
        }()
        
        self.queryItems = queryItems
        self.requestHeaders = headers
        self.requestBody = body
    }
}

// MARK: - Identifiable Conformance -

extension Request: Identifiable {}
