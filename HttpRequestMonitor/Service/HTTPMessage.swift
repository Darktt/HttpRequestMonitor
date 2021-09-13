//
//  HTTPMessage.swift
//  WEBServiceDemo
//
//  Created by Eden on 2021/8/23.
//

import Foundation

public typealias HTTPMessage = CFHTTPMessage

public extension HTTPMessage
{
    // MARK: - Properties -
    
    var requestURL: URL? {
        
        let url: URL? = CFHTTPMessageCopyRequestURL(self).map({ $0.takeRetainedValue() as URL })
        
        return url
    }
    
    var rootURL: URL? {
        
        guard let requestURL: URL = self.requestURL,
              let scheme: String = requestURL.scheme,
              let host: String = requestURL.host,
              let port: Int = requestURL.port else {
            
            return nil
        }
        
        let rootURL = URL(string: "\(scheme)://\(host):\(port)")
        
        return rootURL
    }
    
    var requestMethod: HTTPMethod? {
        
        let method: HTTPMethod? = CFHTTPMessageCopyRequestMethod(self).flatMap {
            
            let rawValue: String = $0.takeRetainedValue() as String
            let method = HTTPMethod(rawValue: rawValue)
            
            return method
        }
        
        return method
    }
    
    var data: Data? {
        
        let data: Data? = CFHTTPMessageCopyBody(self).map({ $0.takeRetainedValue() as Data })
        
        return data
    }
    
    // MARK: - Methods -
    
    static func request(withData data: Data) -> HTTPMessage?
    {
        let message: HTTPMessage = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, true).takeRetainedValue()
        let bytes: Array = Array(data)
        let result: Bool = CFHTTPMessageAppendBytes(message, bytes, data.count)
        
        return result ? message : nil
    }
    
    static func response(statusCode: StatusCode, htmlString: String) -> HTTPMessage
    {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let dateString = dateFormatter.string(from: Date())
        
        var httpHeaders: Array<HTTPHeader> = []
        httpHeaders.append(HTTPHeader(field: "Date", value: dateString))
        httpHeaders.append(HTTPHeader(field: "Server", value: "Swift HTTP Server"))
        httpHeaders.append(HTTPHeader(field: "Connection", value: "close"))
        httpHeaders.append(HTTPHeader.contentType("text/html"))
        httpHeaders.append(HTTPHeader(field: "Content-Length", value: "\(htmlString.count)"))
        
        let body: Data? = htmlString.data(using: .utf8)
        
        let message: HTTPMessage = CFHTTPMessageCreateResponse(kCFAllocatorDefault, statusCode.rawValue, statusCode.description as CFString, kCFHTTPVersion1_1).takeRetainedValue()
        message.setHttpHeaders(httpHeaders)
        message.setBody(body)
        
        return message
    }
    
    func setBody(_ data: Data?)
    {
        guard let data = data else {
            
            return
        }
        
        CFHTTPMessageSetBody(self, data as CFData)
    }
    
    func httpHeaders() -> Array<HTTPHeader>
    {
        guard let allHTTPHeaderFields: Dictionary = CFHTTPMessageCopyAllHeaderFields(self).flatMap({ $0.takeRetainedValue() as? Dictionary<String, String> }) else {
            
            return []
        }
        
        let headers: Array<HTTPHeader> = HTTPHeader.dictionary(allHTTPHeaderFields)
        
        return headers
    }
    
    func value(forHeadField headField: String) -> String?
    {
        let value: String? = CFHTTPMessageCopyHeaderFieldValue(self, headField as CFString).map({ $0.takeRetainedValue() as String })
        
        return value
    }
    
    func setValue(_ value: String?, forHeadField headField: String)
    {
        CFHTTPMessageSetHeaderFieldValue(self, headField as CFString, value as CFString?)
    }
    
    func setValue(by header: HTTPHeader)
    {
        self.setValue(header.value, forHeadField: header.field)
    }
    
    func setHttpHeaders(_ httpHeaders: Array<HTTPHeader>)
    {
        httpHeaders.forEach(self.setValue)
    }
}

// MARK: - HTTPMessage.StatusCode -

public extension HTTPMessage
{
    enum StatusCode: Int
    {
        // 100 Informational
        case `continue` = 100
        
        case switchingProtocols
        
        case processing
        
        // 200 Success
        case ok = 200
        
        case created
        
        case accepted
        
        case nonAuthoritativeInformation
        
        case noContent
        
        case resetContent
        
        case partialContent
        
        case multiStatus
        
        case alreadyReported
        
        case iMUsed = 226
        
        // 300 Redirection
        case multipleChoices = 300
        
        case movedPermanently
        
        case found
        
        case seeOther
        
        case notModified
        
        case useProxy
        
        case switchProxy
        
        case temporaryRedirect
        
        case permanentRedirect
        
        // 400 Client Error
        case badRequest = 400
        
        case unauthorized
        
        case paymentRequired
        
        case forbidden
        
        case notFound
        
        case methodNotAllowed
        
        case notAcceptable
        
        case proxyAuthenticationRequired
        
