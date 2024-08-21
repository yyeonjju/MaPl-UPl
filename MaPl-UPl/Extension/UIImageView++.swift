//
//  UIImageView++.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/21/24.
//

import UIKit

extension UIImageView {
    func configureDefaultImageView(bgColor : UIColor = Assets.Colors.gray5) {
        self.backgroundColor = bgColor
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
    }
    
}

