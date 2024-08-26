//
//  MusicPagerViewCell.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/26/24.
//

import Foundation
import FSPagerView
import SnapKit
import Kingfisher

final class MusicPagerViewCell : FSPagerViewCell {
    // MARK: - UI
    private let artworkImageView = {
        let iv = UIImageView()
        iv.configureDefaultImageView()
        return iv
    }()
    
    private let musicTitleLabel = {
        let label = UILabel()
        label.text = "음악 제목"
        label.font = Font.bold14
        label.textColor = Assets.Colors.white
        return label
    }()
    
    private let musicArtistLabel = {
        let label = UILabel()
        label.text = "아티스트"
        label.font = Font.regular13
        label.textColor = Assets.Colors.white
        return label
    }()
    
    // MARK: - Initializer
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        
        configureSubView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cofigureData(data : SongInfo) {
        let url = URL(string: data.artworkURL)
        artworkImageView.kf.setImage(with: url)
        musicTitleLabel.text = data.title
        musicArtistLabel.text = data.artistName
    }
    
    
    // MARK: - ConfigureUI
    
    private func configureSubView() {
        [artworkImageView, musicTitleLabel, musicArtistLabel]
            .forEach{
                contentView.addSubview($0)
            }
    }
    
    private func configureLayout() {
        artworkImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(contentView)
            make.height.equalTo(artworkImageView.snp.width).multipliedBy(1)
        }
        
        musicTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(artworkImageView.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(artworkImageView)
        }
        
        musicArtistLabel.snp.makeConstraints { make in
            make.top.equalTo(musicTitleLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(artworkImageView)
        }
    }

}