        case requestTimeout
        
        case conflict
        
        case gone
        
        case lengthRequired
        
        case preconditionFailed
        
        case payloadTooLarge
        
        case uriTooLong
        
        case unsupportedMediaType
        
        case rangeNotSatisfiable
        
        case expectationFailed
        
        case imATeapot
        
        case misdirectedRequest = 421
        
        case unprocessableEntity
        
        case locked
        
        case failedDependency
        
        case upgradeRequired = 426
        
        case preconditionRequired = 428
        
        case tooManyRequests
        
        case requestHeaderFieldsTooLarge = 431
        
        case unavailableForLegalReasons = 451
        
        // 500 Server Error
        case internalServerError = 500
        
        case notImplemented
        
        case badGateway
        
        case serviceUnavailable
        
        case gatewayTimeout
        
        case httpVersionNotSupported
        
        case variantAlsoNegotiates
        
        case insufficientStorage
        
        case loopDetected
        
        case notExtended = 510
        
        case networkAuthenticationRequired
    }
}

extension HTTPMessage.StatusCode: CustomStringConvertible
{
    public var description: String {
        
        let description: String
        
        switch self {
            
        case .`continue`:
            description = "Countiune"
            
        case .switchingProtocols:
            description = "Switching Protocols"
            
        case .processing:
            description = "Processing"
            
        case .ok:
            description = "OK"
            
        case .created:
            description = "Created"
            
        case .accepted:
            description = "Accepted"
            
        case .nonAuthoritativeInformation:
            description = "Non Authoritative Information"
            
        case .noContent:
            description = "No Content"
            
        case .resetContent:
            description = "Reset Content"
            
        case .partialContent:
            description = "Rartial Content"
            
        case .multiStatus:
            description = "Multi Status"
            
        case .alreadyReported:
            description = "Already Reported"
            
        case .iMUsed:
            description = "IM Used"
            
        case .multipleChoices:
            description = "Multiple Choices"
            
        case .movedPermanently:
            description = "Moved Permanently"
            
        case .found:
            description = "Found"
            
        case .seeOther:
            description = "See Other"
            
        case .notModified:
            description = "Not Modified"
            
        case .useProxy:
            description = "Use Proxy"
            
        case .switchProxy:
            description = "Switch Proxy"
            
        case .temporaryRedirect:
            description = "Temporary Redirect"
            
        case .permanentRedirect:
            description = "Permanent Redirect"
            
        case .badRequest:
            description = "Bad Request"
            
        case .unauthorized:
            description = "Unauthorized"
            
        case .paymentRequired:
            description = "Payment Required"
            
        case .forbidden:
            description = "Forbidden"
            
        case .notFound:
            description = "Not Found"
            
        case .methodNotAllowed:
            description = "Method Not Allowed"
            
        case .notAcceptable:
            description = "Not Acceptable"
            
        case .proxyAuthenticationRequired:
            description = "Proxy Authentication Required"
            
        case .requestTimeout:
            description = "Request Timeout"
            
        case .conflict:
            description = "Conflict"
            
        case .gone:
            description = "Gone"
            
        case .lengthRequired:
            description = "Length Required"
            
        case .preconditionFailed:
            description = "Precondition Failed"
            
        case .payloadTooLarge:
            description = "Payload Too Large"
            
        case .uriTooLong:
            description = "URI Too Long"
            
        case .unsupportedMediaType:
            description = "Unsupported Media Type"
            
        case .rangeNotSatisfiable:
            description = "Range Not Satisfiable"
            
        case .expectationFailed:
            description = "ExpectationFailed"
            
        case .imATeapot:
            description = "I'm a teapot"
            
        case .misdirectedRequest:
            description = "Misdirected Request"
            
        case .unprocessableEntity:
            description = "Unprocessable Entity"
            
        case .locked:
            description = "Locked"
            
        case .failedDependency:
            description = "Failed Dependency"
            
        case .upgradeRequired:
            description = "Upgrade Required"
            
        case .preconditionRequired:
            description = "Precondition Required"
            
        case .tooManyRequests:
            description = "Too Many Requests"
            
        case .requestHeaderFieldsTooLarge:
            description = "Request Header Fields Too Large"
            
        case .unavailableForLegalReasons:
            description = "Unavailable For Legal Reasons"
            
        case .internalServerError:
            description = "Internal Server Error"
            
        case .notImplemented:
            description = "Not Implemented"
            
        case .badGateway:
            description = "Bad Gateway"
            
        case .serviceUnavailable:
            description = "Service Unavailable"
            
        case .gatewayTimeout:
            description = "Gateway Timeout"
            
        case .httpVersionNotSupported:
            description = "Http Version Not Supported"
            
        case .variantAlsoNegotiates:
            description = "Variant Also Negotiates"
            
        case .insufficientStorage:
            description = "Insufficient Storage"
            
        case .loopDetected:
            description = "Loop Detected"
            
        case .notExtended:
            description = "Not Extended"
            
        case .networkAuthenticationRequired:
            description = "Network Authentication Required"
        }
        
        return description
    }
}
