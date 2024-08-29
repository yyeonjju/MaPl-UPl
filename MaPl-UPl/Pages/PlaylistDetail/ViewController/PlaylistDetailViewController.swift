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
import AVFoundation
import RxCocoa

final class PlaylistDetailViewController : BaseViewController<PlaylistDetailView, PlaylistDetailViewModel> {
    enum PlayerState {
        case playing
        case paused
        case unknown
    }
    
    // MARK: - Properties
    var postId : String?
    private let avPlayer = AVPlayer()
    private var avPlayerItem : AVPlayerItem?
    private let playerState = PublishSubject<PlayerState>()
    private let currentSongIndex = PublishSubject<Int>()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegate()
        setupBind()
//        setupAddObserver()
        
        NotificationCenter.default
            .addObserver(self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: avPlayer.currentItem
        )
        
//        avPlayerItem.특정 이거가 끝나는 시점을 안다면..?
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        avPlayer.pause()
        avPlayer.seek(to: .zero) //재생구간 0으로 이동
    }
    
    
    
    @objc func playerDidFinishPlaying(_ note: NSNotification) {
        print("🩵🩵🩵🩵🩵. 이거 재생 끝났어!!--->    ", viewManager.pagerView.currentIndex)
        if viewManager.pagerView.currentIndex + 1 == vm.songsInfoData?.count {
            viewManager.pagerView.scrollToItem(at: 0, animated: true)
        } else {
            viewManager.pagerView.scrollToItem(at: viewManager.pagerView.currentIndex+1, animated: true)
        }

        avPlayer.play()
    }

    
    // MARK: - SetupBind

    private func setupBind() {
        guard let postId else{return}
        
        let playlistId = PublishSubject<String>()
        
        let input = PlaylistDetailViewModel.Input(playlistId: playlistId, currentSongIndex : currentSongIndex)
        let output = vm.transform(input: input)
        
        playlistId.onNext(postId)
        
        output.songsInfoData
            .bind(with: self) { owner, data in
                owner.viewManager.pagerView.reloadData()
                
                //플레이리스트의 첫번째 음악으로 플레이어 뷰 세팅
//                owner.currentSongIndex.onNext(0)
                owner.playerState.onNext(.unknown)

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
        
        output.currentSongIndex
            .bind(with: self) { owner, index in
                guard let currentSongpPreviewURL = owner.vm.songsInfoData?[index].previewURL else {return }
                
                //하단 플레이어뷰에 보여주기
                owner.setupPlayerItem(index: index)
                //AVPlayerItem 갈아끼우기
                owner.avPlayerItem = AVPlayerItem(url: currentSongpPreviewURL)
                
//                owner.avPlayerItem?.AVPlayerItemDidPlayToEndTimeNotification
//                print("owner.avPlayerItem", owner.avPlayerItem?.status)
                owner.avPlayer.replaceCurrentItem(with: owner.avPlayerItem )
                
//                let time = CMTimeGetSeconds(owner.avPlayer.currentTime()) // 현재 진행 위치
//                
//                print("💛💛💛currentSongIndex - time💛💛💛", time)
            }
        
            .disposed(by: disposeBag)
        
        viewManager.playerStateButton.rx.tap
            .withLatestFrom(playerState)
            .bind(with: self) { owner, state in
                switch state{
                case .playing :
                    owner.playerState.onNext(.paused)

                case .paused, .unknown :
                    owner.playerState.onNext(.playing)

                }
            }
            .disposed(by: disposeBag)
        
        
        playerState
            .bind(with: self) { owner, state in
                print("✅✅state✅✅", state)
                switch state{
                case .playing :
                    owner.avPlayer.play()
                    owner.viewManager.playerStateButton.setImage(Assets.SystemImage.pauseFill, for: .normal)
                case .paused :
                    owner.avPlayer.pause()
                    owner.viewManager.playerStateButton.setImage(Assets.SystemImage.playFill, for: .normal)
                case .unknown :
                    owner.viewManager.playerStateButton.setImage(Assets.SystemImage.playFill, for: .normal)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
//    private func setupAddObserver() {
//        print("💜")
//        avPlayer.addObserver(self, forKeyPath: "rate", options: [], context: nil)
//    }
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "rate", let player = object as? AVPlayer {
//            print("💜", player.rate,"💜", player.isMuted)
//            if player.rate == 1 {
//                print("💜💜💜1💜💜")
//                print("Playing")
//            } else {
//                print("💜💜💜0💜💜")
//                print("Paused")
//            }
//        }
//            
//            
//        }
    
    // MARK: - SetupView
    private func setupPlaylistInfo(data : PlaylistDetailViewModel.PlaylistBasicInfo) {
        viewManager.bgImageView.loadImage(filePath: data.bgImage)
        viewManager.playlistTitle.text = data.title
        viewManager.editorLabel.text = "editor. \(data.editor)"
        
    }
    
    private func setupPlayerItem(index : Int) {
        guard let song = vm.songsInfoData?[index] else{return}
        let imgUrl = URL(string: song.artworkURL)
        viewManager.playerArtworkImageView.kf.setImage(with: imgUrl)
        viewManager.playerTitleLabel.text = song.title
        viewManager.playerArtistLabel.text = song.artistName
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
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        print("🎀", index)
        currentSongIndex.onNext(pagerView.currentIndex)
        viewManager.pagerView.scrollToItem(at: index, animated: true)
//        currentSongIndex.onNext(index)
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        //처음 0index 조절할 때, 옆에 있는거 클릭했을 때, 노래 끝나고 다음 노래로 넘어갈 때
        print("🎀🎀🎀", pagerView.currentIndex)
        currentSongIndex.onNext(pagerView.currentIndex)
//        avPlayer.seekToTime(kCMTimeZero)

    }
    
    
}
