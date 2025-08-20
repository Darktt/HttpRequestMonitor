//
//  RequestListView.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2025/8/19.
//

import SwiftUI

public
struct RequestListView: View
{
    public
    var requests: Array<Request>
    
    private
    var selectedHandler: ((Request) -> Void)?
    
    public
    var body: some View {
        
        ScrollView {
            
            LazyVStack {
                
                ForEach(requests) { request in
                    
                    RequestCell(title: request.rootUrl, detail: request.requestMethod)
                        .onTapGesture {
                            
                            self.selectedHandler?(request)
                        }
                }
            }
        }
        .padding(.top, 10.0)
    }
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public
    init(requests: Array<Request>)
    {
        self.requests = requests
    }
    
    public
    func onSelected(_ handler: @escaping (Request) -> Void) -> some View
    {
        var view = self
        view.selectedHandler = handler
            
        return view
    }
}

#Preview {
        
    RequestListView(requests: kDummyRequests)
}
