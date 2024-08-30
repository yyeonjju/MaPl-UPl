//
//  PurchaseViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/29/24.
//

import UIKit
import RxSwift

struct PurchaseInfo {
    let postId : String
    let productName : String
    let editorName : String
    let price : Int
    let buyerName : String
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
        viewManager.buyButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = PaymentViewController()
                vc.purchaseInfo = owner.purchaseInfo
                owner.pageTransition(to: vc, type: .push)
            }
            .disposed(by: disposeBag)
        
    }
}
        
