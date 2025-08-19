//
//  RootViewController.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2021/9/8.
//

import UIKit
import Combine
import Network

public
class RootViewController: UIViewController
{
    // MARK: - Properties -
    
    public static
    let startServerNoticationName: Notification.Name = Notification.Name(rawValue: "RootViewController.StartServer")
    
    public override
    var keyCommands: [UIKeyCommand]? {
        
#if targetEnvironment(macCatalyst)
        
        return nil
        
#else
        
        let startKeyCommand = MenuManager.startKeyCommand(action: #selector(self.startServerAction(_:)))
        let stopKeyCommand = MenuManager.stopKeyCommand(action: #selector(self.stopServerAction(_:)))
        
        return [startKeyCommand, stopKeyCommand]
        
#endif
    }
    
    @IBOutlet private
    weak var tableView: UITableView!
    
    private
    let store: MonitorStore = kMonitorStore
    
    private
    var cancellableSet: Set<AnyCancellable> = Set()
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public
    init()
    {
        super.init(nibName: "RootViewController", bundle: nil)
    }
    
    internal required
    init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Live Cycle
    
    public override
    func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if self.store.state.httpStatus == .runing {
            
            self.navigationController?.setToolbarHidden(false, animated: true)
        }
    }
    
    public override
    func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    public override
    func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
    }
    
    public override
    func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
    }
    
    public override
    func viewDidLoad()
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
        self.setupSubscribes()
        self.setupNotification()
    }
    
    deinit
    {
    }
}

// MARK: - Actions -

private
extension RootViewController
{
    @objc
    func startServerAction(_ sender: UIKeyCommand)
    {
        self.startMonitor()
    }
    
    @objc
    func stopServerAction(_ sender: UIKeyCommand)
    {
        self.stopMonitor()
    }
}

// MARK: - Private Methods -

private
extension RootViewController
{
    func setupLeftBarButtonItem()
    {
        let trashCanImage = UIImage(systemName: "trash")
        let barButtonItem = UIBarButtonItem().fluent
                                .image(trashCanImage)
                                .subject
        
        let receiveValue: (ActionPublisher<UIBarButtonItem>.Output) -> Void = {
            
            [unowned self] _ in
            
            let action = MonitorAction.cleanRequests
            
            self.sendAction(action)
        }
        
        barButtonItem.publisher()
                     .throttle(for: 0.5, scheduler: RunLoop.main, latest: false)
                     .sink(receiveValue: receiveValue)
                     .store(in: &self.cancellableSet)
        
        self.navigationItem.setLeftBarButton(barButtonItem, animated: true)
    }
    
    func removeLeftBarButtonItem()
    {
        self.navigationItem.setLeftBarButton(nil, animated: true)
    }
    
    func setupRightBarButtonItem()
    {
        let transform: (UIBarButtonItem) -> Bool = {
            
            let isStarted: Bool = ($0.title != "Start")
            
            return isStarted
        }
        
        let receiveValue: (Bool) -> Void = {
            
            [unowned self] isStarted in
            
            guard !isStarted else {
                
                self.stopMonitor()
                return
            }
            
            self.startMonitor()
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
        let predicate: (DTWiFiInformation.IPAddressInfo) -> Bool = {
            
            guard $0.version == DTWiFiInformation.IPAddressInfo.Version.ipv4 else {
                
                return false
            }
            
            let vaildInterface: [DTWiFiInformation.IPAddressInfo.Interface] = [.wifi, .ethernet, .loopback]
            let isVaildInterface: Bool = vaildInterface.contains($0.interface)
            
            return isVaildInterface
        }
        
        let ipAddress: String = wifiInformation.detailedIPAddresses
                                                .filter(predicate)
                                                .first?.address ?? ""
        let portNumber: UInt16 = self.store.state.portNumber
        let addressText: String = {
            
            var text: String = "Address: http://localhost:\(portNumber)"
            
            if !ipAddress.isEmpty {
                
                text += "\nor http://\(ipAddress):\(portNumber)"
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
        
        self.setToolbarItems([flexItem, addressItem, flexItem], animated: false)
    }
    
    func setupSubscribes()
    {
        self.store
            .$state
            .throttle(for: 1.0, scheduler: DispatchQueue.main, latest: false)
            .sink {
                
                [weak self] state in
                
                self?.updateView(with: state)
            }
            .store(in: &self.cancellableSet)
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
        
        self.navigationItem
            .rightBarButtonItem?
            .fluent
            .title(itemTitle)
            .isEnabled(isEnabled)
            .discardResult
        
        self.navigationController?.setToolbarHidden(isToolbarHidden, animated: true)
        
        // Present error message.
        if case let .failed(error) = status {
            
            self.presentAlert(with: error)
        }
    }
    
    func presentAlert(with error: Error)
    {
        let title: String = "Server start failed!"
        let message: String = "\(error)"
        let alertController = UIAlertController.alert(title: title, message: message) {
            
            AlertAction.default("OK") {
                
                self.navigationItem.rightBarButtonItem?.title = "Start"
                self.stopMonitor()
            }
        }
        
        self.present(alertController, animated: true)
    }
    
    func setupNotification()
    {
        NotificationCenter.default
            .publisher(for: RootViewController.startServerNoticationName, object: nil)
            .sink {
                
                [unowned self] _ in
                
                self.startMonitor()
            }
            .store(in: &self.cancellableSet)
    }
    
    func startMonitor()
    {
        guard self.store.state.httpStatus != .runing else {
            
            return
        }
        
        let action = MonitorAction.startMonitor
        
        self.sendAction(action)
        self.setupLeftBarButtonItem()
    }
    
    func stopMonitor()
    {
        guard self.store.state.httpStatus == .runing else {
            
            return
        }
        
        let action = MonitorAction.stopMonitor
        
        self.sendAction(action)
        self.removeLeftBarButtonItem()
    }
    
    func cleanRequests()
    {
        let action = MonitorAction.cleanRequests
        
        self.sendAction(action)
    }
    
    func sendAction(_ action: MonitorAction)
    {
        self.store.dispatch(action)
    }
    
    func updateView(with state: MonitorState)
    {
        if let error = state.error {
            
            self.presentErrorAlert(with: error)
        }
        
        self.serviceStatusUpdate(status: state.httpStatus)
        self.tableView.reloadSection(0)
    }
}

// MARK: - Delegate Methods -
// MARK: #UITableViewDataSource, UITableViewDelegate

extension RootViewController: UITableViewDataSource, UITableViewDelegate
{
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        self.store.state.requests.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier: String = "CellIdentifier"
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
            cell?.accessoryType = .disclosureIndicator
        }
        
        let request: HTTPMessage = self.store.state.requests[indexPath.row]
        
        if let url: URL = request.rootURL,
           let method: HTTPMethod = request.requestMethod {
            
            cell?.textLabel?.text = url.absoluteString
            cell?.detailTextLabel?.text = method.rawValue
        }
        
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let request = self.store.state.requests[indexPath.row]
        let detailController = DetailRequestController(request: request)
        let navigationController = UINavigationController(rootViewController: detailController)
        
        self.splitViewController?.showDetailViewController(navigationController, sender: nil)
    }
}
