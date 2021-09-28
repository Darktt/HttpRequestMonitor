//
//  DetailViewModel.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2021/9/16.
//

import Foundation

public class DetailViewModel
{
    // MARK: - Properties -
    
    public var rootURL: URL? {
        
        self.request?.rootURL
    }
    
    public var isQuertItemsEmpty: Bool {
        
        self.queryItems.isEmpty
    }
    
    public private(set) var queryItems: Array<URLQueryItem> = []
    
    public private(set) var requestHeaders: Array<HTTPHeader> = []
    
    public private(set) var requestBody: String = ""
    
    private var request: HTTPMessage?
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public init()
    {
        
    }
    
    public func setRequest(_ request: HTTPMessage)
    {
        self.request = request
        
        self.resolveRequest()
    }
    
    public func queryItem(at indexPath: IndexPath) -> URLQueryItem?
    {
        let index: Int = indexPath.row
        
        guard self.queryItems.count > index else {
            
            return nil
        }
        
        let quertItem: URLQueryItem = self.queryItems[index]
        
        return quertItem
    }
    
    public func requestHeaders(at indexPath: IndexPath) -> HTTPHeader?
    {
        let index: Int = indexPath.row
        
        guard self.requestHeaders.count > index else {
            
            return nil
        }
        
        let header: HTTPHeader = self.requestHeaders[index]
        
        return header
    }
}

private extension DetailViewModel
{
    func resolveRequest()
    {
        let queryItems: Array<URLQueryItem> = {
            
            guard let url: URL = self.request?.requestURL,
                  let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
                  let queryItems: Array<URLQueryItem> = urlComponents.queryItems else {
                
                return []
            }
            
            return queryItems
        }()
        let headers: Array<HTTPHeader> = self.request?.httpHeaders().sorted() ?? []
        let body: String = {
            
            guard let data = self.request?.data,
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
