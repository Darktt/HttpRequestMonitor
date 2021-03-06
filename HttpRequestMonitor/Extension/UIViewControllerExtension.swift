//
//  UIViewControllerExtension.swift
//
//  Created by Darktt on 16/3/8.
//  Copyright © 2016 Darktt. All rights reserved.
//

import UIKit

public extension UIViewController
{
    // MARK: - Methods -
    // MARK: Initial Method
    
    convenience init(nibName: String)
    {
        self.init(nibName: nibName, bundle: nil)
    }
    
    // MARK: Instance Methods
    
    func toolbarItem(at index: Int) -> UIBarButtonItem?
    {
        guard let toolbarItems = self.toolbarItems, toolbarItems.count < index else {
            
            return nil
        }
        
        let barButtonItem: UIBarButtonItem = toolbarItems[index]
        
        return barButtonItem
    }
    
    func presentFullScreen(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)? = nil)
    {
        viewControllerToPresent.modalPresentationStyle = .fullScreen
        
        self.present(viewControllerToPresent, animated: animated, completion: completion)
    }
    
    func presentedViewController<ViewController>(of type: ViewController.Type) -> ViewController? where ViewController: UIViewController
    {
        let presentedViewController = self.presentedViewController as? ViewController
        
        return presentedViewController
    }
    
    func childViewController<ViewController>(of type: ViewController.Type) -> ViewController? where ViewController: UIViewController
    {
        let viewController = self.children.compactMap({ $0 as? ViewController }).first
        
        return viewController
    }
    
    func filterChildViewController<ViewController>(exception exceptionController: ViewController, execution: (ViewController) -> Void) where ViewController: UIViewController
    {
        self.children.forEach {
            
            childViewController in
            
            guard childViewController != exceptionController else {
                
                return
            }
            
            if let pageController = childViewController as? ViewController {
                
                execution(pageController)
            }
        }
    }
}
