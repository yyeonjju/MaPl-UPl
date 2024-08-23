//
//  SearchMusicTableViewCell.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/21/24.
//

import UIKit
import SnapKit
import RxSwift

final class SearchMusicTableViewCell : BasicSubtitleTableViewCell {
    // MARK: - UI
    let selectButton = CapsuleShapeButton(title: "선택", normalBgColr: Assets.Colors.gray5)
    
    // MARK: - Properties

    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    
    // MARK: - ConfigureUI

    override func configureSubView() {
        super.configureSubView()
        
        contentView.addSubview(selectButton)
    }

    override func configureLayout() {
        super.configureLayout()
        
        selectButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-12)
            make.centerY.equalTo(contentView)
            make.width.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.trailing.equalTo(selectButton.snp.leading)
        }
        
        artistLabel.snp.makeConstraints { make in
            make.trailing.equalTo(selectButton.snp.leading)
        }
    }
}
