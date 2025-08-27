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
    
    private
    var selectedRequest: Request?
    
    public
    var body: some View {
        
        ScrollView {
            
            LazyVStack {
                
                ForEach(self.requests) { request in
                    
                    RequestCell(title: request.rootUrl, detail: request.requestMethod, isSelected: (request == self.selectedRequest))
                        .onTapGesture {
                            
                            self.selectedHandler?(request)
                        }
                }
            }
            .padding(.top, 10.0)
            .padding(.horizontal, 5.0)
        }
    }
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public
    init(requests: Array<Request>, selected: Request? = nil)
    {
        self.requests = requests
        self.selectedRequest = selected
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
        
    RequestListView(requests: kDummyRequests, selected: kDummyRequests.first)
}
