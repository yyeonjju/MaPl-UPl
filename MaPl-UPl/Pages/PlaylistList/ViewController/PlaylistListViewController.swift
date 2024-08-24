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
        let viewDidLoadTrigger = Observable.just(())
        let addButtonTap = PublishSubject<Void>()
        
        let input = PlaylistListViewModel.Input(viewDidLoadTrigger:viewDidLoadTrigger, addButtonTap: addButtonTap)
        let output = vm.transform(input: input)
        
        viewManager.addPlaylistButton.rx.tap
            .bind(to: addButtonTap)
            .disposed(by: disposeBag)
        
        
        //output
        output.pushToPostPlaylistVC
            .bind(with: self) { owner, _ in
                owner.pageTransition(to: PostPlaylistViewController(), type: .push)
            }
            .disposed(by: disposeBag)
        
        output.errorMessage
            .bind(with: self) { owner, message in
                owner.view.makeToast(message, position: .top)
            }
            .disposed(by: disposeBag)
        
        output.isLoading
            .bind(with: self) { owner, isLoading in
                if isLoading {
                    owner.viewManager.spinner.startAnimating()
                }else {
                    owner.viewManager.spinner.stopAnimating()
                }
            }
            .disposed(by: disposeBag)
        
        output.playlistsData
            .bind { data in
                print("💚💚💚data💚💚", data)
            }
            .disposed(by: disposeBag)
    }
    
}
