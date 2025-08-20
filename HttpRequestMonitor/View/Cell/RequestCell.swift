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
    
    public
    var body: some View {
        
        HStack {
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(detail)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

#Preview {
    RequestCell(title: "Request Method", detail: "GET")
}
