//
//  SearchMusicView.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/23/24.
//

import UIKit
import SnapKit

final class SearchMusicView : BaseView {
    // MARK: - UI
    let searchBar = UISearchBar()
    let tableView = UITableView()
    let emptyView = EmptyView()
    let selectedMusicArea = {
        let view = UIView()
        view.backgroundColor = Assets.Colors.pointPink
        view.layer.cornerRadius = 28
        return view
    }()
    let selectText = {
        let text = UILabel()
        text.text = "선택한 음악"
        text.textColor = Assets.Colors.white
        text.font = Font.bold13
        return text
    }()
    let lineImage = {
        let iv = UIImageView()
        iv.image = Assets.SystemImage.line
        iv.tintColor = Assets.Colors.white
        return iv
    }()
    lazy var collectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionVewLayout())
        cv.backgroundColor = .clear
        return cv
    }()
    
    
    func configureCollectionVewLayout () -> UICollectionViewLayout{
        let layout = UICollectionViewFlowLayout()
        let inset = UIEdgeInsets(top: 0, left:  20, bottom: 0, right:  20)
        layout.itemSize = CGSize(width: 72, height: 116)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = inset
        
        return layout
    }

    
    
    // MARK: - ConfigureUI
    
    override func configureSubView() {
        [searchBar, tableView, emptyView, selectedMusicArea]
            .forEach{
                addSubview($0)
            }
        [selectText,lineImage, collectionView]
            .forEach{
                selectedMusicArea.addSubview($0)
            }
        
    }
    
    override func configureLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(selectedMusicArea.snp.top)
        }
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(selectedMusicArea.snp.top)
        }
        
        selectedMusicArea.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(self)
            make.height.equalTo(144)
        }
        selectText.snp.makeConstraints { make in
            make.leading.equalTo(selectedMusicArea).inset(12)
            make.top.leading.equalTo(selectedMusicArea).inset(8)
        }
        lineImage.snp.makeConstraints { make in
            make.centerX.equalTo(selectedMusicArea)
            make.top.equalTo(selectedMusicArea).offset(4)
            make.width.equalTo(40)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(selectText.snp.bottom)
            make.horizontalEdges.equalTo(selectedMusicArea)
            make.bottom.equalTo(self)
        }
        
    }

}
