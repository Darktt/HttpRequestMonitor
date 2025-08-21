//
//  StatusBar.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2025/8/20.
//

import SwiftUI

public
struct StatusBar: View
{
    private
    var text: String?
    
    public
    var body: some View {
        
        ZStack {
            
            Color(NSColor.windowBackgroundColor).opacity(0.7)
            
            HStack(alignment: .center, spacing: 2.0) {
                
                Image(systemName: "network")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                
                Text("Address:")
                    .bold()
                    .foregroundColor(.primary)
                
                Text(self.text ?? "")
                    .foregroundColor(.secondary)
                
                Spacer(minLength: 1.0)
            }
            .font(.caption)
            .padding(.horizontal, 14.0)
            .padding(.vertical, 6.0)
        }
        .frame(height: 30.0)
    }
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public
    init(_ text: String)
    {
        self.text = text
    }
}

#Preview {
    
    StatusBar("http://localhost:3000, http://127.0.0.1:3000")
}
