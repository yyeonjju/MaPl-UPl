//
//  PlaylistListViewModel.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/19/24.
//

import Foundation
import RxSwift

final class PlaylistListViewModel : BaseViewModelProtocol {
    @UserDefaultsWrapper(key: .userInfo) var userInfo : LoginResponse?
    let disposeBag = DisposeBag()
    var playlistsData : [PlaylistResponse] = [] {
        didSet {
            playlistsDataSubject.onNext(playlistsData)
        }
    }
    private let playlistsDataSubject = PublishSubject<[PlaylistResponse]>()
    
    struct Input {
        let loadDataTrigger : PublishSubject<String?> //커서 기반 페이지네이션을 위한 lastItemId
        let addButtonTap : PublishSubject<Void>
        let likeButtonTap : PublishSubject<(Int, Bool)>
        
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
        
        
        var nextCursor : String? = nil
        input.loadDataTrigger
            .map{
                nextCursor  = $0
                return (ProductId.playlist, $0 ?? "")
            }
            .flatMap{ (productId:String, lastItemId:String) in
                isLoadingSubject.onNext(true)
                return NetworkManager.shared.getPlaylistPosts(productId: productId, nextCursor : lastItemId)
            }
            .asDriver(onErrorJustReturn: .failure(FetchError.fetchEmitError))
            .drive(with: self) { owner, result in
                switch result{
                case .success(let posts) :
                    print("🌸success🌸",posts.data)
                    if nextCursor == nil {
                        owner.playlistsData = posts.data
                    }else {
                        owner.playlistsData.append(contentsOf: posts.data)
                    }

                case .failure(let error as FetchError) :
                    errorMessageSubject.onNext(error.errorMessage)
                default:
                    print("default")
                    
                }
                isLoadingSubject.onNext(false)
            }
            .disposed(by: disposeBag)
            
        
        var tappedIndex = 0
        input.likeButtonTap
            .withUnretained(self)
            .flatMap{ (owner, params : (Int, Bool) ) in
                //                isLoadingSubject.onNext(true)
                let index = params.0
                let toggleTo = params.1
                
                tappedIndex = index
                let postId = owner.playlistsData[index].post_id
                let body = LikeModel(like_status: toggleTo)
                return NetworkManager.shared.likePost(body: body, postId: postId)
            }
            .asDriver(onErrorJustReturn: .failure(FetchError.fetchEmitError))
            .drive(with: self) { owner, result in
                switch result{
                case .success(let likeResponse) :
                    print("🌸success🌸",likeResponse)
                    guard let userId = owner.userInfo?.id else {return }
                    
                    //response에 따라 데이터 변경
                    if likeResponse.like_status {
                        owner.playlistsData[tappedIndex].likes.append(userId)
                    } else {
                        let likes = owner.playlistsData[tappedIndex].likes.filter{
                            $0 != userId
                        }
                        owner.playlistsData[tappedIndex].likes = likes
                    }
                    

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
