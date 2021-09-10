//
//  UIAlertActionBuilder.swift
//
//  Created by Eden on 2020/5/13.
//  Copyright © 2020 Darktt. All rights reserved.
//

import UIKit

public struct AlertAction
{
    // MARK: - Properties -
    
    private let title: String
    
    private let style: UIAlertAction.Style
    
    private let action: ActionHandler?
    
    // MARK: - Methods -
    
    public static func `default`(_ title: String, action: ActionHandler?) -> Array<AlertAction>
    {
        let action = AlertAction(title: title, style: .default, action: action)
        
        return [action]
    }

    public static func destructive(_ title: String, action: ActionHandler?) -> Array<AlertAction>
    {
        let action = AlertAction(title: title, style: .destructive, action: action)
        
        return [action]
    }

    public static func cancel(_ title: String, action: ActionHandler?) -> Array<AlertAction>
    {
        let action = AlertAction(title: title, style: .cancel, action: action)
        
        return [action]
    }
    
    public static func forEach<S>(_ sequence: S, @UIAlertActionBuilder body: (S.Element) -> Array<AlertAction>) -> Array<AlertAction> where S: Sequence
    {
        let actions: Array<Array<AlertAction>> = sequence.map(body)
        let flatActions: Array<AlertAction> = actions.flatMap({ $0 })
        
        return flatActions
    }
}

public extension AlertAction
{
    typealias ActionHandler = () -> Void
    
    static func `default`<Title>(_ title: Title, action: ActionHandler?) -> Array<AlertAction> where Title: RawRepresentable, Title.RawValue == String
    {
        let actions: Array<AlertAction> = self.default(title.rawValue, action: action)
        
        return actions
    }
    
    static func destructive<Title>(_ title: Title, action: ActionHandler?) -> Array<AlertAction> where Title: RawRepresentable, Title.RawValue == String
    {
        let actions: Array<AlertAction> = self.destructive(title.rawValue, action: action)
        
        return actions
    }
    
    static func cancel<Title>(_ title: Title, action: ActionHandler?) -> Array<AlertAction> where Title: RawRepresentable, Title.RawValue == String
    {
        let actions: Array<AlertAction> = self.cancel(title.rawValue, action: action)
        
        return actions
    }
}

private extension AlertAction
{
    func alertAction() -> UIAlertAction
    {
        let actionHandler: (UIAlertAction) -> Void = {
            
            _ in
            
            self.action?()
        }
        
        let action = UIAlertAction(title: self.title, style: self.style, handler: actionHandler)
        
        return action
    }
}

@resultBuilder
public struct UIAlertActionBuilder
{
    public typealias Actions = Array<AlertAction>
    
    public static func buildBlock(_ actions: Actions...) -> Actions
    {
        let flatActions: Actions = actions.flatMap({ $0 })
        
        return flatActions
    }
    
    public static func buildIf(_ actions: Actions?) -> Actions
    {
        actions ?? []
    }
    
    public static func buildEither(first actions: Actions) -> Actions
    {
        actions
    }
    
    public static func buildEither(second actions: Actions) -> Actions
    {
        actions
    }
}

public extension UIAlertController
{
    static func alert(title: String?, message: String?, @UIAlertActionBuilder actions: () -> Array<AlertAction>) -> UIAlertController
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        actions().forEach {
            
            let action: UIAlertAction = $0.alertAction()
            
            alertController.addAction(action)
        }
        
        return alertController
    }
}
