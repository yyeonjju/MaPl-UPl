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
    
    override func loadView() {
        view = viewManager
    }
}

