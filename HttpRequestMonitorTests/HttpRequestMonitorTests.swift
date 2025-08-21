//
//  HttpRequestMonitorTests.swift
//  HttpRequestMonitorTests
//
//  Created by Eden on 2025/8/21.
//

import XCTest
@testable import HttpRequestMonitor

public final
class HttpRequestMonitorTests: XCTestCase
{
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
    
    public override
    func setUpWithError() throws
    {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    public override
    func tearDownWithError() throws
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
    }
    
    public
    func testParseGetRequest()
    {
        guard let requestData: Data = self.getRequestDataString.data(using: .utf8) else {
            
            XCTAssert(false, "Create request data failed.")
            return
        }
        
        guard let message = HTTPMessage.request(withData: requestData) else {
            
            XCTAssert(false, "Create request failed.")
            return
        }
        
        let request = Request(message: message)
        
        XCTAssertTrue(request.requestMethod == .get, "Request not get method.")
        XCTAssertFalse(request.queryItems.isEmpty, "Quert items not empty.")
        
        // Check headers has 7 headers.
        XCTAssert(request.requestHeaders.count == 7, "Headers have not 7 headers.")
        
        // Check header has token field.
        let isContainedToken: Bool = request.requestHeaders.contains(where: { ($0.field == "token") && ($0.value == "1ABC20F8-F0A6-44B6-8DF4-2A0CA5498B0D") })
        
        XCTAssertTrue(isContainedToken, "Header have not token field.")
    }
    
    public
    func testGetRequestQueryItem()
    {
        guard let requestData: Data = self.getRequestDataString.data(using: .utf8) else {
            
            XCTAssert(false, "Create request data failed.")
            return
        }
        
        guard let message = HTTPMessage.request(withData: requestData) else {
            
            XCTAssert(false, "Create request failed.")
            return
        }
        
        let request = Request(message: message)
        
        if let queryItem: URLQueryItem = request.queryItems.first {
            
            // Check query has account field.
            let hasAccount: Bool = (queryItem.name == "account") && (queryItem.value == "some")
            
            XCTAssertTrue(hasAccount, "Query have not account field.")
        }
        
        if request.requestHeaders.count >= 6 {
            
            let header: HTTPHeader = request.requestHeaders[6]
            
            // Check header has token field.
            let isContainedToken: Bool = (header.field == "token") && (header.value == "1ABC20F8-F0A6-44B6-8DF4-2A0CA5498B0D")
            
            XCTAssertTrue(isContainedToken, "Header have not token field.")
        } else {
            
            XCTFail("Request header out of range.")
        }
    }
    
    public
    func testParsePostRequest()
    {
        guard let requestData: Data = self.postRequestDataString.data(using: .utf8) else {
            
            XCTFail("Create request data failed.")
            return
        }
        
        guard let message = HTTPMessage.request(withData: requestData) else {
            
            XCTAssert(false, "Create request failed.")
            return
        }
        
        let request = Request(message: message)
        
        XCTAssertTrue(request.requestMethod == .post, "Request not post method.")
        
        // Check headers has 8 headers.
        XCTAssert(request.requestHeaders.count == 8, "Headers have not 8 headers.")
        let body: String = request.requestBody
        
        guard let bodyData: Data = body.data(using: .utf8) else {
            
            // Check request body.
            XCTAssertFalse(request.requestBody.isEmpty, "Request body is empty.")
            return
        }
        
        do {
            
            let requestDictionary = try JSONDecoder().decode(Dictionary<String, String>.self, from: bodyData)
            let token: String = requestDictionary["token"] ?? ""
            
            XCTAssert(token == "1ABC20F8-F0A6-44B6-8DF4-2A0CA5498B0D", "Token not matched.")
            
        } catch {
            
            XCTFail("Parse request body failed with error: \(error)")
        }
    }
}

