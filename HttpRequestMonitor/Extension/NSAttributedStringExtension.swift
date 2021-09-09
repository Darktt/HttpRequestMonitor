//
//  NSAttributedStringExtension.swift
//
//  Created by Darktt on 19/9/3.
//  Copyright © 2019 Darktt. All rights reserved.
//

import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit.NSColor
import AppKit.NSFont

#else

import UIKit.UIColor
import UIKit.UIFont

#endif

// MARK: - Text Color -

public extension NSMutableAttributedString
{
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    
    typealias Color = NSColor
    typealias Font = NSFont
    
#else
    
    typealias Color = UIColor
    typealias Font = UIFont
    
#endif
    
    // Colors
    
#if canImport(UIKit) && (os(iOS) || os(macOS))
    
    var darkText: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        self.darkText(range: range)
        
        return self
    }
    
    var lightText: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        self.lightText(range: range)
        
        return self
    }
    
#endif
    
    var black: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        self.black(range: range)
        
        return self
    }
    
    var blue: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        self.blue(range: range)
        
        return self
    }
    
    var brown: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        self.brown(range: range)
        
        return self
    }
    
    var cyan: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        self.cyan(range: range)
        
        return self
    }
    
    var darkGray: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        self.darkGray(range: range)
        
        return self
    }
    
    var gray: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        self.gray(range: range)
        
        return self
    }
    
    var green: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        self.green(range: range)
        
        return self
    }
    
    var lightGray: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        self.lightGray(range: range)
        
        return self
    }
    
    var magenta: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        self.magenta(range: range)
        
        return self
    }
    
    var orange: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        self.orange(range: range)
        
        return self
    }
    
    var purple: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        self.purple(range: range)
        
        return self
    }
    
    var red: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        self.red(range: range)
        
        return self
    }
    
    var white: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        self.white(range: range)
        
        return self
    }
    
    var yellow: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        self.yellow(range: range)
        
        return self
    }
    
    // MARK: - Methods -
    
    @discardableResult
    func forgroundColor(_ color: Color) -> NSMutableAttributedString
    {
        let range: NSRange = self.fullRange
        self.addTextColor(color, range: range)
        
        return self
    }
    
    @discardableResult
    func forgroundColor(_ color: Color, range: NSRange) -> NSMutableAttributedString
    {
        self.addTextColor(color, range: range)
        
        return self
    }
    
#if canImport(UIKit) && (os(iOS) || os(macOS))
    
    @discardableResult
    func darkText(range: NSRange) -> NSMutableAttributedString
    {
        self.addTextColor(Color.darkText, range: range)
        
        return self
    }
    
    @discardableResult
    func lightText(range: NSRange) -> NSMutableAttributedString
    {
        self.addTextColor(Color.lightText, range: range)
        
        return self
    }
    
#endif
    
    @discardableResult
    func black(range: NSRange) -> NSMutableAttributedString
    {
        self.addTextColor(Color.black, range: range)
        
        return self
    }
    
    @discardableResult
    func blue(range: NSRange) -> NSMutableAttributedString
    {
        self.addTextColor(Color.blue, range: range)
        
        return self
    }
    
    @discardableResult
    func brown(range: NSRange) -> NSMutableAttributedString
    {
        self.addTextColor(Color.brown, range: range)
        
        return self
    }
    
    @discardableResult
    func cyan(range: NSRange) -> NSMutableAttributedString
    {
        self.addTextColor(Color.cyan, range: range)
        
        return self
    }
    
    @discardableResult
    func darkGray(range: NSRange) -> NSMutableAttributedString
    {
        self.addTextColor(Color.darkGray, range: range)
        
        return self
    }
    
    @discardableResult
    func gray(range: NSRange) -> NSMutableAttributedString
    {
        self.addTextColor(Color.gray, range: range)
        
        return self
    }
    
    @discardableResult
    func green(range: NSRange) -> NSMutableAttributedString
    {
        self.addTextColor(Color.green, range: range)
        
        return self
    }
    
    @discardableResult
    func lightGray(range: NSRange) -> NSMutableAttributedString
    {
        self.addTextColor(Color.lightGray, range: range)
        
        return self
    }
    
    @discardableResult
    func magenta(range: NSRange) -> NSMutableAttributedString
    {
        self.addTextColor(Color.magenta, range: range)
        
        return self
    }
    
    @discardableResult
    func orange(range: NSRange) -> NSMutableAttributedString
    {
        self.addTextColor(Color.orange, range: range)
        
        return self
    }
    
    @discardableResult
    func purple(range: NSRange) -> NSMutableAttributedString
    {
        self.addTextColor(Color.purple, range: range)
        
        return self
    }
    
    @discardableResult
    func red(range: NSRange) -> NSMutableAttributedString
    {
        self.addTextColor(Color.red, range: range)
        
        return self
    }
    
    @discardableResult
    func white(range: NSRange) -> NSMutableAttributedString
    {
        self.addTextColor(Color.white, range: range)
        
        return self
    }
    
    @discardableResult
    func yellow(range: NSRange) -> NSMutableAttributedString
    {
        self.addTextColor(Color.yellow, range: range)
        
        return self
    }
}

// MARK: - Font style -

public extension NSMutableAttributedString
{
    @available(iOS 2.0, macCatalyst 13.0, *)
    @available(tvOS, unavailable)
    var bold: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        let fontSize: CGFloat = Font.labelFontSize
        
