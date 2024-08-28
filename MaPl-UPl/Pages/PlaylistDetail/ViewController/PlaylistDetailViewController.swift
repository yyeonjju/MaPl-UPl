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
    var postId : String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegate()
        setupBind()
    }
    
    // MARK: - SetupBind

    private func setupBind() {
        guard let postId else{return}
        
        let playlistId = PublishSubject<String>()
        
        let input = PlaylistDetailViewModel.Input(playlistId: playlistId)
        let output = vm.transform(input: input)
        
        playlistId.onNext(postId)
        
        output.songsInfoData
            .bind(with: self) { owner, data in
               
                owner.viewManager.pagerView.reloadData()
            }
            .disposed(by: disposeBag)
        
        output.playlistBasicInfo
            .bind(with: self) { owner, info in
                owner.setupPlaylistInfo(data: info)
            }
            .disposed(by: disposeBag)
        
        output.errorMessage
            .bind(to: errorMessage)
            .disposed(by: disposeBag)
        
        output.isLoading
            .bind(to: isLoading)
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - SetupView
    private func setupPlaylistInfo(data : PlaylistDetailViewModel.PlaylistBasicInfo) {
        viewManager.bgImageView.loadImage(filePath: data.bgImage)
        viewManager.playlistTitle.text = data.title
        viewManager.editorLabel.text = "editor. \(data.editor)"
        
//        //플레이리스트의 첫번째 음악으로 플레이어 뷰 세팅
//        guard let firstMusic = vm.songsInfoData?.first else{return}
//        let imgUrl = URL(string: firstMusic.artworkURL)
//        viewManager.playerArtworkImageView.kf.setImage(with: imgUrl)
//        viewManager.playerTitleLabel.text = firstMusic.title
//        viewManager.playerArtistLabel.text = firstMusic.artistName
        
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
