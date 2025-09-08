//
//  EdgeInsetsExtension.swift
//
//  Created by Eden on 2025/8/20.
//  
//

import SwiftUI

public
extension EdgeInsets
{
    static
    func allEdge(_ value: CGFloat) -> EdgeInsets
    {
        EdgeInsets(top: value, leading: value, bottom: value, trailing: value)
    }
}
