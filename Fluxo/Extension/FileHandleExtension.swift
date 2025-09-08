//
//  FileHandleExtension.swift
//
//  Created by Eden on 2025/8/28.
//  
//

import Foundation

public
extension FileHandle
{
    func offset(of data: Data, chunkSize: Int = 4096) throws -> UInt64
    {
        var offset: UInt64 = 0
        
        while true {
            
            let chunkData: Data? = try self.read(upToCount: chunkSize)
            
            guard let chunkData = chunkData.and({ !$0.isEmpty }) else {
                
                break
            }
            
            if let range: Range<Data.Index> = chunkData.range(of: data) {
                
                offset += UInt64(range.lowerBound)
                break
            }
            
            offset += UInt64(chunkData.count)
        }
        
        return offset
    }
}
