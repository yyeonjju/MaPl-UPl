//
//  UnderlineTextField.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/21/24.
//

import UIKit
import SnapKit

final class UnderlinedTextField: UITextField {

    private let underline: UIView = UIView()

    init(placeholder : String) {
        super.init(frame: .zero)
        
        self.placeholder = placeholder
        setupUnderline()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUnderline() {
        underline.backgroundColor = Assets.Colors.pointPink
        addSubview(underline)
        
        
        
        underline.snp.makeConstraints { make in
             make.height.equalTo(1.0)
            make.leading.trailing.bottom.equalToSuperview()
         }
    }

}
