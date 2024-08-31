//
//  PlaylistCollectionViewCell.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/25/24.
//

import UIKit
import SnapKit
import RxSwift

final class PlaylistCollectionViewCell : UICollectionViewCell {
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - UI
    
    let bgImageView  = {
        let iv = UIImageView()
        iv.backgroundColor = Assets.Colors.gray5
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    private let blurEffectCoverView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    let titleLabel = {
        let label = UILabel()
        label.font = Font.bold18
        label.textColor = Assets.Colors.white
        label.textAlignment = .center
        return label
    }()
    
    let playlistImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 5
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.borderWidth = 1
        iv.layer.borderColor = Assets.Colors.gray4.cgColor
        return iv
    }()
    
    let songsPreviewTextLabel = {
        let label = UILabel()
        label.textColor = Assets.Colors.white
        label.font = Font.bold13
        return label
    }()
    
    private let likeImageView = {
       let iv = UIImageView()
        iv.image = Assets.SystemImage.likeEmpty
        iv.tintColor = Assets.Colors.white
        return iv
    }()
    let likeButton = UIButton()
    private let likeText = {
       let label = UILabel()
        label.text = "좋아요"
        label.font = Font.bold12
        label.textColor = Assets.Colors.white
        return label
    }()
    
    private let purchaseImageView = {
       let iv = UIImageView()
        iv.image = Assets.SystemImage.banknoteEmpty
        iv.tintColor = Assets.Colors.white
        return iv
    }()
    let purchaseButton = UIButton()
    private let purchaseText = {
       let label = UILabel()
        label.text = "구매하기"
        label.font = Font.bold12
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
    
    
    // MARK: - ConfigureData
    func configureData(data : PlaylistResponse, isLiked : Bool, isPurchased : Bool) {
        let fileURL = data.files.first ?? ""
        bgImageView.loadImage(filePath: fileURL)
        playlistImageView.loadImage(filePath: fileURL)
        titleLabel.text = data.title
        
        likeImageView.image = isLiked ? Assets.SystemImage.likeFill :  Assets.SystemImage.likeEmpty
        
        purchaseImageView.image = isPurchased ? Assets.SystemImage.checkmark : 
        Assets.SystemImage.banknoteEmpty
        purchaseText.text = isPurchased ? "구매 완료" : "구매하기"
        
        
        var songsPreviewText = ""
        let songs = [data.content1, data.content2, data.content3, data.content4, data.content5].compactMap{$0}
        for songStringForm in songs {
            let decodedSongData = stringToDecodedModel(string: songStringForm, model: SongInfo.self)
            let songShortInfo = "🎵\(decodedSongData?.title ?? "")-\(decodedSongData?.artistName ?? "" ) "
            songsPreviewText.append(songShortInfo)
        }
        songsPreviewTextLabel.text = songsPreviewText
        
    }

    
    // MARK: - ConfigureUI
    
    private func configureSubView() {
        [bgImageView, titleLabel, playlistImageView, songsPreviewTextLabel, likeButton, likeImageView, likeText, purchaseImageView, purchaseButton, purchaseText]
            .forEach{
                contentView.addSubview($0)
            }
        bgImageView.addSubview(blurEffectCoverView)
    }
    
    private func configureLayout() {
        bgImageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        
        blurEffectCoverView.snp.makeConstraints { make in
            make.edges.equalTo(bgImageView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(bgImageView).offset(20)
            make.leading.trailing.equalTo(bgImageView)
        }
        
        playlistImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.width.equalTo(bgImageView).multipliedBy(0.8)
            make.height.equalTo(bgImageView).multipliedBy(0.55)
            make.centerX.equalTo(bgImageView)
        }
        
        songsPreviewTextLabel.snp.makeConstraints { make in
            make.top.equalTo(playlistImageView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(playlistImageView)
        }
        
        likeImageView.snp.makeConstraints { make in
            make.centerX.equalTo(likeText)
            make.bottom.equalTo(likeText.snp.top).offset(-8)
            make.size.equalTo(32)
        }
        likeButton.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(likeImageView)
            make.bottom.equalTo(likeText)
        }
        
        likeText.snp.makeConstraints { make in
            make.bottom.equalTo(bgImageView).inset(20)
            make.leading.equalTo(bgImageView).inset(30)
        }
        
        
        purchaseImageView.snp.makeConstraints { make in
            make.centerX.equalTo(purchaseText)
            make.bottom.equalTo(purchaseText.snp.top).offset(-8)
            make.height.equalTo(24)
            make.width.equalTo(32)
        }
        purchaseButton.snp.makeConstraints { make in
            make.edges.equalTo(purchaseImageView)
        }
        
        purchaseText.snp.makeConstraints { make in
            make.bottom.equalTo(bgImageView).inset(20)
            make.trailing.equalTo(bgImageView).inset(30)
        }
    }

}



