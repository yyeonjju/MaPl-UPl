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
        viewManager.tableView.register(SearchMusicTableViewCell.self, forCellReuseIdentifier: SearchMusicTableViewCell.description())
        
        viewManager.collectionView.register(SelectedMusicCollectionViewCell.self, forCellWithReuseIdentifier: SelectedMusicCollectionViewCell.description())
        
        setupBind()
    }
    
    // MARK: - SetupBind

    private func setupBind() {
        let viewDidLoadTrigger = Observable.just(())
        let searchButtonTap = viewManager.searchBar.rx.searchButtonClicked.asObservable()
        let inputText = viewManager.searchBar.rx.text.orEmpty.asObservable()
        let selectedMusic = PublishSubject<SongInfo>()
        let removeMusic = PublishSubject<Int>()
        
        let input = SearchMusicViewModel.Input(viewDidLoadTrigger : viewDidLoadTrigger, searchButtonTap: searchButtonTap, inputText : inputText, selectedMusic : selectedMusic, removeMusic:removeMusic)
        let output = vm.transform(input: input)
        
        
        viewManager.searchBar.rx.searchButtonClicked.bind(with: self) { owner, _ in
            owner.view.endEditing(true)
        }
        .disposed(by: disposeBag)

        
        output.songInfoList
            .bind(to: viewManager.tableView.rx.items(cellIdentifier: SearchMusicTableViewCell.description(), cellType: SearchMusicTableViewCell.self)) { (row, element, cell : SearchMusicTableViewCell) in
                
                cell.confiureData(data: element)
                cell.selectButton.rx.tap
                    .map{element}
                    .bind { song in
                        selectedMusic.onNext(song)
                    }
                    .disposed(by: cell.disposeBag)
                
            }
            .disposed(by: disposeBag)
        
        output.isLoading
            .asDriver(onErrorJustReturn: false) //에러 받지 않고 메인스레드에서 실행시키기 위함
            .drive(with:self) { owner, isLoading in
                owner.viewManager.emptyView.controlLoadingSpinner(isLoading: isLoading)
                owner.viewManager.emptyView.isHidden = !isLoading
            }
            .disposed(by: disposeBag)
        
        
        //선택한 노래
        output.selectedMusicList
            .bind(to: viewManager.collectionView.rx.items(cellIdentifier: SelectedMusicCollectionViewCell.description(), cellType: SelectedMusicCollectionViewCell.self)){ (row, element, cell : SelectedMusicCollectionViewCell) in
                
                cell.confiureData(data: element)
                cell.removeButton.rx.tap
                    .map{row}
                    .bind { row in
                        removeMusic.onNext(row)
                    }
                    .disposed(by: cell.disposeBag)
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
