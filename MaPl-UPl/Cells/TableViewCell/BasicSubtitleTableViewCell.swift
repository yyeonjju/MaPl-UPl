//
//  BasicSubtitleTableViewCell.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/23/24.
//

import UIKit
import Kingfisher

class BasicSubtitleTableViewCell : UITableViewCell {
    // MARK: - UI
    let artworkImageView = {
        let view = UIImageView()
        view.configureDefaultImageView()

        return view
    }()
    
    let titleLabel = {
        let label = UILabel()
        label.text = "title title title"
        label.font = Font.bold16
        label.textColor = Assets.Colors.gray1
        return label
    }()
    
    let artistLabel = {
        let label = UILabel()
        label.text = "artistLabel"
        label.font = Font.regular13
        label.textColor = Assets.Colors.gray3
        return label
    }()
    
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubView()
        configureLayout()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ConfigureData
    func confiureData(data : SongInfo) {
        let artworkUrl = URL(string: data.artworkURL)
        artworkImageView.kf.setImage(with: artworkUrl)
        titleLabel.text = data.title
        artistLabel.text = data.artistName
    }

    
    // MARK: - ConfigureUI
    
    func configureSubView() {
        [artworkImageView, titleLabel, artistLabel]
            .forEach{
                contentView.addSubview($0)
            }
    }
    
    func configureLayout() {
        artworkImageView.snp.makeConstraints { make in
            make.leading.verticalEdges.equalTo(contentView).inset(8)
            make.width.equalTo(artworkImageView.snp.height).multipliedBy(1)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(artworkImageView.snp.trailing).offset(4)
            make.top.equalTo(artworkImageView.snp.top)
//            make.trailing.equalTo(contentView).offset(-8)
        }
        
        artistLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
    }
}
