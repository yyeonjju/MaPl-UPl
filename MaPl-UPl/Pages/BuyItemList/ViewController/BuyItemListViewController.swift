//
//  BuyItemListViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/31/24.
//

import UIKit
import RxSwift

final class BuyItemListViewController : BaseViewController<BuyItemListView, BuyItemListViewModel> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "구매한 플레이리스트"
        setupBind()
    }
    
    private func setupBind() {
        let loadDataTrigger = Observable.just(())
        let input = BuyItemListViewModel.Input(loadDataTrigger:loadDataTrigger)
        let output = vm.transform(input: input)
        
        viewManager.tableView.register(BasicColoredBackgroundSubtitleTableViewCell.self, forCellReuseIdentifier: BasicColoredBackgroundSubtitleTableViewCell.description())
        
        
        output.paymentsData
            .bind(to: viewManager.tableView.rx.items(cellIdentifier: BasicColoredBackgroundSubtitleTableViewCell.description(), cellType: BasicColoredBackgroundSubtitleTableViewCell.self)) { (row, element, cell : BasicColoredBackgroundSubtitleTableViewCell) in
                cell.selectionStyle = .none
                cell.loadPlaylistData(id: element.postId)
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
