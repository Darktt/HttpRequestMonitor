//
//  ViewController.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2021/9/8.
//

import UIKit
import Combine
import DTPermissionKit

class ViewController: UIViewController
{
    // MARK: - Properties -
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    private var httpService: HTTPService?
    
    private var requests: Array<HTTPMessage> = [] {
        
        didSet {
            
            self.tableView.reloadData()
        }
    }
    
    private var cancellableSet: Set<AnyCancellable> = Set()
    
    // MARK: View Live Cycle
    
    public override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
    }
    
    public override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.checkLocationPremission()
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
        
        self.title = "Server"
        
        _ = self.tableView.fluent
            .delegate(self)
            .dataSource(self)
        
        self.setupRightBarButtonItem()
        self.setupToolbarItem()
        self.setupService()
    }
    
    deinit
    {
        
    }
}

private extension ViewController
{
    func setupRightBarButtonItem()
    {
        let barButtonItem = UIBarButtonItem().fluent
                            .title("Start")
                            .subject
        
        barButtonItem.publisher()
            .compactMap {
                
                item -> (HTTPService, Bool)? in
                
                guard let service = self.httpService else {
                    
                    return nil
                }
                
                let isStart: Bool = (item.title == "Start")
                
                return (service, isStart)
            }
            .sink {
                
                if $0.1 {
                    
                    $0.0.start()
                } else {
                    
                    $0.0.cancel()
                }
            }
            .store(in: &self.cancellableSet)
        
        self.navigationItem.setRightBarButton(barButtonItem, animated: false)
    }
    
    func setupToolbarItem()
    {
        let range = NSRange(location: 0, length: 9)
        let wifiInformation = DTWiFiInformation.current
        let ipAddress: String = wifiInformation.ipAddresses.first ?? ""
        let addressText: String = {
            
            var text: String = "Address: http://localhost:2208"
            
            if !ipAddress.isEmpty {
                
                text += "\nor http://\(ipAddress):2208"
            }
            
            return text
        }()
        
        let addressAttributedText = NSMutableAttributedString(string: addressText)
                                            .forgroundColor(.systemGray)
                                            .forgroundColor(.black, range: range)
                                            .systemFont(ofSize: 14.0)
        
        let addressLabel = UILabel(frame: .zero).fluent
                            .attributedText(addressAttributedText)
                            .numberOfLines(0)
                            .subject
        
        let flexItem = UIBarButtonItem(systemItem: .flexibleSpace)
        
        let addressItem = UIBarButtonItem().fluent
            .customView(addressLabel).subject
        
        self.setToolbarItems([flexItem, addressItem, flexItem,], animated: false)
    }
    
    func setupService()
    {
        do {
            
            let service = try HTTPService(port: 2208)
            service.statusUpdateHandler = self.serviceStatusUpdate(status:)
            service.receiveRequestHandler = self.receiveRequest(request:)
            
            self.httpService = service
        } catch {
            
            print("Error: \(error)")
        }
    }
    
    func serviceStatusUpdate(status: HTTPService.Status)
    {
        self.title = "Server \(status)"
        
        // Update current state
        var itemTitle: String = "Start"
        var isEnabled: Bool = true
        var isToolbarHidden: Bool = true
        
        if status == .runing {
            
            itemTitle = "Stop"
            isToolbarHidden = false
        }
        
        if case .waitting(_) = status {
            
            isEnabled = false
        }
        
        self.navigationItem.rightBarButtonItem?.title = itemTitle
        self.navigationItem.rightBarButtonItem?.isEnabled = isEnabled
        self.navigationController?.setToolbarHidden(isToolbarHidden, animated: true)
        
        // Present error message.
        if case let .failed(error) = status {
            
            self.presentAlert(with: error)
        }
    }
    
    func receiveRequest(request: HTTPMessage)
    {
        self.requests.append(request)
    }
    
    func checkLocationPremission()
    {
        DTPermission.locationWhenInUse.request { //<#DTPermission.Status#> in
            
            guard $0 != .authorizedWhenInUse else {
                
                self.setupToolbarItem()
                return
            }
            
            
        }
    }
    
    func presentAlert(with error: Error)
    {
        let okAction = UIAlertAction(title: "OK", style: .default) {
            
            _ in
            
            self.navigationItem.rightBarButtonItem?.title = "Start"
            self.httpService?.cancel()
        }
        
        let alertController = UIAlertController(title: "Server start failed!", message: "\(error)", preferredStyle: .alert)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true)
    }
}

// MARK:  - Delegate Methods -

extension ViewController: UITableViewDataSource
{
    //MARK: - UITableView DataSource Methods
    
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        self.requests.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let CellIdentifier: String = "CellIdentifier"
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: CellIdentifier)
        }
        
        let request: HTTPMessage = self.requests[indexPath.row]
        
        if let url: URL = request.requestURL,
           let method: HTTPMethod = request.requestMethod {
            
            cell?.textLabel?.text = url.absoluteString
            cell?.detailTextLabel?.text = method.rawValue
        }
        
        return cell!
    }
}

extension ViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
}
