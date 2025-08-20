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
        
        VStack(alignment: .leading, spacing: 0.0) {
            
            HStack(alignment: .center, spacing: 1.0) {
                
                Image(systemName: "network")
                
                Text("Address:")
                    .bold()
                
                Text(self.text ?? "")
                
                Spacer(minLength: 1.0)
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding([.leading, .trailing], 10.0)
        }
        .frame(height: 20.0)
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
