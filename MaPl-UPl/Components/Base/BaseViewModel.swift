//
//  BaseViewModel.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import Foundation
import RxSwift

protocol BaseViewModelProtocol : AnyObject{
    associatedtype Input
    associatedtype Output
    
    init()
    
    var disposeBag : DisposeBag {get}
    
    func transform(input : Input) -> Output
}

