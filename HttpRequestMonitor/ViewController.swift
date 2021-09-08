//
//  ViewController.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2021/9/8.
//

import UIKit
import Combine

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
        
//        self.navigationController?.setToolbarHidden(false, animated: true)
        
        _ = self.tableView.fluent
            .delegate(self)
            .dataSource(self)
        
        self.setupRightBarButtonItem()
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
    
    func setupService()
    {
        do {
            
            let service = try HTTPService(port: 2208)
            service.statusUpdateHandler = self.serviceStatusUpdate(status:)
            
            self.httpService = service
        } catch {
            
            print("Error: \(error)")
        }
    }
    
    func serviceStatusUpdate(status: HTTPService.Status)
    {
        self.title = "Server \(status)"
        
        if status == .suspend {
            
            self.navigationItem.rightBarButtonItem?.title = "Start"
        }
        
        if status == .runing {
            
            self.navigationItem.rightBarButtonItem?.title = "Stop"
        }
        
        if case let .failed(error) = status {
            
            self.presentAlert(with: error)
        }
        
        var isEnabled: Bool = true
        
        if case .waitting(_) = status {
            
            isEnabled = false
        }
        
        self.navigationItem.rightBarButtonItem?.isEnabled = isEnabled
    }
    
    func receiveRequest(request: HTTPMessage)
    {
        self.requests.append(request)
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
            cell = UITableViewCell(style: .default, reuseIdentifier: CellIdentifier)
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
