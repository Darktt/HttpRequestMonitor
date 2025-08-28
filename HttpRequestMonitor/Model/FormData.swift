//
//  FormData.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2025/8/27.
//

import Foundation

public
struct FormData
{
    // MARK: - Properties -
    
    public private(set)
    var parts: Array<FormPart> = []
    
    private
    let path: URL
    
    private
    let fileHandle: FileHandle
    
    private
    let boundary: String
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public
    init(path: URL, boundary: String) throws
    {
        let fileHandle = try FileHandle(forReadingFrom: path)
        
        self.path = path
        self.fileHandle = fileHandle
        self.boundary = "--" + boundary
        
        try self.parse()
    }
}

private
extension FormData
{
    mutating
    func parse() throws
    {
        defer {
            
            try? self.fileHandle.close()
        }
        
        let sizeKey = DictionaryKey<FileAttributeKey, UInt64>(rawValue: .size)
        let fileManager = FileManager.default
        let fileAttribute: Dictionary<FileAttributeKey, Any> = try fileManager.attributesOfItem(atPath: self.path.path())
        guard let fileSize = fileAttribute[sizeKey]else {
            
            return
        }
        
        var parts: [FormPart] = []
        var offset: UInt64 = 0
        
        while offset < fileSize {
            
            // 找 boundary
            guard let boundaryRange = try self.findBoundary(from: offset) else {
                
                break
            }
            
            let partStart = boundaryRange.upperBound
            
            // 下一個 boundary
            guard let nextBoundaryRange = try findBoundary(from: partStart) else {
                
                break
            }
            
            let partEnd = nextBoundaryRange.lowerBound
            
            // 讀取這段資料
            try self.fileHandle.seek(toOffset: partStart)
            let readCount = Int(partEnd - partStart)
            let partData = try self.fileHandle.read(upToCount: readCount) ?? Data()
            
            // \r\n\r\n
            let separatorData = Data([13,10,13,10])
            
            // 分割 header 與 body
            if let separatorRange: Range<Data.Index> = partData.range(of: separatorData) {
                
                let headersData: Data = partData[..<separatorRange.lowerBound]
                let bodyData: Data = partData[separatorRange.upperBound...]
                
                let headers = String(data: headersData, encoding: .utf8).flatMap({
                    
                    $0.trimmingCharacters(in: .whitespacesAndNewlines)
                }) ?? ""
                let fileName: String? = try self.extractFilename(from: headers)
                let bodyContent: String? = String(data: bodyData, encoding: .utf8)?
                                            .trimmingCharacters(in: .whitespacesAndNewlines)
                var filePath: URL?
                
                if bodyContent == nil {
                    
                    let catcheDirectory: URL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
                    // 把 body 寫到暫存檔（使用檔名）
                    filePath = catcheDirectory.appending(path:fileName ?? UUID().uuidString)
                    
                    try bodyData.write(to: filePath!)
                }
                var formPart = FormPart(header: headers)
                formPart.content = bodyContent
                formPart.fileName = fileName
                formPart.path = filePath
                
                parts.append(formPart)
            }
            
            offset = partEnd
        }
        
        self.parts = parts
    }
    
    func findBoundary(from offset: UInt64) throws -> Range<UInt64>?
    {
        guard let boundaryData = self.boundary.data(using: .utf8) else {
            
            return nil
        }
        
        try self.fileHandle.seek(toOffset: offset)
        let chunkSize: Int = 64 * 1024
        var searchOffset = offset
        var resultRange: Range<UInt64>?
        
        while true {
            
            let data = try self.fileHandle.read(upToCount: chunkSize) ?? Data()
            
            if data.isEmpty {
                
                break
            }
            
            if let range = data.range(of: boundaryData) {
                
                let lower = searchOffset + UInt64(range.lowerBound)
                let upper = searchOffset + UInt64(range.upperBound)
                resultRange = lower..<upper
                break
            }
            
            searchOffset += UInt64(data.count)
        }
        
        return resultRange
    }
    
    func extractFilename(from headers: String) throws -> String?
    {
        let pattern: String = #"filename="([^"]+)""#
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(headers.startIndex..., in: headers)
        let match: NSTextCheckingResult? = regex.firstMatch(in: headers, range: range)
        
        guard let range = match.flatMap({ Range($0.range(at: 1), in: headers) }) else {
            
            return nil
        }
        
        return String(headers[range])
    }
}
