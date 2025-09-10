//
//  DetailView.swift
//  Fluxo
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
        
        ZStack {
            
            Color(NSColor.controlBackgroundColor).opacity(0.85)
            
            Group {
                
                if let request = self.request {
                    
                    self.requestView(with: request)
                    
                } else {
                    
                    self.emptyView()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 1)
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
        VStack(alignment: .center, spacing: 0.0) {
            
            Spacer(minLength: 40)
            
            Image(systemName: "network")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.secondary.opacity(0.4))
            
            VStack(spacing: 8) {
                
                Text("No Request Selected")
                    .font(.headline)
                    .foregroundColor(.secondary.opacity(0.4))
                    .padding()
            }
            
            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func requestView(with request: Request) -> some View
    {
        ScrollView {
            
            VStack(alignment: .leading, spacing: 18) {
                
                if !request.queryItems.isEmpty {
                    
                    self.queryItemView(with: request.queryItems)
                }
                
                if !request.requestHeaders.isEmpty {
                    
                    self.requestHeaderView(with: request.requestHeaders)
                }
                
                if request.hasBody {
                    
                    BodyView(request: request)
                }
            }
            .padding(18)
        }
    }
    
    func queryItemView(with queryItems: Array<URLQueryItem>) -> some View
    {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Query Items")
                .font(.headline)
                .padding(.bottom, 5)
            
            Divider().background(Color.accentColor.opacity(0.18))
            
            ForEach(queryItems, id: \.self) {
                
                queryItem in
                
                Text("\(queryItem.name): \(queryItem.value ?? "")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    
    func requestHeaderView(with requestHeaders: Array<HTTPHeader>) -> some View
    {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Request Headers")
                .font(.headline)
                .padding(.vertical, 5)
            
            Divider().background(Color.accentColor.opacity(0.18))
            
            ForEach(requestHeaders) {
                
                header in
                
                Text("\(header.field): \(header.value)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    
    func bodyView(withImagePath path: URL) -> some View
    {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Body")
                .font(.headline)
                .padding(.vertical, 5)
            
            Divider().background(Color.accentColor.opacity(0.18))
            
            if let image = NSImage(contentsOf: path) {
            
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 200)
            } else {
                
                Text("Unable to load image.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    
    func bodyView(with body: String) -> some View
    {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Body")
                .font(.headline)
                .padding(.vertical, 5)
            
            Divider().background(Color.accentColor.opacity(0.18))
            
            Text(body)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
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
