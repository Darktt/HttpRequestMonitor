//
//  HttpRequestMonitorTests.swift
//  HttpRequestMonitorTests
//
//  Created by Eden on 2021/9/28.
//

import XCTest
import HttpRequestMonitor

public class HttpRequestMonitorTests: XCTestCase
{
    private var detailViewModel: DetailViewModel!
    
    private let getRequestDataString: String = """
            GET /login?account=some HTTP/1.1
            Host: localhost:3000
            Accept-Encoding: gzip, deflate
            Accept: */*
            User-Agent: Rested/2009 CFNetwork/1240.0.4 Darwin/20.6.0
            Accept-Language: zh-tw
            token: 1ABC20F8-F0A6-44B6-8DF4-2A0CA5498B0D
            Connection: keep-alive
            """
    
    private let postRequestDataString: String = """
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
    
    override public func setUpWithError() throws
    {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.detailViewModel = DetailViewModel()
    }
    
    override public func tearDownWithError() throws
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        self.detailViewModel = nil
    }
    
    public func testParseGetRequest()
    {
        guard let requestData: Data = self.getRequestDataString.data(using: .utf8) else {
            
            XCTAssert(false, "Create request data failed.")
            return
        }
        
        guard let request = HTTPMessage.request(withData: requestData) else {
            
            XCTAssert(false, "Create request failed.")
            return
        }
        
        XCTAssertTrue(request.requestMethod == .get, "Request not get method.")
        
        self.detailViewModel.setRequest(request)
        
        XCTAssertFalse(self.detailViewModel.isQuertItemsEmpty, "Quert items not empty.")
        
        // Check headers has 7 headers.
        XCTAssert(self.detailViewModel.requestHeaders.count == 7, "Headers have not 7 headers.")
        
        // Check header has token field.
        let isContainedToken: Bool = self.detailViewModel.requestHeaders.contains(where: { ($0.field == "token") && ($0.value == "1ABC20F8-F0A6-44B6-8DF4-2A0CA5498B0D") })
        
        XCTAssertTrue(isContainedToken, "Header have not token field.")
    }
    
    public func testGetRequestTableViewIndexPath()
    {
        guard let requestData: Data = self.getRequestDataString.data(using: .utf8) else {
            
            XCTAssert(false, "Create request data failed.")
            return
        }
        
        guard let request = HTTPMessage.request(withData: requestData) else {
            
            XCTAssert(false, "Create request failed.")
            return
        }
        
        self.detailViewModel.setRequest(request)
        
        var indexPath = IndexPath(row: 0, section: 0)
        
        if let queryItem: URLQueryItem = self.detailViewModel.queryItem(at: indexPath) {
            
            // Check query has account field.
            let hasAccount: Bool = (queryItem.name == "account") && (queryItem.value == "some")
            
            XCTAssertTrue(hasAccount, "Query have not account field.")
        }
        
        indexPath = IndexPath(row: 6, section: 1)
        
        if let header: HTTPHeader = self.detailViewModel.requestHeaders(at: indexPath) {
            
            // Check header has token field.
            let isContainedToken: Bool = (header.field == "token") && (header.value == "1ABC20F8-F0A6-44B6-8DF4-2A0CA5498B0D")
            
            XCTAssertTrue(isContainedToken, "Header have not token field.")
        } else {
            
            XCTFail("Request header out of range.")
        }
    }
    
    public func testParsePostRequest()
    {
        guard let requestData: Data = self.postRequestDataString.data(using: .utf8) else {
            
            XCTAssert(false, "Create request data failed.")
            return
        }
        
        guard let request = HTTPMessage.request(withData: requestData) else {
            
            XCTAssert(false, "Create request failed.")
            return
        }
        
        XCTAssertTrue(request.requestMethod == .post, "Request not post method.")
        
        self.detailViewModel.setRequest(request)
        
        XCTAssert(self.detailViewModel.isQuertItemsEmpty, "Quert items is empty.")
        
        // Check headers has 8 headers.
        XCTAssert(self.detailViewModel.requestHeaders.count == 8, "Headers have not 6 headers.")
        
        // Check request body.
        XCTAssertFalse(self.detailViewModel.requestBody.isEmpty, "Request body is empty.")
        
        if let bodyData: Data = request.data,
            let requestDictionary = try? JSONDecoder().decode(Dictionary<String, String>.self, from: bodyData),
            let token: String = requestDictionary["token"] {
            
            XCTAssert(token == "1ABC20F8-F0A6-44B6-8DF4-2A0CA5498B0D", "Token not matched.")
        } else {
            
            XCTFail("Parse request body failed.")
        }
    }
}
