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
        guard var contentType: String = self.request.contentType else {
            
            return EmptyView().eraseToAnyView
        }
        
        if contentType.contains("; ") {
            
            let components: Array<String> = contentType.components(separatedBy: ";")
            contentType = components.first!
        }
        
        if kTextContentTypes.contains(contentType),
            let body = self.bodyString.and({ !$0.isEmpty }) {
            
            let view = BodyView.TextContent(bodyString: body)
            
            return view.eraseToAnyView
        }
        
        guard let path: URL = self.path else {
            
            return EmptyView().eraseToAnyView
        }
        
        if kImageContentTypes.contains(contentType) {
            
            let view = BodyView.ImageContent(path: path)
            
            return view.eraseToAnyView
        }
        
        if kFileContentTypes.contains(contentType) {
            
            if !self.request.fromParts.isEmpty {
                
                let view = BodyView.FormDataContent(parts: self.request.fromParts)
                
                return view.eraseToAnyView
            }
            
            let view = BodyView.FileContent(path: path)
            
            return view.eraseToAnyView
        }
        
        return EmptyView().eraseToAnyView
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

// MARK: - BodyView.ImageContent -

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

// MARK: - BodyView.FileContent -

fileprivate
extension BodyView
{
    struct FileContent: View
    {
        let path: URL
        
        var body: some View {
            
            Button("Save file", systemImage: "arrow.down.document.fill") {
                
                Task {
                    
                    let panel = NSSavePanel()
                    panel.nameFieldStringValue = self.path.lastPathComponent
                    panel.isExtensionHidden = false
                    panel.canCreateDirectories = true
                    
                    if await panel.begin() == .OK,
                       let destinationURL = panel.url {
                        
                        do {
                            
                            try FileManager.default.copyItem(at: self.path, to: destinationURL)
                        } catch {
                            
                            print("Error saving file: \(error)")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - BodyView.FormDataContent -

extension BodyView
{
    struct FormDataContent: View
    {
        let parts: Array<FormPart>
        
        var body: some View {
            
            VStack(alignment: .center, spacing: 15.0) {
                
                ForEach(self.parts) {
                    
                    part in
                    
                    FormPartView(part: part)
                }
            }
        }
    }
}

fileprivate
extension BodyView.FormDataContent
{
    struct FormPartView: View
    {
        let part: FormPart
        
        var body: some View {
            
            HStack(spacing: 2.0) {
                
                Text("Header")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(self.part.header)
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.8))
            }
            
            HStack(spacing: 2.0) {
                
                Text("Content")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let path = self.part.path {
                    
                    BodyView.FileContent(path: path)
                } else {
                    
                    BodyView.TextContent(bodyString: self.part.content ?? "")
                }
            }
            
            Divider()
                .background(Color.gray.opacity(0.5))
                .padding(.leading, 15.0)
        }
    }
}
