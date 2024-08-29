//
//  PurchaseViewModel.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/29/24.
//

import Foundation
import RxSwift

final class PurchaseViewModel : BaseViewModelProtocol {
    let disposeBag = DisposeBag()
    
    struct Input {
        let buyButtonTap : PublishSubject<Void>
        let purchaseInfo : Observable<PurchaseInfo>
    }
    
    struct Output {
        
    }
    
    func transform(input : Input) -> Output {
        input.buyButtonTap
            .withLatestFrom(input.purchaseInfo)
            .bind(with: self) { owber, purchaseInfo in
                print("-----구매 로직!!!", purchaseInfo)
            }
            .disposed(by: disposeBag)
        
        
        
        return Output()
    }
}
