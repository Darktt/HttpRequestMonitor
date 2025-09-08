//
//  DictionaryExtension.swift
//
//  Created by Darktt on 16/9/7.
//  Copyright © 2016 Darktt. All rights reserved.
//

import Foundation

// MARK: - DictionaryKey -

public 
struct DictionaryKey<K, V>: RawRepresentable where K: Hashable
{
    public
    var rawValue: K
    
    public
    init(rawValue: K)
    {
        self.rawValue = rawValue
    }
}

// MARK: - Protocol -
// MARK: #DictionaryKeyConvertible

public 
protocol DictionaryKeyConvertible { }

extension DictionaryKeyConvertible
{
    public static
    func key<K>(_ key: K) -> DictionaryKey<K, Self> where K: Hashable
    {
        let key = DictionaryKey<K, Self>(rawValue: key)
        
        return key
    }
}

// MARK: - Extensions -

public 
extension Dictionary
{
    subscript<V>(key: DictionaryKey<Key, V>) -> V? {
        
        set {
            
            self[key.rawValue] = newValue as? Value
        }
        
        get {
            
            return self[key.rawValue] as? V
        }
    }
    
    subscript<V>(key: DictionaryKey<Key, V>, default defaultValue: @autoclosure () -> V) -> V {
        
        set {
            
            self[key] = newValue
        }
        
        get {
            
            return self[key] ?? defaultValue()
        }
    }
    
    subscript<RawKey>(key: RawKey) -> Value? where RawKey: RawRepresentable, RawKey.RawValue == Key {
        
        set {
            
            self[key.rawValue] = newValue
        }
        
        get {
            
            return self[key.rawValue]
        }
    }
    
    func hasKey(_ key: Key) -> Bool
    {
        
        let hasKey: Bool = (self[key] != nil)
        
        return hasKey
    }
    
    func key(for value: Value) -> Key? where Value: Comparable
    {
        let result: (key: Key, value: Value)? = self.first(where: { $1 == value })
        
        return result?.key
    }
}

public 
extension Dictionary where Value == Int
{
    // Counting number of duplicate elements.
    init<S>(counted list: S) where S: Sequence, S.Element == Key
    {
        let ones: Repeated<Int> = Swift.repeatElement(1, count: Int.max)
        let zippedSequence: Zip2Sequence<S, Repeated<Int>> = Swift.zip(list, ones)
        
        self.init(zippedSequence, uniquingKeysWith: +)
    }
    
    // Counting number of specific elements.
    init<S>(counted list: S, by keyForCounting: (S.Element) -> Key) where S: Sequence
    {
        let ones: Repeated<Int> = Swift.repeatElement(1, count: Int.max)
        let keys: [Key] = list.map(keyForCounting)
        let zippedSequence: Zip2Sequence<[Key], Repeated<Int>> = Swift.zip(keys, ones)
        
        self.init(zippedSequence, uniquingKeysWith: +)
    }
    
    // Counting number of specific optional elements.
    init<S>(counted list: S, by keyForCounting: (S.Element) -> Key?) where S: Sequence
    {
        let ones: Repeated<Int> = Swift.repeatElement(1, count: Int.max)
        let keys: [Key] = list.compactMap(keyForCounting)
        let zippedSequence: Zip2Sequence<[Key], Repeated<Int>> = Swift.zip(keys, ones)
        
        self.init(zippedSequence, uniquingKeysWith: +)
    }
}

public 
extension Dictionary where Key == AnyHashable
{
    subscript<K, V>(key: DictionaryKey<K, V>) -> V? where K: Hashable {
        
        set {
            
            let hashedKey = AnyHashable(key.rawValue)
            self[hashedKey] = newValue as? Value
        }
        
        get {
            
            let hashedKey = AnyHashable(key.rawValue)
            return self[hashedKey] as? V
        }
    }
    
    subscript<K>(key: DictionaryKey<K, Value>, default defaultValue: @autoclosure () -> Value) -> Value?  where K: Hashable {
        
        set {
            
            let hashedKey = AnyHashable(key.rawValue)
            self[hashedKey] = newValue
        }
        
        get {
            
            let hashedKey = AnyHashable(key.rawValue)
            return self[hashedKey, default: defaultValue()]
        }
    }
    
    subscript<V, R>(key: DictionaryKey<Key, R>) -> R? where R: RawRepresentable, R.RawValue == V {
        
        set {
            
            self[key.rawValue] = newValue?.rawValue as? Value
        }
        
        get {
            
            guard let value = self[key.rawValue] as? V else  {
                
                return nil
            }
            
            let rawValue = R(rawValue: value)
            
            return rawValue
        }
    }
    
    subscript<V, R>(key: DictionaryKey<Key, R>, default defaultValue: @autoclosure () -> R) -> R? where R: RawRepresentable, R.RawValue == V {
        
        set {
            
            self[key] = newValue
        }
        
        get {
            
            return self[key] ?? defaultValue()
        }
    }
}

public 
extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any
{
    // MARK: - Methods -
    
    static
    func infoDictionary() -> Dictionary<String, Any>?
    {
        return Bundle.main.infoDictionary
    }
    
    static
    func localizedInfoDictionary() -> Dictionary<String, Any>?
    {
        return Bundle.main.localizedInfoDictionary
    }
}

public 
extension Dictionary where Key == String, Value == Any
{
    // MARK: - Properties -
    // infoDictionary
    
    var bundleVersion: String {
        
        let key: DictionaryKey<String, String> = String.key("CFBundleVersion")
        
        return self[key]!
    }
    
