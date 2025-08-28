//
//  FormPart.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2025/8/27.
//

import Foundation

public
struct FormPart
{
    // MARK: - Properties -
    
    public
    var id: UUID = UUID()
    
    public
    let header: String
    
    public
    var content: String? = nil
    
    public
    var fileName: String? = nil
    
    public
    var path: URL?
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public
    init(header: String)
    {
        self.header = header
    }
}

extension FormPart: Identifiable
{ }

extension FormPart: CustomStringConvertible
{
    public
    var description: String {
        
        "Header: \(self.header)\nFileName: \(self.fileName ?? "nil")"
    }
}
