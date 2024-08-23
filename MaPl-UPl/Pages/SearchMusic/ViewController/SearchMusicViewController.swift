//
//  SearchMusicViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/23/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchMusicViewController : BaseViewController<SearchMusicView, SearchMusicViewModel> {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewManager.tableView.rowHeight = 70
        viewManager.tableView.register(BasicMusicTableViewCell.self, forCellReuseIdentifier: BasicMusicTableViewCell.description())
        setupBind()
    }
    
    // MARK: - SetupBind

    private func setupBind() {
        let viewDidLoadTrigger = Observable.just(())
        let searchButtonTap = viewManager.searchBar.rx.searchButtonClicked.asObservable()
        let inputText = viewManager.searchBar.rx.text.orEmpty.asObservable()
        
        let input = SearchMusicViewModel.Input(viewDidLoadTrigger : viewDidLoadTrigger, searchButtonTap: searchButtonTap, inputText : inputText)
        let output = vm.transform(input: input)
        

        
        output.songInfoList
            .bind(to: viewManager.tableView.rx.items(cellIdentifier: BasicMusicTableViewCell.description(), cellType: BasicMusicTableViewCell.self)) { (row, element, cell : BasicMusicTableViewCell) in
                cell.confiureData(data: element)
                
            }
            .disposed(by: disposeBag)
        
        output.isLoading
            .asDriver(onErrorJustReturn: false) //에러 받지 않고 메인스레드에서 실행시키기 위함
            .drive(with:self) { owner, isLoading in
                owner.viewManager.emptyView.controlLoadingSpinner(isLoading: isLoading)
                owner.viewManager.emptyView.isHidden = !isLoading
            }
            .disposed(by: disposeBag)
        
        
//        viewManager.tableView.rx.modelSelected(SongInfo.self)
//            .bind(with:self) {owner, selectedModel in
//                print("selectedModel", selectedModel)
//                
////                owner.playItem(url: selectedModel.previewURL)
//            }
//            .disposed(by: disposeBag)
    }
    
    
}
