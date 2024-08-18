//
//  BaseViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import UIKit

class BaseViewController<BV : BaseView, VM : BaseViewModelProtocol> : UIViewController {
    let viewManager = BV.init()
    let vm = VM.init()
    
    override func loadView() {
        view = viewManager
    }
}

