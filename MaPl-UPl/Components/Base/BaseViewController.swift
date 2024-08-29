//
//  BaseViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import UIKit
import RxSwift

class BaseViewController<BV : BaseView, VM : BaseViewModelProtocol> : UIViewController {
    let viewManager = BV.init()
    let vm = VM.init()
    let disposeBag = DisposeBag()
    
    let errorMessage = PublishSubject<String>()
    let isLoading = PublishSubject<Bool>()
    
    override func loadView() {
        view = viewManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBackButtonItem()
        hideKeyboardWhenTappedAround()
        setupBind()
    }
    
    
    // MARK: - ConfigureUI
    private func setupBind() {
        isLoading
            .bind(with: self) { owner, isLoading in
                if isLoading {
                    owner.viewManager.spinner.startAnimating()
                }else {
                    owner.viewManager.spinner.stopAnimating()
                }
            }
            .disposed(by: disposeBag)
        
        errorMessage
            .bind(with: self) { owner, message in
                owner.view.makeToast(message, position: .top)
            }
            .disposed(by: disposeBag)
    }
    
}

