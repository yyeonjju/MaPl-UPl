//
//  EmptyView.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/23/24.
//

import UIKit

final class EmptyView : BaseView {
    // MARK: - UI
    private let label = {
        let label = UILabel()
        label.textColor = Assets.Colors.gray2
        label.font = Font.bold16
        label.text = "노래를 검색하세요 :)"
        return label
    }()
    
    private let loadingSpinner = {
        let spinner = UIActivityIndicatorView()
        spinner.isHidden = true
        spinner.stopAnimating()
        return spinner
    }()
    
    
    // MARK: - ConfigureUI
    override func configureSubView() {
        [label, loadingSpinner]
            .forEach{
                addSubview($0)
            }
    }
    
    override func configureLayout() {
        label.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
        loadingSpinner.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
    }
    
    // MARK: - Method
    
    func controlLoadingSpinner(isLoading:Bool){
        loadingSpinner.isHidden = !isLoading
        label.isHidden = isLoading
        if isLoading{
            loadingSpinner.startAnimating()
        }else{
            loadingSpinner.stopAnimating()
        }
        
    }

}

