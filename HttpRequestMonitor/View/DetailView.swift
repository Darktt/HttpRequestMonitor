//
//  DetailView.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2025/8/19.
//

import SwiftUI

public
struct DetailView: View
{
    // MARK: - Properties -
    
    public
    var request: Request?
    
    public
    var body: some View {
        
        if let request = self.request {
            
            self.requestView(with: request)
        } else {
            
            self.emptyView()
        }
    }
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public
    init(request: Request?)
    {
        self.request = request
    }
}

// MARK: - Private Methods -

private
extension DetailView
{
    func emptyView() -> some View
    {
        VStack(alignment: .center) {
            
            Text("No Request")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding()
        }
    }
    
    func requestView(with request: Request) -> some View
    {
        ScrollView {
            
            VStack(alignment: .leading, spacing: 10) {
                
                if !request.queryItems.isEmpty {
                    
                    self.queryItemView(with: request.queryItems)
                }
                
                if !request.requestHeaders.isEmpty {
                    
                    self.requestHeaderView(with: request.requestHeaders)
                }
                
                if !request.requestBody.isEmpty {
                    
                    self.bodyView(with: request.requestBody)
                }
            }
            .padding(EdgeInsets(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0))
        }
    }
    
    func queryItemView(with queryItems: Array<URLQueryItem>) -> some View
    {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Query Items")
                .font(.headline)
                .padding(.bottom, 5)
            
            Divider()
            
            ForEach(queryItems, id: \.self) {
                
                queryItem in
                
                Text("\(queryItem.name): \(queryItem.value ?? "")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    func requestHeaderView(with requestHeaders: Array<HTTPHeader>) -> some View
    {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Request Headers")
                .font(.headline)
                .padding(.vertical, 5)
            
            Divider()
            
            ForEach(requestHeaders) {
                
                header in
                
                Text("\(header.field): \(header.value)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    func bodyView(with body: String) -> some View
    {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Body")
                .font(.headline)
                .padding(.vertical, 5)
            
            Divider()
            
            Text(body)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview("DetailView (Empty)") {
    
    DetailView(request: nil)
}

#Preview("DetailView (GET)") {
    
    DetailView(request: kDummyRequests.first)
        .frame(minWidth: 300)
}

#Preview("DetailView (POST)") {
    
    DetailView(request: kDummyRequests.last)
        .frame(minWidth: 300)
}
