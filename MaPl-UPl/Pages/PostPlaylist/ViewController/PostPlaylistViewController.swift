//
//  PostPlaylistViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import UIKit
import RxSwift

final class PostPlaylistViewController : BaseViewController<PostPlaylistView, PostPlaylistViewModel> {
    // MARK: - UI
    // MARK: - Properties
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBind()
    }
    
    private func setupBind() {
        let postPlaylistButtonTap = PublishSubject<Void>()
        
        let input = PostPlaylistViewModel.Input(postPlaylistButtonTap : postPlaylistButtonTap)
        let output = vm.transform(input: input)
        
        viewManager.postPlaylistButton.rx.tap
            .bind(to: postPlaylistButtonTap)
            .disposed(by: disposeBag)
        
        
        
        
    }
}
