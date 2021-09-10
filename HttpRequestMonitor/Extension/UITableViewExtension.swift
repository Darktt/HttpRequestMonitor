//
//  UITableViewExtension.swift
//
//  Created by Darktt on 16/10/4.
//  Copyright © 2016 Darktt. All rights reserved.
//

import UIKit

public extension UITableView
{
    // MARK: - Methods -
    // MARK: Initial Method
    
    convenience init(frame: CGRect, style: UITableView.Style = .plain, forTarget target: (UITableViewDataSource & UITableViewDelegate)? = nil)
    {
        self.init(frame: frame, style: style)
        
        self.dataSource = target
        self.delegate = target
    }
    
    // MARK: - Query Index Path
    
    func indexPathForRow(at view: UIView) -> IndexPath?
    {
        guard let superview = view.superview else {
            return nil
        }
        
        let rect = superview.convert(view.frame, to: self)
        let indexPaths: Array<IndexPath>? = self.indexPathsForRows(in: rect)
        
        return indexPaths?.first
    }
    
    // MARK: - Query Cell
    
    func cellForRow(at point: CGPoint) -> UITableViewCell?
    {
        guard let indexPath: IndexPath = self.indexPathForRow(at: point) else {
            
            return nil
        }
        
        let cell: UITableViewCell? = self.cellForRow(at: indexPath)
        
        return cell
    }
    
    func cellsForRows(in rect: CGRect) -> Array<UITableViewCell>?
    {
        guard let indexPaths: Array<IndexPath> = self.indexPathsForRows(in: rect) else {
            
            return nil
        }
        
        let cells: Array<UITableViewCell> = indexPaths.compactMap({ self.cellForRow(at: $0) })
        
        return cells
    }
    
    // MARK: - Move Row
    
    func moveRow(_ row: Int, to toRow: Int, in section: Int = 0)
    {
        let fromIndexPath = IndexPath(row: row, section: section)
        let toIndexPath = IndexPath(row: toRow, section: section)
        
        self.moveRow(at: fromIndexPath, to: toIndexPath)
    }
    
    // MARK: - Select Row or Section
    
    func selectRow(_ row: Int, section: Int = 0, animated: Bool = true, scrollPosition: UITableView.ScrollPosition = .none)
    {
        let indexPath = IndexPath(row: row, section: section)
        
        self.selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    // MARK: - Reload Row or Section
    
    func reloadCell(_ cell: UITableViewCell, with animation: UITableView.RowAnimation = .automatic)
    {
        guard let indexPath = self.indexPath(for: cell) else {
            
            return
        }
        
        self.reloadRow(at: indexPath, with: animation)
    }
    
    func reloadRow(_ row: Int, section: Int = 0, with animation: UITableView.RowAnimation = .automatic)
    {
        let indexPathForReload = IndexPath(row: row, section: section)
        
        self.reloadRow(at: indexPathForReload, with: animation)
    }
    
    func reloadRow(at indexPath: IndexPath, with animation: UITableView.RowAnimation = .automatic)
    {
        self.reloadRows(at: [indexPath], with: animation)
    }
    
    func reloadSection(_ section: Int, with animation: UITableView.RowAnimation = .automatic)
    {
        let indexSetForReload = IndexSet(integer: section)
        
        self.reloadSections(indexSetForReload, with: animation)
    }
    
    // MARK: - Insert Row or Section
    
    func insertRow(_ row: Int, section: Int = 0, with animation: UITableView.RowAnimation = .automatic)
    {
        let indexPathForInsert = IndexPath(row: row, section: section)
        
        self.insertRow(at: indexPathForInsert, with: animation)
    }
    
    func insertRow(at indexPath: IndexPath, with animation: UITableView.RowAnimation = .automatic)
    {
        self.insertRows(at: [indexPath], with: animation)
    }
    
    func insertSection(_ section: Int, with animation: UITableView.RowAnimation = .automatic)
    {
        let indexSetForInsert = IndexSet(integer: section)
        
        self.insertSections(indexSetForInsert, with: animation)
    }
    
    // MARK: - Delete Row or Section
    
    func deleteCell(_ cell: UITableViewCell, animation: UITableView.RowAnimation = .automatic)
    {
        guard let indexPath: IndexPath = self.indexPath(for: cell) else {
            
            return
        }
        
        self.deleteRow(at: indexPath, with: animation)
    }
    
    func deleteRow(_ row: Int, section: Int = 0, with animation: UITableView.RowAnimation = .automatic)
    {
        let indexPath = IndexPath(row: row, section: section)
        
        self.deleteRow(at: indexPath, with: animation)
    }
    
    func deleteRow(at indexPath: IndexPath, with animation: UITableView.RowAnimation = .automatic)
    {
        self.deleteRows(at: [indexPath], with: animation)
    }
    
    func deleteSection(_ section: Int, with animation: UITableView.RowAnimation = .automatic)
    {
        let indexSetForDelete = IndexSet(integer: section)
        
        self.deleteSections(indexSetForDelete, with: animation)
    }
    
    // MARK: - Scroll To Visible
    
    func scrollToRow(_ row: Int, section: Int = 0, atScrollPosition scrollPosition: UITableView.ScrollPosition = .top, animated: Bool = true)
    {
        let indexPath = IndexPath(row: row, section: section)
        
        self.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    // MARK: - Perform Batch Updates
    
    func performBatchUpdates(updateExecute: @convention(block) (UITableView) -> Void)
    {
        self.beginUpdates()
        
        updateExecute(self)
        
        self.endUpdates()
    }
}
