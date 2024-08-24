//
//  BaseView.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import UIKit
import SnapKit

class BaseView : UIView {
    let spinner = UIActivityIndicatorView()
    
    // MARK: - Initializer
    override init(frame : CGRect) {
        super.init(frame: frame)
        
        configureBackgroundColor()
        configureSpinnerUI()
        
        configureSubView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - ConfigureUI
    private func configureSpinnerUI() {
        self.addSubview(spinner)
        spinner.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
    }
    
    func configureSubView() {
    }
    
    func configureLayout() {
    }
    
}
