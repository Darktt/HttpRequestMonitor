//
//  ViewExtension.swift
//
//  Created by Eden on 2025/8/25.
//  
//

import SwiftUI

public
extension View
{
    var eraseToAnyView: AnyView {
        
        AnyView(self)
    }
}
