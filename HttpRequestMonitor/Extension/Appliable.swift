//
//  Appliable.swift
//
//  Created by Darktt on 18/6/12.
//  Copyright © 2018 Darktt. All rights reserved.
//

import Foundation

// MARK: - Appliable -

public protocol Appliable: AnyObject
{
    init()
}

extension Appliable
{
    public init(_ configuration: (Self) throws -> Void) rethrows
    {
        self.init()
        try configuration(self)
    }
    
    public static func apply(_ block: () throws -> Self) rethrows -> Self
    {
        return try block()
    }
    
    @discardableResult
    public func apply(_ block: (Self) throws -> Void) rethrows -> Self
    {
        try block(self)
        
        return self
    }
}

extension NSObject : Appliable { }
