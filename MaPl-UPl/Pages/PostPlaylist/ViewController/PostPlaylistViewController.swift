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
        let selectedBgImageData = PublishSubject<Data>()
        
        let input = PostPlaylistViewModel.Input(postPlaylistButtonTap : postPlaylistButtonTap, selectedBgImageData : selectedBgImageData)
        let output = vm.transform(input: input)
        
        
        //TODO: 이미지 바뀔 때마다 바인딩
        viewManager.postPlaylistButton.rx.tap
            .bind(onNext: { _ in
                selectedBgImageData.onNext(UIImage(systemName: "star")!.pngData()!)
            })
            .disposed(by: disposeBag)
        
        viewManager.postPlaylistButton.rx.tap
            .bind(to: postPlaylistButtonTap)
            .disposed(by: disposeBag)
        
        
        
        
    }
}
