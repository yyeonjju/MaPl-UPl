//
//  PlaylistListViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import UIKit
import RxSwift

final class PlaylistListViewController : BaseViewController<PlaylistListView, PlaylistListViewModel> {
    @UserDefaultsWrapper(key: .userInfo) var userInfo : LoginResponse?

    var previousIndex = 0
    var diffableDataSource: UICollectionViewDiffableDataSource<Int, PlaylistResponse>!
    
    let likeButtonTapSubject = PublishSubject<(Int, Bool)>()
    let loadDataTrigger = PublishSubject<String?>() //String는 커서 기반
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegate()
        setupBind()
        
        configureDataSource()
        updateSnapshot()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadDataTrigger.onNext(nil)
    }
    
    // MARK: - SetupDelegate
    private func setupDelegate() {
        
        viewManager.collectionView.delegate = self
        viewManager.collectionView.register(PlaylistCollectionViewCell.self, forCellWithReuseIdentifier: PlaylistCollectionViewCell.description())
    }

    
    // MARK: - SetupBind
    private func setupBind() {
        let addButtonTap = PublishSubject<Void>()
        
        let input = PlaylistListViewModel.Input(loadDataTrigger:loadDataTrigger, addButtonTap: addButtonTap, likeButtonTap : likeButtonTapSubject)
        let output = vm.transform(input: input)
        
        viewManager.addPlaylistButton.rx.tap
            .bind(to: addButtonTap)
            .disposed(by: disposeBag)
        
        //rxcocoa - prefetch
        viewManager.collectionView.rx.prefetchItems
            .compactMap(\.last?.row)
            .bind(with: self) { owner, row in
                guard row == owner.vm.playlistsData.count - 1 else { return }
                let lastItemId = owner.vm.playlistsData.last?.post_id
                owner.loadDataTrigger.onNext(lastItemId)
            }
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
                owner.updateSnapshot()
            }
            .disposed(by: disposeBag)
        
    }
    
    
    func configureDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource<Int, PlaylistResponse>(collectionView: viewManager.collectionView) {[weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCollectionViewCell.description(), for: indexPath) as! PlaylistCollectionViewCell
            guard let self, let userId = userInfo?.id else {return cell}
            
            indexPath.row == previousIndex ? increaseAnimation(zoomCell: cell) : decreaseAnimation(zoomCell: cell)
            
            let data = vm.playlistsData[indexPath.row]
            let isLiked = data.likes.contains(userId)
            cell.configureData(data: data, isLiked : isLiked)
            
            cell.likeButton.rx.tap
                .map{ !isLiked }
                .bind(with: self) { owner, toggleTo in
                    owner.likeButtonTapSubject.onNext((indexPath.row, toggleTo))
                }
                .disposed(by: cell.disposeBag)

            return cell
        }
    }

    func updateSnapshot() {
        // 초기 스냅샷 생성
        var snapshot = NSDiffableDataSourceSnapshot<Int, PlaylistResponse>()
        snapshot.appendSections([0])
        snapshot.appendItems(vm.playlistsData)
        
        // 스냅샷을 데이터 소스에 적용
        diffableDataSource.apply(snapshot)
    }
    
}


extension PlaylistListViewController : UITableViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let data = diffableDataSource.itemIdentifier(for: indexPath) else {return}
        
        let vc = PlaylistDetailViewController()
        vc.data = data
        pageTransition(to: vc, type: .push)
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

