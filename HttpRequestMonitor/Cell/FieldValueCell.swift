//
//  FieldValueCell.swift
//  HttpRequestMonitor
//
//  Created by Eden on 2021/9/13.
//

import UIKit

public class FieldValueCell: UITableViewCell
{
    // MARK: - Properties -
    
    public var quertyItem: URLQueryItem? {
        
        willSet {
            
            self.titleLabel.text = newValue?.name
            self.valueLabel.text = newValue?.value
        }
    }
    
    public var requestHeader: HTTPHeader? {
        
        willSet {
            
            self.titleLabel.text = newValue?.field
            self.valueLabel.text = newValue?.value
        }
    }
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var valueLabel: UILabel!
    
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

extension FieldValueCell: CustomCellRegistrable
{
    public static var cellNib: UINib? {
        
        let nib = UINib(nibName: "FieldValueCell", bundle: nil)
        
        return nib
    }
 
    public static var cellIdentifier: String {
        
        return "FieldValueCell"
    }
}