        self.bold(ofSize: fontSize, range: range)
        
        return self
    }
    
    @available(iOS 2.0, macCatalyst 13.0, *)
    @available(tvOS, unavailable)
    var italic: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        let fontSize: CGFloat = Font.labelFontSize
        
        self.italic(ofSize: fontSize, range: range)
        
        return self
    }
    
    var strikethrough: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        
        self.strikethrough(range: range)
        
        return self
    }
    
    var underline: NSMutableAttributedString {
        
        let range: NSRange = self.fullRange
        
        self.underline(range: range)
        
        return self
    }
    
    // MARK: - Methods -
    
    @discardableResult
    func systemFont(ofSize size: CGFloat) -> NSMutableAttributedString
    {
        let range: NSRange = self.fullRange
        let font = Font.systemFont(ofSize: size)
        
        self.addFont(font, range: range)
        
        return self
    }
    
    @discardableResult
    func systemFont(ofSize size: CGFloat, range: NSRange) -> NSMutableAttributedString
    {
        let font = Font.systemFont(ofSize: size)
        
        self.addFont(font, range: range)
        
        return self
    }
    
    @discardableResult
    func bold(ofSize size: CGFloat) -> NSMutableAttributedString
    {
        let range: NSRange = self.fullRange
        let font = Font.boldSystemFont(ofSize: size)
        
        self.addFont(font, range: range)
        
        return self
    }
    
    @discardableResult
    func bold(ofSize size: CGFloat, range: NSRange) -> NSMutableAttributedString
    {
        let font = Font.boldSystemFont(ofSize: size)
        
        self.addFont(font, range: range)
        
        return self
    }
    
    @discardableResult
    func italic(ofSize size: CGFloat) -> NSMutableAttributedString
    {
        let range: NSRange = self.fullRange
        let font: Font
        
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        
        let systemFont = Font.systemFont(ofSize: size)
        let fontManager = NSFontManager.shared
        font = fontManager.convert(systemFont, toHaveTrait: .italicFontMask)
            
#else
        font = Font.italicSystemFont(ofSize: size)
        
#endif
        
        self.addFont(font, range: range)
        
        return self
    }
    
    @discardableResult
    func italic(ofSize size: CGFloat, range: NSRange) -> NSMutableAttributedString
    {
        let font: Font
        
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        
        let systemFont = Font.systemFont(ofSize: size)
        let fontManager = NSFontManager.shared
        font = fontManager.convert(systemFont, toHaveTrait: .italicFontMask)
            
#else
        font = Font.italicSystemFont(ofSize: size)
        
#endif
        
        self.addFont(font, range: range)
        
        return self
    }
    
    @discardableResult
    func strikethrough(range: NSRange) -> NSMutableAttributedString
    {
        self.addStrikethrough(style: .single, range: range)
        
        return self
    }
    
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    
    @discardableResult
    func strikethroughColor(_ color: NSColor) -> NSMutableAttributedString
    {
        let range: NSRange = self.fullRange
        
        self.addStrikethroughColor(color, range: range)
        
        return self
    }
    
    @discardableResult
    func strikethroughColor(_ color: NSColor, range: NSRange) -> NSMutableAttributedString
    {
        self.addStrikethroughColor(color, range: range)
        
        return self
    }
    
#else
    
    @discardableResult
    func strikethroughColor(_ color: UIColor) -> NSMutableAttributedString
    {
        let range: NSRange = self.fullRange
        
        self.addStrikethroughColor(color, range: range)
        
        return self
    }
    
    @discardableResult
    func strikethroughColor(_ color: UIColor, range: NSRange) -> NSMutableAttributedString
    {
        self.addStrikethroughColor(color, range: range)
        
        return self
    }
    
#endif
    
    @discardableResult
    func underline(range: NSRange) -> NSMutableAttributedString
    {
        self.addUnerline(style: .single, range: range)
        
        return self
    }
}

// MARK: - Private Methods -

private extension NSMutableAttributedString
{
    var fullRange: NSRange {
        
        let length: Int = self.string.count
        let range = NSRange(location: 0, length: length)
        
        return range
    }
    
    func addTextColor(_ color: Color, range: NSRange)
    {
        let attrubutes: Dictionary<NSAttributedString.Key, Any> = [.foregroundColor: color]
        self.addAttributes(attrubutes, range: range)
    }
    
    func addFont(_ font: Font, range: NSRange)
    {
        let attrubutes: Dictionary<NSAttributedString.Key, Any> = [.font: font]
        self.addAttributes(attrubutes, range: range)
    }
    
    func addStrikethrough(style: NSUnderlineStyle, range: NSRange)
    {
        let attrubutes: Dictionary<NSAttributedString.Key, Any> = [.strikethroughStyle: style.rawValue]
        self.addAttributes(attrubutes, range: range)
    }
    
    func addStrikethroughColor(_ color: Color, range: NSRange)
    {
        let attrubutes: Dictionary<NSAttributedString.Key, Any> = [.strikethroughColor: color]
        self.addAttributes(attrubutes, range: range)
    }
    
    func addUnerline(style: NSUnderlineStyle, range: NSRange)
    {
        let attrubutes: Dictionary<NSAttributedString.Key, Any> = [.underlineStyle: style.rawValue]
        self.addAttributes(attrubutes, range: range)
    }
}
