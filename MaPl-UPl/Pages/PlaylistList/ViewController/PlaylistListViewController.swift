//
//  PlaylistListViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import UIKit
import RxSwift

final class PlaylistListViewController : BaseViewController<PlaylistListView, PlaylistListViewModel> {

    var previousIndex = 0
    var zoomInIndex = BehaviorSubject(value: 0)
    var zoomOutIndex = PublishSubject<Int>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegate()
        setupBind()
    }
    
    // MARK: - SetupDelegate
    private func setupDelegate() {
        
        viewManager.collectionView.delegate = self
        viewManager.collectionView.dataSource = self
        viewManager.collectionView.register(PlaylistCollectionViewCell.self, forCellWithReuseIdentifier: PlaylistCollectionViewCell.description())
    }

    
    // MARK: - SetupBind
    private func setupBind() {
        let viewDidLoadTrigger = Observable.just(())
        let addButtonTap = PublishSubject<Void>()
        
        let input = PlaylistListViewModel.Input(viewDidLoadTrigger:viewDidLoadTrigger, addButtonTap: addButtonTap)
        let output = vm.transform(input: input)
        
        viewManager.addPlaylistButton.rx.tap
            .bind(to: addButtonTap)
            .disposed(by: disposeBag)
        
        
        //output
        output.pushToPostPlaylistVC
            .bind(with: self) { owner, _ in
                owner.pageTransition(to: PostPlaylistViewController(), type: .push)
            }
            .disposed(by: disposeBag)
        
        output.errorMessage
            .bind(with: self) { owner, message in
                owner.view.makeToast(message, position: .top)
            }
            .disposed(by: disposeBag)
        
        output.isLoading
            .bind(with: self) { owner, isLoading in
                if isLoading {
                    owner.viewManager.spinner.startAnimating()
                }else {
                    owner.viewManager.spinner.stopAnimating()
                }
            }
            .disposed(by: disposeBag)
        
        output.playlistsData
            .bind(with: self) { owner, data in
                owner.viewManager.collectionView.reloadData()
            }
            .disposed(by: disposeBag)
        
//            .bind(to: viewManager.collectionView.rx.items(cellIdentifier: PlaylistCollectionViewCell.description(), cellType: PlaylistCollectionViewCell.self)){[weak self] (row, element, cell : PlaylistCollectionViewCell) in
//
//            }
//            .disposed(by: disposeBag)
        
        
    }
    
}







extension PlaylistListViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.playlistsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCollectionViewCell.description(), for: indexPath) as! PlaylistCollectionViewCell
        indexPath.row == previousIndex ? increaseAnimation(zoomCell: cell) : decreaseAnimation(zoomCell: cell)
        return cell
    }
}



extension PlaylistListViewController: UICollectionViewDelegateFlowLayout {
    
    ///Paging Animation
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = viewManager.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let cellWidth = layout.itemSize.width + layout.minimumLineSpacing
        let offsetX = targetContentOffset.pointee.x
        let index = (offsetX + scrollView.contentInset.left) / cellWidth
        let roundedIndex = round(index)
        targetContentOffset.pointee = CGPoint(x: roundedIndex * cellWidth - scrollView.contentInset.left, y: 0)
    }
    
    ///Zoom Animation
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let collectionView = viewManager.collectionView
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let cellWidth = layout.itemSize.width + layout.minimumLineSpacing
        let offsetX = collectionView.contentOffset.x
        let index = (offsetX + scrollView.contentInset.left) / cellWidth
        let roundedIndex = round(index)
        let indexPath = IndexPath(item: Int(roundedIndex), section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) {
            increaseAnimation(zoomCell: cell)
        }
        
        
        if Int(roundedIndex) != previousIndex {
            let preIndexPath = IndexPath(item: previousIndex, section: 0)
            if let preCell = collectionView.cellForItem(at: preIndexPath) {
                decreaseAnimation(zoomCell: preCell)
            }
            previousIndex = indexPath.item
        }
    }
    
    func increaseAnimation(zoomCell: UICollectionViewCell) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            zoomCell.transform = .identity
        }, completion: nil)
    }
    
    func decreaseAnimation(zoomCell: UICollectionViewCell) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            zoomCell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: nil)
    }

    
    
    
}

