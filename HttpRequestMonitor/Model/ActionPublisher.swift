//
//  ActionPublisher.swift
//
//  Created by Darktt on 21/9/6.
//  Copyright © 2021 Darktt. All rights reserved.
//

import Combine
import UIKit.UIBarButtonItem
import UIKit.UIGestureRecognizer

// MARK: - Actor -

public protocol Actor
{
    func addTarget(_ target: AnyObject, action: Selector)
}

// MARK: confirm Actor

extension UIBarButtonItem: Actor
{
    public func addTarget(_ target: AnyObject, action: Selector)
    {
        self.target = target
        self.action = action
    }
}

extension UIGestureRecognizer: Actor {
    
    public func addTarget(_ target: AnyObject, action: Selector)
    {
        let anyTarget: Any = target
        
        self.addTarget(anyTarget, action: action)
    }
}

// MARK: - ActionPublisher -

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct ActionPublisher<Source>: Publisher where Source: Actor
{
    public typealias Output = Source
    public typealias Failure = Never
    
    // MARK: - Properties -
    
    public var source: Source
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public init(source: Source)
    {
        self.source = source
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Source == S.Input
    {
        let subscription = ActionSubscription(subscriber: subscriber, source: self.source)
        
        subscriber.receive(subscription: subscription)
    }
}

// MARK: - ActionSubscription -

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public final class ActionSubscription<SubscriberType, Source>: Subscription where SubscriberType: Subscriber, SubscriberType.Input == Source, Source: Actor
{
    // MARK: - Properties -
    
    private var subscriber: SubscriberType?
    
    private var source: Source
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public init(subscriber: SubscriberType, source: Source)
    {
        self.subscriber = subscriber
        self.source = source
        
        source.addTarget(self, action: #selector(self.actionHandler))
    }
    
    public func request(_ demand: Subscribers.Demand)
    {
        // We do nothing here as we only want to send events when they occur.
        // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
    }
    
    public func cancel()
    {
        self.subscriber = nil
    }
    
    @objc
    private func actionHandler()
    {
        _ = self.subscriber?.receive(self.source)
    }
}

// MARK: - ActionPublisherCompartible -

public protocol ActionPublisherCompartible {}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension ActionPublisherCompartible where Self: Actor
{
    public func publisher() -> ActionPublisher<Self>
    {
        let publisher = ActionPublisher(source: self)
        
        return publisher
    }
}

// MARK: confirm ActionPublisherCompartible

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension UIBarButtonItem: ActionPublisherCompartible {}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension UIGestureRecognizer: ActionPublisherCompartible {}
