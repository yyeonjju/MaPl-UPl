//
//  MainNormalButton.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import UIKit
import SnapKit

final class MainNormalButton : UIButton{

    init(title : String, bgColor : UIColor = Assets.Colors.gray3) {
        super.init(frame: .zero)
        
        self.layer.cornerRadius = 16
        self.backgroundColor = bgColor
        self.setTitleColor(Assets.Colors.white, for: .normal)
        self.setTitle(title, for: .normal)
        
        self.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
