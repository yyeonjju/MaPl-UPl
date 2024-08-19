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
        
//        self.layer.shadowColor = Assets.Colors.pointPink.cgColor
//        self.layer.shadowRadius = 5
//        self.layer.shadowOpacity = 1
//        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        var config = UIButton.Configuration.gray()
        config.title = title
        config.baseForegroundColor = Assets.Colors.white
        config.baseBackgroundColor = bgColor
        config.titleAlignment = .center
        config.imagePadding = 10
        self.configuration = config
        
        self.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
