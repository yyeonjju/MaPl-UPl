//
//  AutoResizingTableView.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/22/24.
//

import UIKit

class AutoResizingTableView : UITableView {
    
    override public func layoutSubviews() {
//        print("AutoResizingTableView intrinsicContentSize --> ", intrinsicContentSize)
//        print("AutoResizingTableView bounds.size --> ", bounds.size)
        
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return contentSize
    }
}
