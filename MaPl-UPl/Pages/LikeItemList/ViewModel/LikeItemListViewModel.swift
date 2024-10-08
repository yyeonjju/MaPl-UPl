//
//  LikeItemListViewModel.swift
//  MaPl-UPl
//
//  Created by 하연주 on 9/1/24.
//

import Foundation
import RxSwift

final class LikeItemListViewModel : BaseViewModelProtocol {
    let disposeBag = DisposeBag()
    
    var likesData : [PlaylistResponse] = [] {
        didSet {
            likesDataSubject.onNext(likesData)
        }
    }
    let likesDataSubject = PublishSubject<[PlaylistResponse]>()
    
    struct Input {
        let loadDataTrigger : PublishSubject<String?>
    }
    
    struct Output {
        let likesData : PublishSubject<[PlaylistResponse]>
        let errorMessage : PublishSubject<String>
        let isLoading : PublishSubject<Bool>
    }
    
    func transform(input : Input) -> Output {
        let errorMessageSubject = PublishSubject<String>()
        let isLoadingSubject = PublishSubject<Bool>()
        
        var nextCursor : String? = nil
        input.loadDataTrigger
            .flatMap{ cursor in
                isLoadingSubject.onNext(true)
                nextCursor = cursor
                return NetworkManager.shared.getLikes(nextCursor: cursor ?? "")
            }
            .asDriver(onErrorJustReturn: .failure(FetchError.fetchEmitError))
            .drive(with: self) { owner, result in
                switch result{
                case .success(let value) :
                    print("🌸success🌸",value)
                    if nextCursor == nil {
                        owner.likesData = value.data
                    }else {
                        owner.likesData.append(contentsOf: value.data)
                    }

                case .failure(let error as FetchError) :
                    errorMessageSubject.onNext(error.errorMessage)
                default:
                    print("default")
                    
                }
                
                isLoadingSubject.onNext(false)
            }
            .disposed(by: disposeBag)
        
        
        return Output(likesData: likesDataSubject, errorMessage : errorMessageSubject, isLoading: isLoadingSubject)
    }
}
