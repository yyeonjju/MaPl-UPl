//
//  NormalOutlineTextField.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import UIKit

final class NormalOutlineTextField : UITextField {
    
    init(placeholder : String, borderColor : UIColor = Assets.Colors.pointPink) {
        super.init(frame: .zero)
        
        self.placeholder = placeholder
        self.borderStyle = .roundedRect
        self.layer.cornerRadius = 8
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = 2
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
