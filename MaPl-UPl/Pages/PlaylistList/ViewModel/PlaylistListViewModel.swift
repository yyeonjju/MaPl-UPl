//
//  PlaylistListViewModel.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/19/24.
//

import Foundation
import RxSwift

final class PlaylistListViewModel : BaseViewModelProtocol {
    let disposeBag = DisposeBag()
    var playlistsData : [PlaylistResponse] = [] {
        didSet {
            playlistsDataSubject.onNext(playlistsData)
        }
    }
    private let playlistsDataSubject = PublishSubject<[PlaylistResponse]>()
    
    struct Input {
        let viewDidLoadTrigger : Observable<Void>
        let addButtonTap : PublishSubject<Void>
        
    }
    
    struct Output {
        let pushToPostPlaylistVC : PublishSubject<Void>
        let isLoading : PublishSubject<Bool>
        let errorMessage : PublishSubject<String>
        let playlistsData : PublishSubject<[PlaylistResponse]>
    }
    
    func transform(input : Input) -> Output {
        let isLoadingSubject = PublishSubject<Bool>()
        let errorMessageSubject = PublishSubject<String>()
        
        input.viewDidLoadTrigger
            .map{
                ProductId.playlist
            }
            .flatMap{ productId in
                isLoadingSubject.onNext(true)
                return NetworkManager.shared.getPlaylistPosts(productId: productId)
            }
            .asDriver(onErrorJustReturn: .failure(FetchError.fetchEmitError))
            .drive(with: self) { owner, result in
                switch result{
                case .success(let posts) :
                    print("🌸success🌸",posts.data)
                    owner.playlistsData.append(contentsOf: posts.data)
                case .failure(let error as FetchError) :
                    errorMessageSubject.onNext(error.errorMessage)
                default:
                    print("default")
                    
                }
                isLoadingSubject.onNext(false)
            }
            .disposed(by: disposeBag)
            
        
        
        return Output(pushToPostPlaylistVC: input.addButtonTap, isLoading: isLoadingSubject, errorMessage: errorMessageSubject, playlistsData: playlistsDataSubject)
    }
    
}
