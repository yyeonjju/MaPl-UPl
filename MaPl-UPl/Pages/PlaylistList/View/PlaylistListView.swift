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
    lazy var collectionView = {
        let layout = self.collectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        let horizontalInset = (UIScreen.main.bounds.width - layout.itemSize.width) / 2
        view.contentInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        view.contentInsetAdjustmentBehavior = .never
        view.decelerationRate = .fast
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.isPagingEnabled = false
        return view
    }()
    
    private func collectionViewFlowLayout() -> UICollectionViewFlowLayout {
      let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width: 300, height: 440)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = -10
      return layout
    }
    
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
        [collectionView, addPlaylistButton]
            .forEach{
                addSubview($0)
            }
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        addPlaylistButton.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            make.size.equalTo(60)
        }
    }

}
