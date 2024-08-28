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
        view.backgroundColor = Assets.Colors.white
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
    
    private let playerView = {
        let view = UIView()
        view.backgroundColor = Assets.Colors.white
        view.layer.cornerRadius = 40
        view.layer.opacity = 0.3
        //        view.clipsToBounds = true
        return view
    }()
    
    let playerArtworkImageView = {
        let iv = UIImageView()
        iv.backgroundColor = Assets.Colors.gray4
        iv.clipsToBounds = true
        return iv
    }()
    
    let playerTitleLabel = {
        let label = UILabel()
        label.text = "-"
        label.font = Font.bold16
        label.textColor = Assets.Colors.white
        return label
    }()
    
    let playerArtistLabel = {
        let label = UILabel()
        label.text = "-"
        label.font = Font.regular13
        label.textColor = Assets.Colors.white
        return label
    }()
    
    let playerStateButton = {
       let button = UIButton()
//        button.setImage(Assets.SystemImage.playFill, for: .normal)
        button.tintColor = Assets.Colors.white
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        playerArtworkImageView.layer.cornerRadius = playerArtworkImageView.bounds.width / 2
    }

    
    
    // MARK: - ConfigureUI
    
    override func configureSubView() {
        [bgImageView, blurEffectCoverView, playlistTitle, editorLabel, underline, pagerView, playerView, playerArtworkImageView, playerStateButton, playerTitleLabel, playerArtistLabel]
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
        
        
        //playerView
        playerView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(10)
            make.bottom.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(80)
        }
        playerArtworkImageView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(playerView).inset(10)
            make.width.equalTo(playerArtworkImageView.snp.height).multipliedBy(1)
            make.leading.equalTo(playerView).offset(20)
        }
        
        playerTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(playerArtworkImageView.snp.trailing).offset(10)
            make.trailing.equalTo(playerStateButton.snp.leading)
            make.top.equalTo(playerArtworkImageView).offset(8)
        }
        
        playerArtistLabel.snp.makeConstraints { make in
            make.leading.equalTo(playerArtworkImageView.snp.trailing).offset(10)
            make.trailing.equalTo(playerStateButton.snp.leading)
            make.top.equalTo(playerTitleLabel.snp.bottom).offset(4)
        }
        
        playerStateButton.snp.makeConstraints { make in
            make.trailing.equalTo(playerView).offset(-20)
            make.centerY.equalTo(playerView)
            make.size.equalTo(24)
        }
        
    }

}