    var bundleShortVersion: String {
        
        let key: DictionaryKey<String, String> = String.key("CFBundleShortVersionString")
        
        return self[key]!
    }
    
    var bundleName: String {
        
        let key: DictionaryKey<String, String> = String.key("CFBundleName")
        
        return self[key]!
    }
    
    var bundleDisplayName: String {
        
        let key: DictionaryKey<String, String> = String.key("CFBundleDisplayName")
        
        return self[key]!
    }
    
    var bundleIdentifier: String {
        
        let key: DictionaryKey<String, String> = String.key("CFBundleIdentifier")
        
        return self[key]!
    }
}

#if canImport(UIKit)

public 
extension Dictionary where Key == String, Value == Any
{
    // Keyboard notification user info.
    @available(iOS 3.2, *)
    @available(tvOS, unavailable)
    var keyboardFrameBegin: CGRect {
        
        let key: DictionaryKey<String, CGRect> = CGRect.key(UIResponder.keyboardFrameBeginUserInfoKey)
        let value: CGRect = self[key]!
        
        return value
    }
    
    @available(iOS 3.2, *)
    @available(tvOS, unavailable)
    var keyboardFrameEnd: CGRect {
        
        let key: DictionaryKey<String, CGRect> = CGRect.key(UIResponder.keyboardFrameEndUserInfoKey)
        let value: CGRect = self[key]!
        
        return value
    }
    
    @available(iOS 3.2, *)
    @available(tvOS, unavailable)
    var animationCurve: UIView.AnimationCurve {
        
        let key: DictionaryKey<String, Int> = Int.key(UIResponder.keyboardAnimationCurveUserInfoKey)
        let rawValue: Int = self[key]!
        let value = UIView.AnimationCurve(rawValue: rawValue)!
        
        return value
    }
    
    @available(iOS 3.2, *)
    @available(tvOS, unavailable)
    var animationDuration: TimeInterval {
        
        let key: DictionaryKey<String, TimeInterval> = TimeInterval.key(UIResponder.keyboardAnimationCurveUserInfoKey)
        let value: TimeInterval = self[key]!
        
        return value
    }
    
    @available(iOS 9.0, *)
    @available(tvOS, unavailable)
    var isLocalUserInfo: Bool {
        
        let key: DictionaryKey<String, Bool> = Bool.key(UIResponder.keyboardIsLocalUserInfoKey)
        let value: Bool = self[key]!
        
        return value
    }
}

#endif

// MARK: - Confirm Protocols -
// MARK: #Array

extension Array: DictionaryKeyConvertible { }

// MARK: #Bool

extension Bool: DictionaryKeyConvertible { }

// MARK: #Character

extension Character: DictionaryKeyConvertible { }

// MARK: #CharacterSet

extension CharacterSet: DictionaryKeyConvertible { }

// MARK: #Data

extension Data: DictionaryKeyConvertible { }

// MARK: #Date

extension Date: DictionaryKeyConvertible { }

// MARK: #Dictionary

extension Dictionary: DictionaryKeyConvertible { }

// MARK: #Double

extension Double: DictionaryKeyConvertible { }

// MARK: #Float

extension Float: DictionaryKeyConvertible { }

// MARK: #Int

extension Int: DictionaryKeyConvertible { }

// MARK: #Int8

extension Int8: DictionaryKeyConvertible { }

// MARK: #Int16

extension Int16: DictionaryKeyConvertible { }

// MARK: #Int32

extension Int32: DictionaryKeyConvertible { }

// MARK: #Int64

extension Int64: DictionaryKeyConvertible { }

// MARK: #Set

extension Set: DictionaryKeyConvertible { }

// MARK: #String

extension String: DictionaryKeyConvertible { }

// MARK: #UUID

extension UUID: DictionaryKeyConvertible { }

// MARK: #URL

extension URL: DictionaryKeyConvertible { }

// MARK: #UInt

extension UInt: DictionaryKeyConvertible { }

// MARK: - AppKit -

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

// MARK: #NSColor

extension NSColor: DictionaryKeyConvertible { }

// MARK: #NSImage

extension NSImage: DictionaryKeyConvertible { }

#endif

// MARK: - CoreGraphics -

#if canImport(CoreGraphics)

import CoreGraphics

// MARK: #CGFloat

extension CGFloat: DictionaryKeyConvertible { }

// MARK: #CGSize

extension CGSize: DictionaryKeyConvertible { }

// MARK: #CGPoint

extension CGPoint: DictionaryKeyConvertible { }

// MARK: #CGRect

extension CGRect: DictionaryKeyConvertible { }

#endif

// MARK: - CoreBluetooth -

#if canImport(CoreBluetooth)

import CoreBluetooth

// MARK: #CBUUID

extension CBUUID: DictionaryKeyConvertible { }

#endif

// MARK: - UIKit -

#if canImport(UIKit)

import UIKit

// MARK: #UIBarItem

extension UIBarItem: DictionaryKeyConvertible { }

// MARK: #UIColor

extension UIColor: DictionaryKeyConvertible { }

// MARK: UIEdgeInsets

extension UIEdgeInsets: DictionaryKeyConvertible { }

// MARK: #UIImage

extension UIImage: DictionaryKeyConvertible { }

// MARK: #UIView

extension UIView: DictionaryKeyConvertible { }

// MARK: #UIView.AnimationCurve

extension UIView.AnimationCurve: DictionaryKeyConvertible { }

#endif

// MARK: - Photos -

#if canImport(Photos)

import Photos

// MARK: #PHAsset

@available(iOS 8.0, OSX 10.13, tvOS 10.0, *)
extension PHAsset: DictionaryKeyConvertible { }

#endif
