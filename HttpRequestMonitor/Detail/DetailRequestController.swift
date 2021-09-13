//
//  DetailRequestController.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2021/9/10.
//

import UIKit

public class DetailRequestController: UIViewController
{
    // MARK: - Properties -
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    private let request: HTTPMessage
    
    private var queryItems: Array<URLQueryItem> = []
    
    private var requestHeaders: Array<HTTPHeader> = []
    
    private var requestBody: String = ""
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public init(request: HTTPMessage)
    {
        self.request = request
        
        super.init(nibName: "DetailRequestController", bundle: nil)
    }
    
    internal required init?(coder: NSCoder)
    {
        self.request = HTTPMessage.response(statusCode: .notFound, htmlString: "Not found!!!")
        
        super.init(coder: coder)
    }
    
    public override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }
    
    // MARK: View Live Cycle
    
    public override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    public override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
    }
    
    public override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
    }
    
    public override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
    }
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.title = self.request.requestURL?.absoluteString
        
        self.tableView.fluent
            .delegate(self)
            .dataSource(self)
            .rowHeight(UITableView.automaticDimension)
            .estimatedRowHeight(UITableView.automaticDimension)
            .separatorStyle(.none)
            .discardResult
        
        self.tableView.register(FieldValueCell.self)
        self.tableView.register(BodyCell.self)
        
        self.resolveRequest()
    }
    
    deinit
    {
        
    }
}

// MARK: - Private Methons -

private extension DetailRequestController
{
    func resolveRequest()
    {
        let headers: Array<HTTPHeader> = self.request.httpHeaders().sorted()
        let body: String = {
            
            guard let data = self.request.data, let bodyString: String = String(data: data, encoding: .utf8) else {
                
                return ""
            }
            
            return bodyString
        }()
        
        self.requestHeaders = headers
        self.requestBody = body
    }
    
    func queryCell(with tableView: UITableView, at indexPath: IndexPath) -> FieldValueCell?
    {
        guard !self.queryItems.isEmpty,
              let cell = tableView.dequeueReusableCell(FieldValueCell.self, for: indexPath) else {
            
            return nil
        }
        
        return cell
    }
    
    func headerCell(with tableView: UITableView, at indexPath: IndexPath) -> FieldValueCell?
    {
        guard (indexPath.section == 0 && self.queryItems.isEmpty) || (indexPath.section == 1 && !self.queryItems.isEmpty),
              let cell = tableView.dequeueReusableCell(FieldValueCell.self, for: indexPath) else {
            
            return nil
        }
        
        return cell
    }
    
    func bodyCell(with tableView: UITableView, at indexPath: IndexPath) -> BodyCell?
    {
        guard (indexPath.section == 1 && self.queryItems.isEmpty) || (indexPath.section == 2),
              let cell = tableView.dequeueReusableCell(BodyCell.self, for: indexPath) else {
            
            return nil
        }
        
        return cell
    }
}

// MARK: - Delagate Methods -

extension DetailRequestController: UITableViewDataSource
{
    //MARK: - UITableView DataSource Methods
    
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        guard self.queryItems.isEmpty else {
            
            return 3
        }
        
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var numberOfRowsInSection: Int = 0
        
        if section == 0 {
            
            if !self.queryItems.isEmpty {
                
                numberOfRowsInSection = self.queryItems.count
            } else {
                
                numberOfRowsInSection = self.requestHeaders.count
            }
        }
        
        if section == 1 {
            
            if !self.queryItems.isEmpty {
                
                numberOfRowsInSection = self.requestHeaders.count
            } else {
                
                numberOfRowsInSection = 1
            }
        }
        
        if section == 2 {
            
            numberOfRowsInSection = 1
        }
        
        return numberOfRowsInSection
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = self.queryCell(with: tableView, at: indexPath) {
            
            let queryItem: URLQueryItem = self.queryItems[indexPath.row]
            
            cell.fluent
                .quertyItem(queryItem)
                .discardResult
            
            return cell
        }
        
        if let cell = self.headerCell(with: tableView, at: indexPath) {
            
            let header: HTTPHeader = self.requestHeaders[indexPath.row]
            
            cell.fluent
                .requestHeader(header)
                .discardResult
            
            return cell
        }
        
        if let cell = self.bodyCell(with: tableView, at: indexPath) {
            
            cell.fluent
                .bodyString(self.requestBody)
                .discardResult
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        var sectionTitle: String = ""
        
        if section == 0 {
            
            if !self.queryItems.isEmpty {
                
                sectionTitle = "Queries"
            } else {
                
                sectionTitle = "Headers"
            }
        }
        
        if section == 1 {
            
            if !self.queryItems.isEmpty {
                
                sectionTitle = "Headers"
            } else {
                
                sectionTitle = "Body"
            }
        }
        
        if section == 2 {
            
            sectionTitle = "Body"
        }
        
        return sectionTitle
    }
}

extension DetailRequestController: UITableViewDelegate
{
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
