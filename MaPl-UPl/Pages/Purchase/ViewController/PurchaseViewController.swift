//
//  PurchaseViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/29/24.
//

import UIKit
import RxSwift

struct PurchaseInfo {
    var productName : String
    var editorName : String
    var price : Int
}


class PurchaseViewController : BaseViewController<PurchaseView, PurchaseViewModel> {

    // MARK: - Properties
    var purchaseInfo : PurchaseInfo?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        viewManager.section1.inputLabel.text = purchaseInfo?.productName
        viewManager.section2.inputLabel.text = purchaseInfo?.editorName
        viewManager.section3.inputLabel.text = "\(purchaseInfo?.price.formatted() ?? "-")"
        
        setupBind()
    }
    
    private func setupBind() {
        guard let purchaseInfo else {return }
        let buyButtonTapSubject = PublishSubject<Void>()
        let purchaseInfoObservable = Observable.just(purchaseInfo)
        
        let input = PurchaseViewModel.Input(buyButtonTap : buyButtonTapSubject, purchaseInfo : purchaseInfoObservable)
        let output = vm.transform(input: input)
        
        viewManager.buyButton.rx.tap
            .bind(to : buyButtonTapSubject)
            .disposed(by: disposeBag)
        
    }
}
