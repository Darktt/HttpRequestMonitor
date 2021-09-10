//
//  UserDefaultsWrapper.swift
//
//  Created by Darktt on 20/1/9.
//  Copyright © 2020 Darktt. All rights reserved.
//

import Foundation

@frozen @propertyWrapper
public struct UserDefaultsWrapper<Value>
{
    // MARK: - Properties -
    
    public var wrappedValue: Value {
        
        set {
            
            self.userDefaults.set(newValue, forKey: self.key)
        }
        
        get {
            
            if let value: Value = self.userDefaults.object(forKey: self.key) as? Value {
                
                return value
            }
            
            return self.defaultValue
        }
    }
    
    private let key: String
    
    private let defaultValue: Value
    
    private var userDefaults: UserDefaults = .standard
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public init(_ key: String, defaultValue: Value)
    {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public init(_ key: String, defaultValue: Value, userDefaults: UserDefaults)
    {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }
}
