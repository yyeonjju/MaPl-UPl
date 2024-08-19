//
//  PlaylistListViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import UIKit
import RxSwift

final class PlaylistListViewController : BaseViewController<PlaylistListView, PlaylistListViewModel> {

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBind()
    }
    
    // MARK: - SetupBind
    private func setupBind() {
        let addButtonTap = PublishSubject<Void>()
        
        let input = PlaylistListViewModel.Input(addButtonTap: addButtonTap)
        let output = vm.transform(input: input)
        
        viewManager.addPlaylistButton.rx.tap
            .bind(to: addButtonTap)
            .disposed(by: disposeBag)
        
        
        
        output.pushToPostPlaylistVC
            .bind(with: self) { owner, _ in
                owner.pageTransition(to: PostPlaylistViewController(), type: .push)
            }
            .disposed(by: disposeBag)
        
    }
    
}
