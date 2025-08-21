//
//  RequestCell.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2025/8/19.
//

import SwiftUI

public
struct RequestCell: View
{
    let title: String
    
    let detail: String
    
    @State
    private
    var isHover = false
    
    public
    var body: some View {
        
        HStack {
            
            Text(self.title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(self.detail)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 10.0)
        .padding(.horizontal, 16.0)
        .background(
            (self.isHover ? Color.accentColor.opacity(0.13) : Color(NSColor.controlBackgroundColor).opacity(0.85))
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: self.isHover ? .accentColor.opacity(0.10) : .black.opacity(0.04), radius: 4, x: 0, y: 1)
        .onHover {
            
            hover in
            
            self.isHover = hover
        }
        .animation(.easeInOut(duration: 0.18), value: self.isHover)
    }
}

#Preview {
    
    RequestCell(title: "Request Method", detail: "GET")
}
