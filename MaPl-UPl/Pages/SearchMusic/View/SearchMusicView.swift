//
//  SearchMusicView.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/23/24.
//

import UIKit
import SnapKit

final class SearchMusicView : BaseView {
    // MARK: - UI
    let searchBar = UISearchBar()
    let tableView = UITableView()
    let emptyView = EmptyView()
    
    
    // MARK: - ConfigureUI
    
    override func configureSubView() {
        [searchBar, tableView, emptyView]
            .forEach{
                addSubview($0)
            }
    }
    
    override func configureLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.bottom.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.bottom.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
    }

}
