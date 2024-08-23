//
//  SelectedMusicCollectionViewCell.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/23/24.
//

import UIKit
import SnapKit
import RxSwift

final class SelectedMusicCollectionViewCell : UICollectionViewCell {
    
    // MARK: - Properties

    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    
    // MARK: - UI
    let artworkImageView  = {
        let iv = UIImageView()
        iv.configureDefaultImageView()
        return iv
    }()
    
    private let removeIconView : UIView = {
        let view = UIView()
        view.backgroundColor = Assets.Colors.gray4
        view.layer.borderColor = .none
        return view
    }()
    
    let removeButton : UIButton = {
        let btn = UIButton()
        
        let font = UIFont.systemFont(ofSize: 10)
        let configuration = UIImage.SymbolConfiguration(font: font) // <1>

        let image = UIImage(systemName: "xmark", withConfiguration: configuration)
        
        btn.setImage(image, for: .normal)
        btn.tintColor = Assets.Colors.gray2
        return btn
    }()
    
    let titleLabel = {
        let label = UILabel()
        label.text = "title title title"
        label.font = Font.bold14
        label.textColor = Assets.Colors.white
        return label
    }()
    
    let artistLabel = {
        let label = UILabel()
        label.text = "artist"
        label.font = Font.regular13
        label.textColor = Assets.Colors.white
        return label
    }()
    
    // MARK: - Initializer
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        configureSubView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ConfiureData
    func confiureData(data : SongInfo){
        let artworkUrl = URL(string: data.artworkURL)
        artworkImageView.kf.setImage(with: artworkUrl)
        titleLabel.text = data.title
        artistLabel.text = data.artistName
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        removeIconView.layer.cornerRadius = removeIconView.frame.width/2
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        removeIconView.layer.cornerRadius = removeIconView.frame.width/2
    }
    
    // MARK: - ConfigureUI
    
    private func configureSubView() {
        [artworkImageView, titleLabel, artistLabel, removeIconView]
            .forEach{
                contentView.addSubview($0)
            }
        
        removeIconView.addSubview(removeButton)
    }
    
    private func configureLayout() {
        artworkImageView.snp.makeConstraints { make in
            make.size.equalTo(72)
            make.top.equalTo(contentView).offset(4)
            make.centerX.equalTo(contentView)
        }
        
        removeIconView.snp.makeConstraints { make in
            make.centerX.equalTo(artworkImageView.snp.trailing)
            make.centerY.equalTo(artworkImageView.snp.top).offset(4)
            make.size.equalTo(20)
        }
        
        removeButton.snp.makeConstraints { make in
            make.center.equalTo(removeIconView)
            make.size.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(artworkImageView.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(contentView)
        }
        
        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.horizontalEdges.equalTo(contentView)
        }
    }

}
