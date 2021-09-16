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
    
    private let viewModel: DetailViewModel = .init()
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public init(request: HTTPMessage)
    {
        self.viewModel.setRequest(request)
        
        super.init(nibName: "DetailRequestController", bundle: nil)
    }
    
    internal required init?(coder: NSCoder)
    {
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
        
        self.title = self.viewModel.rootURL?.absoluteString
        
        self.tableView.fluent
            .delegate(self)
            .dataSource(self)
            .separatorStyle(.none)
            .allowsSelection(false)
            .rowHeight(UITableView.automaticDimension)
            .estimatedRowHeight(UITableView.automaticDimension)
            .discardResult
        
        self.tableView.register(FieldValueCell.self)
        self.tableView.register(BodyCell.self)
    }
    
    deinit
    {
        
    }
}

// MARK: - Private Methons -

private extension DetailRequestController
{
    func queryCell(with tableView: UITableView, at indexPath: IndexPath) -> FieldValueCell?
    {
        guard indexPath.section == 0, !self.viewModel.isQuertItemsEmpty,
              let cell = tableView.dequeueReusableCell(FieldValueCell.self, for: indexPath) else {
            
            return nil
        }
        
        return cell
    }
    
    func headerCell(with tableView: UITableView, at indexPath: IndexPath) -> FieldValueCell?
    {
        guard (indexPath.section == 0 && self.viewModel.isQuertItemsEmpty) || (indexPath.section == 1 && !self.viewModel.isQuertItemsEmpty),
              let cell = tableView.dequeueReusableCell(FieldValueCell.self, for: indexPath) else {
            
            return nil
        }
        
        return cell
    }
    
    func bodyCell(with tableView: UITableView, at indexPath: IndexPath) -> BodyCell?
    {
        guard (indexPath.section == 1 && self.viewModel.isQuertItemsEmpty) || (indexPath.section == 2),
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
        guard self.viewModel.isQuertItemsEmpty else {
            
            return 3
        }
        
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var numberOfRowsInSection: Int = 0
        
        if section == 0 {
            
            if !self.viewModel.isQuertItemsEmpty {
                
                numberOfRowsInSection = self.viewModel.queryItems.count
            } else {
                
                numberOfRowsInSection = self.viewModel.requestHeaders.count
            }
        }
        
        if section == 1 {
            
            if !self.viewModel.isQuertItemsEmpty {
                
                numberOfRowsInSection = self.viewModel.requestHeaders.count
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
        if let cell = self.queryCell(with: tableView, at: indexPath),
           let queryItem: URLQueryItem = self.viewModel.queryItem(at: indexPath) {
            
            cell.fluent
                .quertyItem(queryItem)
                .discardResult
            
            return cell
        }
        
        if let cell = self.headerCell(with: tableView, at: indexPath),
           let header: HTTPHeader = self.viewModel.requestHeaders(at: indexPath) {
            
            cell.fluent
                .requestHeader(header)
                .discardResult
            
            return cell
        }
        
        if let cell = self.bodyCell(with: tableView, at: indexPath) {
            
            cell.fluent
                .bodyString(self.viewModel.requestBody)
                .discardResult
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        var sectionTitle: String = ""
        
        if section == 0 {
            
            if !self.viewModel.isQuertItemsEmpty {
                
                sectionTitle = "Queries"
            } else {
                
                sectionTitle = "Headers"
            }
        }
        
        if section == 1 {
            
            if !self.viewModel.isQuertItemsEmpty {
                
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
