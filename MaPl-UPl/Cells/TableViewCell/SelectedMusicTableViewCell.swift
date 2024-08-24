//
//  SelectedMusicTableViewCell.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/21/24.
//

import UIKit
import SnapKit

final class SelectedMusicTableViewCell : BasicSubtitleTableViewCell {
    var removeItem : (()->Void)?
    
    
    // MARK: - UI
    private let dragImageView = {
        let iv = UIImageView()
        iv.image = Assets.SystemImage.threeLines
        iv.tintColor = Assets.Colors.gray3
        return iv
    }()
    
    let optionsButton = {
        let button = UIButton()
        button.setImage(Assets.SystemImage.options, for: .normal)
        button.tintColor = Assets.Colors.gray3
        button.transform = CGAffineTransform(rotationAngle: .pi / 2)
        return button
    }()
    
    // MARK: - Initianlizer

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupOptionsMenuItem()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup

    
    
    private func setupOptionsMenuItem() {
        let removeMusic = UIAction(title: "이 노래 지우기"){ [weak self] _ in
            guard let self else{return}
            
            removeItem?()
        }
        
        let items = [removeMusic]
        let menu = UIMenu(children: items)
        optionsButton.menu = menu
        optionsButton.showsMenuAsPrimaryAction = true
    }
    
    
    // MARK: - ConfigureUI
    
    override func configureSubView() {
        super.configureSubView()
        
        [dragImageView, optionsButton]
            .forEach{
                contentView.addSubview($0)
            }
    }
    
    override func configureLayout() {
        
        dragImageView.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(4)
            make.centerY.equalTo(contentView)
            make.width.equalTo(18)
        }
        
        artworkImageView.snp.makeConstraints { make in
            make.leading.equalTo(dragImageView.snp.trailing).offset(4)
            make.verticalEdges.equalTo(contentView).inset(8)
            make.width.equalTo(artworkImageView.snp.height).multipliedBy(1)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(artworkImageView.snp.trailing).offset(4)
            make.top.equalTo(artworkImageView.snp.top)
        }
        
        artistLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        optionsButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-4)
//            make.top.equalTo(contentView).offset(4)
            make.centerY.equalTo(contentView)
            
        }
        
    }

}
