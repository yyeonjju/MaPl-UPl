//
//  BasicColoredBackgroundSubtitleTableViewCell.swift
//  MaPl-UPl
//
//  Created by 하연주 on 9/1/24.
//

import UIKit

final class BasicColoredBackgroundSubtitleTableViewCell : BasicSubtitleTableViewCell {
    
    private let containerView = {
        let view = UIView()
        view.backgroundColor = Assets.Colors.pointPink
        view.layer.opacity = 0.3
        view.layer.cornerRadius = 20
        return view
    }()
    
    
    func configurePlaylistData(data : PlaylistResponse) {
        mainImageView.loadImage(filePath: data.files.first ?? "")
        titleLabel.text = data.title
        
        var songsPreviewText = ""
        let songs = [data.content1, data.content2, data.content3, data.content4, data.content5].compactMap{$0}
        
        for songStringForm in songs {
            let decodedSongData = stringToDecodedModel(string: songStringForm, model: SongInfo.self)
            let songShortInfo = "\(decodedSongData?.title ?? "")-\(decodedSongData?.artistName ?? "" ) / "
            songsPreviewText.append(songShortInfo)
        }
        
        subtitleLabel.text = songsPreviewText
    }
    
    override func configureSubView() {
        contentView.addSubview(containerView)
        
        super.configureSubView()
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(2)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.trailing.equalTo(containerView).offset(-4)
        }
    }

}
