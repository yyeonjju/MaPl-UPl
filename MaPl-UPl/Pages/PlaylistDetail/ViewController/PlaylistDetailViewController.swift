//
//  PlaylistDetailViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/26/24.
//

import Foundation
import FSPagerView
import RxSwift

final class PlaylistDetailViewController : BaseViewController<PlaylistDetailView, PlaylistDetailViewModel> {
    
    // MARK: - Properties
    var data : PlaylistResponse?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView(data : data)
        setupDelegate()
        setupBind()
    }
    
    // MARK: - SetupBind

    private func setupBind() {
        guard let data else{return}
        
        let input = PlaylistDetailViewModel.Input(playlistData: Observable.just(data))
        let output = vm.transform(input: input)
        
        output.songInfoData
            .bind(with: self) { owner, data in
                owner.viewManager.pagerView.reloadData()
            }
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - SetupView
    private func setupView(data : PlaylistResponse?) {
        guard let data, let bgImage = data.files.first else {return}
        viewManager.bgImageView.loadImage(filePath: bgImage)
        viewManager.playlistTitle.text = data.title
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
