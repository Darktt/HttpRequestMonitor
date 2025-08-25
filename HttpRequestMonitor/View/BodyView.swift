//
//  BodyView.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2025/8/25.
//

import SwiftUI

public
struct BodyView: View
{
    public
    var request: Request
    
    private
    var path: URL? {
        
        self.request.bodyPath
    }
    
    private
    var bodyString: String? {
        
        self.request.requestBody
    }
    
    public
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Body")
                .font(.headline)
                .padding(.vertical, 5)
            
            Divider().background(Color.accentColor.opacity(0.18))
            
            self.contentView()
        }
        .padding(10)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private
extension BodyView
{
    func contentView() -> some View
    {
        if let body = self.bodyString.and({ !$0.isEmpty }) {
            
            let view = BodyView.TextContent(bodyString: body)
            
            return view.eraseToAnyView
        }
        
        guard let path = self.path else {
            
            return EmptyView().eraseToAnyView
        }
        
        let view = BodyView.ImageContent(path: path)
        
        return view.eraseToAnyView
    }
}

// MARK: - BodyView.ImageView -

fileprivate
extension BodyView
{
    struct ImageContent: View
    {
        let path: URL
        
        var body: some View {
            
            if let image = NSImage(contentsOf: self.path) {
            
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 200)
            } else {
                
                BodyView.TextContent(bodyString: "Unable to load image.")
            }
        }
    }
}

// MARK: - BodyView.TextContent -

fileprivate
extension BodyView
{
    struct TextContent: View
    {
        let bodyString: String
        
        var body: some View {
            
            Text(self.bodyString)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
