//
//  BuyItemListViewModel.swift
//  MaPl-UPl
//
//  Created by 하연주 on 9/1/24.
//

import Foundation
import RxSwift

final class BuyItemListViewModel : BaseViewModelProtocol {
    let disposeBag = DisposeBag()
    
    var paymentsData : [PlaylistPayment] = [] {
        didSet{
            paymentsDataSubject.onNext(paymentsData)
        }
    }
    
    let paymentsDataSubject = PublishSubject<[PlaylistPayment]>()
    
    struct Input {
        let loadDataTrigger : Observable<Void>
    }
    
    struct Output {
        let paymentsData : PublishSubject<[PlaylistPayment]>
        let errorMessage : PublishSubject<String>
        let isLoading : PublishSubject<Bool>
    }
    
    func transform(input : Input) -> Output {
        let errorMessageSubject = PublishSubject<String>()
        let isLoadingSubject = PublishSubject<Bool>()
        
        input.loadDataTrigger
            .flatMap{ cursor in
                isLoadingSubject.onNext(true)
                return NetworkManager.shared.getPayments()
            }
            .asDriver(onErrorJustReturn: .failure(FetchError.fetchEmitError))
            .drive(with: self) { owner, result in
                switch result{
                case .success(let value) :
                    print("🌸success🌸",value)
                    owner.paymentsData = value.data
                case .failure(let error as FetchError) :
                    errorMessageSubject.onNext(error.errorMessage)
                default:
                    print("default")
                    
                }
                
                isLoadingSubject.onNext(false)
            }
            .disposed(by: disposeBag)
        
        return Output(paymentsData: paymentsDataSubject, errorMessage : errorMessageSubject, isLoading: isLoadingSubject)
    }
}
