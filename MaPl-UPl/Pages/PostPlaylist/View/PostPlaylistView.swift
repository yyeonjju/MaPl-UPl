//
//  PostPlaylistView.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/19/24.
//

import UIKit
import SnapKit

final class PostPlaylistView : BaseView {
    // MARK: - UI
    let postPlaylistButton = MainNormalButton(title: "내 플리 등록하기")
    
    
    
    // MARK: - ConfigureUI
    
    override func configureSubView() {
        [postPlaylistButton]
            .forEach{
                addSubview($0)
            }
    }
    
    override func configureLayout() {
        postPlaylistButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(20)
        }
    }

}
