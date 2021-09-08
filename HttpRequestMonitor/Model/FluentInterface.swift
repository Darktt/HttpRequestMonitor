//
//  FluentInterface.swift
//  DTTest
//
//  Created by Darktt on 21/9/3.
//  Copyright © 2021 Darktt. All rights reserved.
//

import UIKit

/// Implement fluent interface.
///
/// Idea from: [利用 Swift 5.1 新功能實作 Fluent Interface　讓程式碼更易讀流暢！](https://www.appcoda.com.tw/fluent-interface/)
/// Usage:
/// ```swift
///     FluentInterface(subject: UIView())
///         .frame(CGRect(x: 0, y: 0, width: 100, height: 100))
///         .backgroundColor(.white)
///         .alpha(0.5)
///         .subject
/// ```
@dynamicMemberLookup
public struct FluentInterface<Subject>
{
    public let subject: Subject
    
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<Subject, Value>) -> ((Value) -> FluentInterface<Subject>)
    {
        var subject: Subject = self.subject
        
        let returnHandler: (Value) -> FluentInterface<Subject> = {
            
            subject[keyPath: keyPath] = $0
            
            let fluentInterface = FluentInterface(subject: subject)
            
            return fluentInterface
        }
        
        return returnHandler
    }
}

// MARK: - FluentCompatible -

public protocol FluentCompatible { }

extension FluentCompatible
{
    var fluent: FluentInterface<Self> {
        
        FluentInterface(subject: self)
    }
}

extension UIBarItem: FluentCompatible { }

extension UIView: FluentCompatible { }

extension UIGestureRecognizer: FluentCompatible { }
