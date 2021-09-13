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
            
            guard let data = self.request.data else {
                
                return ""
            }
            
            let bodyString: String = String(data: data, encoding: .utf8) ?? ""
            
            return bodyString
        }()
        
        self.requestHeaders = headers
        self.requestBody = body
    }
}

// MARK: - Delagate Methods -

extension DetailRequestController: UITableViewDataSource
{
    //MARK: - UITableView DataSource Methods
    
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let CellIdentifier: String = "CellIdentifier"
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: CellIdentifier)
        }
        
        return cell!
    }
}

extension DetailRequestController: UITableViewDelegate
{
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
