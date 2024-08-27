//
//  PlaylistDetailView.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/26/24.
//

import UIKit
import SnapKit
import FSPagerView

final class PlaylistDetailView : BaseView {
    // MARK: - UI
    
    let bgImageView  = {
        let iv = UIImageView()
        iv.backgroundColor = Assets.Colors.gray5
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    private let blurEffectCoverView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    
    
    let playlistTitle = {
        let label = UILabel()
        label.text = "플레이리스트 제목"
        label.font = .systemFont(ofSize: 25, weight: .heavy)
        label.textAlignment = .center
        label.textColor = Assets.Colors.white
        return label
    }()
    
    let editorLabel = {
        let label = UILabel()
        label.text = "editor. "
        label.textColor = Assets.Colors.white
        label.font = Font.regular14
        return label
    }()
    private let underline = {
       let view = UIView()
        view.backgroundColor = Assets.Colors.pointPink
        return view
    }()
    
    
    let pagerView = {
        let pv = FSPagerView()
        pv.transformer = FSPagerViewTransformer(type: .coverFlow)
        pv.isInfinite = true
        let itemWidth = UIScreen.main.bounds.width / 2
        pv.itemSize = CGSize(width: itemWidth, height: itemWidth)
        return pv
    }()
    
    
    // MARK: - ConfigureUI
    
    override func configureSubView() {
        [bgImageView, blurEffectCoverView, playlistTitle, editorLabel, underline, pagerView]
            .forEach{
                addSubview($0)
            }
    }
    
    override func configureLayout() {
        bgImageView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        blurEffectCoverView.snp.makeConstraints { make in
            make.edges.equalTo(bgImageView)
        }
        playlistTitle.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
        editorLabel.snp.makeConstraints { make in
            make.top.equalTo(playlistTitle.snp.bottom).offset(4)
            make.centerX.equalTo(playlistTitle)
        }
        underline.snp.makeConstraints { make in
            make.top.equalTo(editorLabel.snp.bottom)
            make.height.equalTo(1.0)
            make.horizontalEdges.equalTo(editorLabel)
        }
        pagerView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(300)
        }
        
    }

}
