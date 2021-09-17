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
    // MARK: - Properties -
    
    public let subject: Subject
    
    public let discardResult: Void = ()
    
    // MARK: - Methods -
    
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<Subject, Value>) -> FluentCaller<Subject, Value>
    {
        let caller = FluentCaller(subject: self.subject, keyPath: keyPath)
        
        return caller
    }
}

@dynamicCallable
public struct FluentCaller<Subject, Value>
{
    // MARK: - Properties -
    
    fileprivate let subject: Subject
    
    fileprivate let keyPath: WritableKeyPath<Subject, Value>
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    func dynamicallyCall(withArguments arguments: Array<Value>) -> FluentInterface<Subject>
    {
        guard let value: Value = arguments.first else {
            
            return FluentInterface(subject: self.subject)
        }
        
        var subject: Subject = self.subject
        subject[keyPath: self.keyPath] = value
        
        let fluentInterface = FluentInterface(subject: subject)
        
        return fluentInterface
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

extension UIGestureRecognizer: FluentCompatible { }

extension UIResponder: FluentCompatible { }

#if targetEnvironment(macCatalyst)

extension NSTouchBar: FluentCompatible { }

extension NSTouchBarItem: FluentCompatible { }

#endif
