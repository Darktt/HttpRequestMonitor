//
//  Request.swift
//  Fluxo
//
//  Created by Eden on 2025/8/19.
//

import Foundation
import RegexBuilder

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
let kTextContentTypes: Set<String> = [
    
    "text/plain",
    "text/html",
    "text/css",
    "text/javascript",
    "application/json",
    "application/xml",
    "application/x-www-form-urlencoded"
]

public
let kImageContentTypes: Set<String> = [
    
    "image/png",
    "image/jpeg",
    "image/gif",
    "image/webp",
    "image/tiff",
    "image/heic"
]

public
let kFileContentTypes: Set<String> = [
    
    "application/pdf",
    "application/zip",
    "application/msword",
    "application/octet-stream",
    "application/vnd.ms-excel",
    "application/vnd.ms-powerpoint",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    "audio/mpeg",
    "audio/wav",
    "audio/ogg",
    "video/mp4",
    "video/mpeg",
    "video/quicktime",
    "video/webm",
    "video/avi",
    kFormData
]

private
let kFormData = "multipart/form-data"

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
    
    public
    var contentType: String? {
        
        self.message.contentType
    }
    
    public
    var hasBody: Bool {
        
        var hasBody: Bool = (self.message.body != nil)
        hasBody = hasBody || (self.bodyPath != nil)
        
        return hasBody
    }
    
    public private(set)
    var requestBody: String = ""
    
    public
    var bodyPath: URL? {
        
        self.message.bodyPath
    }
    
    public
    var fromParts: Array<FormPart> = []
    
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
        let message = HTTPMessage()
        message.appendData(requestData)
        
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
        let queryItems: Array<URLQueryItem> = self.message.queryItems
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
        self.parseFromData()
    }
    
    mutating
    func parseFromData()
    {
        guard var contentType: String = self.message.contentType,
                let path = self.bodyPath else {
            
            return
        }
        
        var boundary: String = ""
        
        if contentType.contains("; ") {
            
            let components: Array<String> = contentType.components(separatedBy: "; ")
            let regex = "boundary=".regex
            
            contentType = components.first!
            boundary = String(components.last?.trimmingPrefix(regex) ?? "")
        }
        
        if contentType == kFormData {
            
            do {
                
                let formData = try FormData(path: path, boundary: boundary)
                let parts: Array<FormPart> = formData.parts
                
                self.fromParts = parts
            } catch {
                
                print("Parse form data error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Identifiable Conformance -

extension Request: Identifiable {}

extension Request: Equatable
{
    public static
    func == (lhs: Request, rhs: Request) -> Bool
    {
        lhs.id == rhs.id
    }
}
