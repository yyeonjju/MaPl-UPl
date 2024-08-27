//
//  PlaylistDetailViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/26/24.
//

import Foundation
import FSPagerView
import RxSwift
import Kingfisher

final class PlaylistDetailViewController : BaseViewController<PlaylistDetailView, PlaylistDetailViewModel> {
    
    // MARK: - Properties
    var data : PlaylistResponse?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegate()
        setupBind()
        setupView(data : data)
    }
    
    // MARK: - SetupBind

    private func setupBind() {
        guard let data else{return}
        
        let input = PlaylistDetailViewModel.Input(playlistData: Observable.just(data))
        let output = vm.transform(input: input)
        
//        output.songInfoData
//            .bind(with: self) { owner, data in
//                print("🌸")
//                owner.viewManager.pagerView.reloadData()
//                
//            }
//            .disposed(by: disposeBag)
        
    }
    
    // MARK: - SetupView
    private func setupView(data : PlaylistResponse?) {
        guard let data, let bgImage = data.files.first else {return}
        viewManager.bgImageView.loadImage(filePath: bgImage)
        viewManager.playlistTitle.text = data.title
        viewManager.editorLabel.text = "editor. \(data.creator.nick ?? "-")"
        
        //플레이리스트의 첫번째 음악으로 플레이어 뷰 세팅
        guard let firstMusic = vm.songsInfoData?.first else{return}
        let imgUrl = URL(string: firstMusic.artworkURL)
        viewManager.playerArtworkImageView.kf.setImage(with: imgUrl)
        viewManager.playerTitleLabel.text = firstMusic.title
        viewManager.playerArtistLabel.text = firstMusic.artistName
        
    }


    // MARK: - SetupDelegate
    private func setupDelegate() {
        viewManager.pagerView.delegate = self
        viewManager.pagerView.dataSource = self
        viewManager.pagerView.register(MusicPagerViewCell.self, forCellWithReuseIdentifier: MusicPagerViewCell.description())
    }
    
}

extension PlaylistDetailViewController : FSPagerViewDataSource, FSPagerViewDelegate {
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return vm.songsInfoData?.count ?? 0
    }
        
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: MusicPagerViewCell.description(), at: index) as! MusicPagerViewCell
        guard let data = vm.songsInfoData?[index] else {return cell}
        
        cell.cofigureData(data: data)
        return cell
    }
    
    
}
