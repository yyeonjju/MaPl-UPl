//
//  LikeItemListViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/31/24.
//

import UIKit
import RxSwift

final class LikeItemListViewController : BaseViewController<LikeItemListView, LikeItemListViewModel> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "좋아요한 플레이리스트"
        setupBind()
    }
    
    private func setupBind() {
        let loadDataTrigger = PublishSubject<String?>()
        let input = LikeItemListViewModel.Input(loadDataTrigger:loadDataTrigger)
        let output = vm.transform(input: input)
        
        
        loadDataTrigger.onNext(nil)
        
        viewManager.tableView.register(BasicColoredBackgroundSubtitleTableViewCell.self, forCellReuseIdentifier: BasicColoredBackgroundSubtitleTableViewCell.description())
        
        
        output.likesData
            .bind(to: viewManager.tableView.rx.items(cellIdentifier: BasicColoredBackgroundSubtitleTableViewCell.description(), cellType: BasicColoredBackgroundSubtitleTableViewCell.self)) { (row, element, cell : BasicColoredBackgroundSubtitleTableViewCell) in
                cell.selectionStyle = .none
                cell.configurePlaylistData(data: element)
            }
            .disposed(by: disposeBag)
        
        output.errorMessage
            .bind(to: errorMessage)
            .disposed(by: disposeBag)
        
        output.isLoading
            .bind(to: isLoading)
            .disposed(by: disposeBag)
    }
}
