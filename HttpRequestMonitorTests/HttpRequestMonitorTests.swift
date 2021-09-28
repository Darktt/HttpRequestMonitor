//
//  HttpRequestMonitorTests.swift
//  HttpRequestMonitorTests
//
//  Created by Eden on 2021/9/28.
//

import XCTest
import HttpRequestMonitor

class HttpRequestMonitorTests: XCTestCase
{
    
    override func setUpWithError() throws
    {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws
    {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() throws
    {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testParseGetRequest()
    {
        let requestDataString = """
            GET /login?accound=some HTTP/1.1
            Host: localhost:3000
            Accept-Encoding: gzip, deflate
            Accept: */*
            User-Agent: Rested/2009 CFNetwork/1240.0.4 Darwin/20.6.0
            Accept-Language: zh-tw
            token: 1ABC20F8-F0A6-44B6-8DF4-2A0CA5498B0D
            Connection: keep-alive
            """
        
        guard let requestData: Data = requestDataString.data(using: .utf8) else {
            
            XCTAssert(false, "Create request data failed.")
            return
        }
        
        guard let request = HTTPMessage.request(withData: requestData) else {
            
            XCTAssert(false, "Create request failed.")
            return
        }
        
        let detailViewModel = DetailViewModel()
        detailViewModel.setRequest(request)
        
        // Check query items have only one item.
        XCTAssert(detailViewModel.queryItems.count == 1, "Quert items have not one item.")
        
        // Check headers has 7 headers.
        XCTAssert(detailViewModel.requestHeaders.count == 7, "Headers have not 7 headers.")
        
        // Check header has token field.
        let isContainedToken: Bool = detailViewModel.requestHeaders.contains(where: { $0.field == "token" && $0.value == "1ABC20F8-F0A6-44B6-8DF4-2A0CA5498B0D" })
        
        XCTAssertTrue(isContainedToken, "Header have not token field.")
    }
}
