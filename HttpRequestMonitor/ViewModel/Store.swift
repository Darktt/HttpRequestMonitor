//
//  Store.swift
//
//  Created by Darktt on 2024/3/1.
//

import Foundation

public
typealias Processor<Action> = (Action) -> Void

public
typealias Middleware<State, Action> =
( Store<State, Action> ) ->
// (@escaping (Action) -> Void) ->
( @escaping Processor<Action> ) ->
// ((Action) -> Void)
( Processor<Action> )

// 定義 Reducer 類型別名，用於處理狀態變化的邏輯
public
typealias Reducer<State, Action> = (State, Action) -> State

// 定義 Store 類，實現簡單的 Redux 風格狀態管理
@MainActor
public
class Store<State, Action>: ObservableObject
{
    @Published
    public private(set)
    var state: State
    
    private
    var reducer: Reducer<State, Action>
    
    private
    var middlewares: Array<Middleware<State, Action>> = []
    
    // 初始化 Store，接受初始狀態、Reducer 和 Middleware 數組
    init(initialState: State, reducer: @escaping Reducer<State, Action>, middlewares: Array<Middleware<State, Action>> = [])
    {
        self.state = initialState
        self.reducer = reducer
        self.middlewares = middlewares
    }
    
    func dispatch(_ action: Action)
    {
        var composedMiddleware: Processor<Action> = self.dispatchWithoutMiddleware
        
        self.middlewares.reversed().forEach {
            
            middleware in
            
            let currentMiddleware = composedMiddleware
            composedMiddleware = middleware(self)(currentMiddleware)
        }
        
        composedMiddleware(action)
    }
}

private
extension Store
{
    func dispatchWithoutMiddleware(action: Action)
    {
        Task {
            @MainActor in
            
            let newState = self.reducer(self.state, action)
            
            self.state = newState
        }
    }
}
