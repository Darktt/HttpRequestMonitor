//
//  HTTPMessage.swift
//
//  Created by Eden on 2021/8/23.
//

import Foundation

public
class HTTPMessage
{
    // MARK: - Properties -
    
    public
    let id: UUID = UUID()
    
    public
    var requestURL: URL? {
        
        let url: URL? = CFHTTPMessageCopyRequestURL(self.message)
                            .map({ $0.takeRetainedValue() as URL })
        
        return url
    }
    
    public
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
    
    public
    var requestMethod: HTTPMethod? {
        
        let method: HTTPMethod? = CFHTTPMessageCopyRequestMethod(self.message).flatMap {
            
            let rawValue: String = $0.takeRetainedValue() as String
            let method = HTTPMethod(rawValue: rawValue)
            
            return method
        }
        
        return method
    }
    
    public
    var isHeadersComplete: Bool {
        
        let isHeaderComplete: Bool = CFHTTPMessageIsHeaderComplete(self.message)
        
        return isHeaderComplete
    }
    
    public
    var contentType: String? {
        
        self.httpHeaders()
            .first(where: { $0.field == "Content-Type" })
            .flatMap({ $0.value })
    }
    
    public
    var contentSize: Double {
        
        self.httpHeaders()
            .first(where: { $0.field == "Content-Length" })
            .flatMap({ Double($0.value) }) ?? 0.0
    }
    
    public
    var body: Data? {
        
        let data: Data? = CFHTTPMessageCopyBody(self.message)
                                .map({ $0.takeRetainedValue() as Data })
        
        return data
    }
    
    public
    var bodyPath: URL?
    
    public
    var isComplete: Bool {
        
        if self.isContentTypeNotText() {
            
            return self.bodyPath != nil
        }
        
        guard let body = self.body else {
            
            return false
        }
        
        let contentSize: Double = self.contentSize
        
        return Double(body.count) >= contentSize
    }
    
    internal
    var data: Data? {
        
        let data: Data? = CFHTTPMessageCopySerializedMessage(self.message)
                                .map({ $0.takeRetainedValue() as Data })
        
        return data
    }
    
    private
    var message: CFHTTPMessage
    
    private
    lazy var fileHandler: FileHandle? = {
        
        let fileManager = FileManager.default
        let tempDirectory: URL = fileManager.temporaryDirectory
        let filePath: URL = tempDirectory.appendingPathComponent("http_message_body_\(self.id.uuidString).tmp")
        
        do {
            
            fileManager.createFile(atPath: filePath.path(), contents: nil)
            let fileHandler = try FileHandle(forWritingTo: filePath)
            
            return fileHandler
        } catch {
            
            print("Failed to create file handler with error: \(error)")
            
            return nil
        }
    }()
    
    // MARK: - Initializers -
    
    public static
    func response(statusCode: StatusCode, htmlString: String) -> HTTPMessage
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let dateString = dateFormatter.string(from: Date())
        let htmlData = htmlString.data(using: .utf8) ?? Data()
        let contentLength: Int = htmlData.count
        
        var httpHeaders: Array<HTTPHeader> = []
        httpHeaders.append(HTTPHeader(field: "Date", value: dateString))
        httpHeaders.append(HTTPHeader(field: "Server", value: "Swift HTTP Server"))
        httpHeaders.append(HTTPHeader(field: "Connection", value: "close"))
        httpHeaders.append(HTTPHeader.contentType("text/html; charset=utf-8"))
        httpHeaders.append(HTTPHeader(field: "Content-Length", value: "\(contentLength)"))
        
        let message: CFHTTPMessage = CFHTTPMessageCreateResponse(kCFAllocatorDefault, statusCode.rawValue, statusCode.description as CFString, kCFHTTPVersion1_1).takeRetainedValue()
        let httpMessage = HTTPMessage(message)
        httpMessage.setHttpHeaders(httpHeaders)
        httpMessage.setBody(htmlData)
        
        return httpMessage
    }
    
    public
    init()
    {
        let message: CFHTTPMessage = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, true).takeRetainedValue()
        
        self.message = message
    }
    
    private
    init(_ message: CFHTTPMessage)
    {
        self.message = message
    }
    
    @discardableResult
    func appendData(_ data: Data) -> Bool
    {
        if self.isHeadersComplete && self.isContentTypeNotText() {
            
            self.writeToFile(with: data)
            return true
        }
        
        let bytes: Array = Array(data)
        let result: Bool = CFHTTPMessageAppendBytes(self.message, bytes, data.count)
        
        if self.isContentTypeNotText() {
            
            self.writeToFile(with: self.body)
        }
        
        return result
    }
    
    func setBody(_ data: Data?)
    {
        guard let data = data else {
            
            return
        }
        
        CFHTTPMessageSetBody(self.message, data as CFData)
    }
    
    func httpHeaders() -> Array<HTTPHeader>
    {
        guard let allHTTPHeaderFields: Dictionary = CFHTTPMessageCopyAllHeaderFields(self.message)
                .flatMap({ $0.takeRetainedValue() as? Dictionary<String, String> }) else {
            
            return []
        }
        
        let headers: Array<HTTPHeader> = HTTPHeader.dictionary(allHTTPHeaderFields)
        
        return headers
    }
    
    func value(forHeadField headField: String) -> String?
    {
        let value: String? = CFHTTPMessageCopyHeaderFieldValue(self.message, headField as CFString)
                                .map({ $0.takeRetainedValue() as String })
        
        return value
    }
    
    func setValue(_ value: String?, forHeadField headField: String)
    {
        CFHTTPMessageSetHeaderFieldValue(self.message, headField as CFString, value as CFString?)
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

// MARK: - Private Methods -

private
extension HTTPMessage
{
    func isContentTypeNotText() -> Bool
    {
        let isNotText = (self.contentType.and({ !$0.hasPrefix("text/") }) != nil)
        
        return isNotText
    }
    
    func writeToFile(with bodyData: Data?)
    {
        guard let fileHandler = self.fileHandler, let data = bodyData else {
            
            return
        }
        
        do {
            
            var currentSize: UInt64 = try fileHandler.seekToEnd()
            currentSize += UInt64(data.count)
            try fileHandler.write(contentsOf: data)
            try fileHandler.synchronize()
            
            if Double(currentSize) >= self.contentSize {
                
                try fileHandler.close()
                let fileUrl: URL = try self.moveToCatch()
                
                self.bodyPath = fileUrl
            }
            
        } catch {
            
            print("Failed wirte to file with error: \(error)")
        }
    }
    
    func moveToCatch() throws -> URL
    {
        let fileName: String = "http_message_body_\(self.id.uuidString).tmp"
        
        let fileManager = FileManager.default
        let tempDirectory: URL = fileManager.temporaryDirectory
        let filePath: URL = tempDirectory.appendingPathComponent(fileName)
        let catcheDirectory: URL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let destnationPath: URL = catcheDirectory.appendingPathComponent(fileName)
        
        try fileManager.moveItem(at: filePath, to: destnationPath)
        
        return destnationPath
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
            description = "Continue"
            
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
            description = "Partial Content"
            
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
