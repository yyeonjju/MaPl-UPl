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
    let mainImageView = {
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
    
    let subtitleLabel = {
        let label = UILabel()
        label.text = ""
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
        mainImageView.kf.setImage(with: artworkUrl)
        titleLabel.text = data.title
        subtitleLabel.text = data.artistName
    }
    
    // MARK: - ConfigureUI
    
    func configureSubView() {
        [mainImageView, titleLabel, subtitleLabel]
            .forEach{
                contentView.addSubview($0)
            }
    }
    
    func configureLayout() {
        mainImageView.snp.makeConstraints { make in
            make.leading.verticalEdges.equalTo(contentView).inset(8)
            make.width.equalTo(mainImageView.snp.height).multipliedBy(1)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(mainImageView.snp.trailing).offset(4)
            make.top.equalTo(mainImageView.snp.top)
//            make.trailing.equalTo(contentView).offset(-8)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
    }
}
