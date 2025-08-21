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
    
    let isSelected: Bool
    
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
        .background(self.backgroundColor())
        .overlay(self.overlay())
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: self.shadowColor(), radius: self.isSelected ? 7 : 4, x: 0, y: 1)
        .onHover {
            hover in
            
            self.isHover = hover
        }
        .animation(.easeInOut(duration: 0.18), value: self.isHover)
        .animation(.easeInOut(duration: 0.18), value: self.isSelected)
    }
}

// MARK: - Prvate Methods -

private
extension RequestCell
{
    func backgroundColor() -> Color
    {
        if self.isSelected {
            
            return Color.accentColor.opacity(0.22)
        }
        
        if self.isHover {
            
            return Color.accentColor.opacity(0.13)
        }
        
        return Color(NSColor.controlBackgroundColor).opacity(0.85)
    }
    
    func shadowColor() -> Color
    {
        if self.isSelected {
            
            return Color.accentColor.opacity(0.18)
        }
        
        if self.isHover {
            
            return Color.accentColor.opacity(0.10)
        }
        
        return Color.black.opacity(0.04)
    }
    
    func overlay() -> some View
    {
        let borderColor: Color = self.isSelected ? Color.accentColor : Color.clear
        let lineWidth: CGFloat = self.isSelected ? 2 : 0.5
        
        let view = RoundedRectangle(cornerRadius: 10, style: .continuous)
            .stroke(borderColor, lineWidth: lineWidth)
        
        return view
    }
}

// MARK: - Preview -

#Preview {
    RequestCell(title: "Request Method", detail: "GET", isSelected: true)
}
