//
//  HTTPHeader.swift
//
//  Created by Darktt on 19/5/28.
//  Copyright © 2019 Darktt. All rights reserved.
//

import Foundation

// MARK: - HTTPHeader -

public struct HTTPHeader
{
    // MARK: - Properties -
    
    public let field: String
    
    public let value: String
    
    // MARK: - Methods -
    
    public static func accept(_ value: String) -> HTTPHeader
    {
        let header = HTTPHeader(field: "Accept", value: value)
        
        return header
    }
    
    public static func acceptCharset(_ value: String) -> HTTPHeader
    {
        let header = HTTPHeader(field: "Accept-Charset", value: value)
        
        return header
    }
    
    public static func acceptEncoding(_ value: String) -> HTTPHeader
    {
        let header = HTTPHeader(field: "Accept-Encoding", value: value)
        
        return header
    }
    
    public static func acceptLanguage(_ value: String) -> HTTPHeader
    {
        let header = HTTPHeader(field: "Accept-Language", value: value)
        
        return header
    }
    
    public static func authorization(username: String, password: String) -> HTTPHeader
    {
        let value: String = "\(username):\(password)"
        let token: String = value.data(using: .utf8)!.base64EncodedString()
        let header = HTTPHeader.authorization(token: token, type: .basic)
        
        return header
    }
    
    public static func authorization(token: String, type: AuthorizationType) -> HTTPHeader
    {
        let credential: String = "\(type) " + token
        let header = HTTPHeader.authorization(credential)
        
        return header
    }
    
    public static func authorization(_ value: String) -> HTTPHeader
    {
        let header = HTTPHeader(field: "Authorization", value: value)
        
        return header
    }
    
    public static func contentDisposition(_ value: String, fileName: String? = nil) -> HTTPHeader
    {
        var newValue: String = value
        
        if let fileName = fileName {
            
            newValue += "; filename=\"" + fileName + "\""
        }
        
        let header = HTTPHeader(field: "Content-Disposition", value: newValue)
        
        return header
    }
    
    public static func contentType(_ value: String) -> HTTPHeader
    {
        let header = HTTPHeader(field: "Content-Type", value: value)
        
        return header
    }
    
    public static func userAgent(_ value: String) -> HTTPHeader
    {
        let header = HTTPHeader(field: "User-Agent", value: value)
        
        return header
    }
    
    public static func dictionary<Key, Value>(_ dictionary: Dictionary<Key, Value>) -> Array<HTTPHeader> where Key: StringProtocol, Value: StringProtocol
    {
        let headers: Array<HTTPHeader> = dictionary.map(HTTPHeader.init)
        
        return headers
    }
    
    // MARK: Initial Method
    
    public init(field: String, value: String)
    {
        self.field = field
        self.value = value
    }
    
    private init<Key, Value>(_ keyValue: (key: Key, value: Value)) where Key: StringProtocol, Value: StringProtocol
    {
        self.field = keyValue.key.description
        self.value = keyValue.value.description
    }
}

// MARK: - AuthorizationType -

/// The general HTTP authentication framework is used by several authentication schemes. Schemes can differ in security strength and in their availability in client or server software.
///
/// The most common authentication scheme is the "Basic" authentication scheme which is introduced in more details below. IANA maintains a list of authentication schemes, but there are other schemes offered by host services, such as Amazon AWS. Common authentication schemes include:
///
/// - basic: Base64-encoded credentials. See below for more information. (see: [RFC 7617](https://tools.ietf.org/html/rfc7617))
/// - bearer: Bearer tokens to access OAuth 2.0-protected resources. (see: [RFC 6750](https://tools.ietf.org/html/rfc6750))
/// - digest: Only md5 hashing is supported in Firefox, see [bug 472823](https://bugzilla.mozilla.org/show_bug.cgi?id=472823) for SHA encryption support. (see: [RFC 7616](https://tools.ietf.org/html/rfc7616))
/// - hoba: **H**TTP **O**rigin-**B**ound **A**uthentication, digital-signature-based. (see: [RFC 7486](https://tools.ietf.org/html/rfc7486), Section 3)
/// - mutual: See: [RFC 8120](https://tools.ietf.org/html/rfc8120)
/// - awsSignature: See: [AWS docs](https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-auth-using-authorization-header.html)
/// - custom: Define custom authorization type.
public enum AuthorizationType
{
    /// Base64-encoded credentials. See below for more information.
    /// - SeeAlso: [RFC 7617](https://tools.ietf.org/html/rfc7617)
    case basic
    
    /// Bearer tokens to access OAuth 2.0-protected resources.
    /// - SeeAlso: [RFC 6750](https://tools.ietf.org/html/rfc6750))
    case bearer
    
    /// Only md5 hashing is supported in Firefox, see [bug 472823](https://bugzilla.mozilla.org/show_bug.cgi?id=472823) for SHA encryption support. (see: [RFC 7616](https://tools.ietf.org/html/rfc7616))
    case digest
    
    /// **H**TTP **O**rigin-**B**ound **A**uthentication, digital-signature-based.
    /// - SeeAlso: [RFC 7486](https://tools.ietf.org/html/rfc7486), Section 3
    case hoba
    
    /// - SeeAlso: [RFC 8120](https://tools.ietf.org/html/rfc8120)
    case mutual
    
    /// Amazon Web Services signature.
    ///
    /// - SeeAlso: [AWS docs](https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-auth-using-authorization-header.html)
    case awsSignature
    
    /// Define custom authorization type.
    case custom(_ otherType: String)
}

extension AuthorizationType: CustomStringConvertible
{
    public var description: String {
        
        let description: String!
        
        switch self {
        case .basic:
            description = "Basic"
            
        case .bearer:
            description = "Bearer"
            
        case .digest:
            description = "Digest"
            
        case .hoba:
            description = "HOBA"
            
        case .mutual:
            description = "Mutual"
            
        case .awsSignature:
            description = "AWS4-HMAC-SHA256"
            
        case let .custom(otherType):
            description = otherType
        }
        
        return description
    }
}

// MARK: - HTTPHeaderBuilder -

@resultBuilder
public struct HTTPHeaderBuilder
{
    public static func buildBlock(_ header: HTTPHeader) -> Dictionary<String, String>
    {
        return [header.field: header.value]
    }
    
    public static func buildBlock(_ headers: HTTPHeader...) -> Dictionary<String, String>
    {
        return headers.dictionary()
    }
}

// MARK: - Other extensions -

public extension Sequence where Element == HTTPHeader
{
    // MARK: - Methods -
    
    func dictionary() -> Dictionary<String, String>
    {
        let fieldsAndValues: Array<(String, String)> = self.map { ($0.field, $0.value) }
        let dictionary = Dictionary(fieldsAndValues) { $1 }
        
        return dictionary
    }
}

extension Array where Element == HTTPHeader
{
    var description: String {
        
        let description = self.reduce("") { $0 + $1.field + "=" + $1.value + ";" }
        
        return description
    }
    
    func sorted() -> Array
    {
        self.sorted {
            
            $0.field < $1.field
        }
    }
}
