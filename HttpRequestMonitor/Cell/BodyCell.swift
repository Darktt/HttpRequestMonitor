//
//  BodyCell.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2021/9/13.
//

import UIKit

public class BodyCell: UITableViewCell
{
    // MARK: - Properties -
    
    public var bodyString: String = "" {
        
        willSet {
            
            self.bodyLabel.text = newValue
        }
    }
    
    @IBOutlet fileprivate weak var bodyLabel: UILabel!
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    deinit
    {
        
    }
}

// MARK: - Confirm Protocol -

extension BodyCell: CustomCellRegistrable
{
    public static var cellNib: UINib? {
        
        let nib = UINib(nibName: "BodyCell", bundle: nil)
        
        return nib
    }
 
    public static var cellIdentifier: String {
        
        return "BodyCell"
    }
}
