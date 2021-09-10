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
    
    private let request: HTTPMessage
    
//    @IBOutlet fileprivate weak var <#Variable name#>: <#Class#>!
    
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
    }
    
    deinit
    {
        
    }
}

// MARK: - Private Methons -

private extension DetailRequestController
{
    
}
