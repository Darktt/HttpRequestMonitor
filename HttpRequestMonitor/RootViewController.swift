//
//  RootViewController.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2021/9/8.
//

import UIKit
import Combine

class RootViewController: UIViewController
{
    // MARK: - Properties -
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    private var httpService: HTTPService?
    
    private var requests: Array<HTTPMessage> = [] {
        
        didSet {
            
            self.tableView.reloadSection(0)
        }
    }
    
    private var cancellableSet: Set<AnyCancellable> = Set()
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public init()
    {
        super.init(nibName: "RootViewController", bundle: nil)
        
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Live Cycle
    
    public override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if self.httpService?.status == .runing {
            
            self.navigationController?.setToolbarHidden(false, animated: true)
        }
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
        
        self.title = "Server"
        
        self.tableView.fluent
            .delegate(self)
            .dataSource(self)
            .discardResult
        
        self.setupRightBarButtonItem()
        self.setupToolbarItem()
        self.setupService()
    }
    
    deinit
    {
        
    }
}

private extension RootViewController
{
    func setupRightBarButtonItem()
    {
        let transform: (UIBarButtonItem) -> (HTTPService, Bool)? = {
            
            [unowned self] in
            
            guard let service = self.httpService else {
                
                return nil
            }
            
            let isStarted: Bool = ($0.title != "Start")
            
            return (service, isStarted)
        }
        
        let receiveValue: ((service: HTTPService, isStarted: Bool)) -> Void = {
            
            [unowned self] in
            
            guard !$0.isStarted else {
                
                $0.service.cancel()
                return
            }
            
            $0.service.start()
            
            self.requests.removeAll()
        }
        
        let barButtonItem = UIBarButtonItem().fluent
                            .title("Start")
                            .subject
        
        barButtonItem.publisher()
            .throttle(for: 2.0, scheduler: RunLoop.main, latest: false)
            .compactMap(transform)
            .sink(receiveValue: receiveValue)
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
                                            .forgroundColor(.label, range: range)
                                            .systemFont(ofSize: 14.0)
        
        let addressLabel = UILabel(frame: .zero).fluent
                            .attributedText(addressAttributedText)
                            .numberOfLines(0)
                            .subject
        
        let flexItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
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
            
            self.presentAlert(with: error)
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
        guard !self.requests.isEmpty else {
            
            self.requests.append(request)
            return
        }
        
        self.requests.insert(request, at: 0)
    }
    
    /*
    func requestLocationPremission()
    {
        DTPermission.locationWhenInUse.request {
            
            [unowned self] in
            
            guard $0 != .authorizedWhenInUse else {
                
                self.setupToolbarItem()
                return
            }
            
            self.presentLocationPremissionDeniedMessage()
        }
    }
    
    func presentLocationPremissionDeniedMessage()
    {
        let title: String = "Cannot get IP address"
        let message: String = "Please accept the location when in use premission."
        let alertController = UIAlertController.alert(title: title, message: message) {
            
            AlertAction.cancel("Setting") {
                
                guard let url = URL(string: UIApplication.openSettingsURLString) else {
                    
                    return
                }
                
                let application = UIApplication.shared
                application.open(url, options: [:], completionHandler: nil)
            }
            
            AlertAction.default("Don't remine me.") {
                
                self.isIgnorePremissionCheck = true
            }
        }
        
        self.present(alertController, animated: true)
    }
    */
    func presentAlert(with error: Error)
    {
        let title: String = "Server start failed!"
        let message: String = "\(error)"
        let alertController = UIAlertController.alert(title: title, message: message) {
            
            AlertAction.default("OK") {
                
                self.navigationItem.rightBarButtonItem?.title = "Start"
                self.httpService?.cancel()
            }
        }
        
        self.present(alertController, animated: true)
    }
}

// MARK:  - Delegate Methods -

extension RootViewController: UITableViewDataSource
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
            cell?.accessoryType = .disclosureIndicator
        }
        
        let request: HTTPMessage = self.requests[indexPath.row]
        
        if let url: URL = request.rootURL,
           let method: HTTPMethod = request.requestMethod {
            
            cell?.textLabel?.text = url.absoluteString
            cell?.detailTextLabel?.text = method.rawValue
        }
        
        return cell!
    }
}

extension RootViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let request = self.requests[indexPath.row]
        let detailController = DetailRequestController(request: request)
        let navigationController = UINavigationController(rootViewController: detailController)
        
        self.splitViewController?.showDetailViewController(navigationController, sender: nil)
    }
}
