//
//  PlaylistListView.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/19/24.
//

import UIKit
import SnapKit

final class PlaylistListView : BaseView {
    // MARK: - UI
    let addPlaylistButton = {
        let btn = UIButton()
        btn.backgroundColor = Assets.Colors.gray4
        btn.setImage(Assets.SystemImage.plus, for: .normal)
        btn.tintColor = Assets.Colors.white
        return btn
    }()
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addPlaylistButton.layer.cornerRadius = addPlaylistButton.frame.width/2
    }

    // MARK: - ConfigureUI
    
    override func configureSubView() {
        [addPlaylistButton]
            .forEach{
                addSubview($0)
            }
    }
    
    override func configureLayout() {
        addPlaylistButton.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            make.size.equalTo(60)
        }
    }

}
