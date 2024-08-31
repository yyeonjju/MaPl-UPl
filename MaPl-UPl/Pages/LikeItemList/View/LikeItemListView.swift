//
//  LikeItemListView.swift
//  MaPl-UPl
//
//  Created by 하연주 on 9/1/24.
//

import UIKit
import SnapKit

final class LikeItemListView : BaseView {
    let tableView = UITableView()
    

    override func configureSubView() {
        addSubview(tableView)
    }
    
    override func configureLayout() {
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
}
