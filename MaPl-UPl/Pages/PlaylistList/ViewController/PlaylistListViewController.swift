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
    let purchaseButtonTapSubject = PublishSubject<Int>()
    let loadDataTrigger = PublishSubject<String?>() //String는 커서 기반 페이지네이션을 위한 것
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDataSource()
//        updateSnapshot()
        
        setupNavigation()
        setupDelegate()
        setupBind()
        
    }
    
    private func setupNavigation() {
        let myPage = UIBarButtonItem(image: UIImage(systemName: "person.circle"), style: .plain, target: self, action: #selector(myPageButtonClicked))
        navigationItem.rightBarButtonItem = myPage
    }
    
    @objc private func myPageButtonClicked() {
        pageTransition(to: MyPageViewController(), type: .push)
    }
    
    
    // MARK: - SetupDelegate
    private func setupDelegate() {
        
        viewManager.collectionView.delegate = self
        viewManager.collectionView.register(PlaylistCollectionViewCell.self, forCellWithReuseIdentifier: PlaylistCollectionViewCell.description())
    }

    
    // MARK: - SetupBind
    private func setupBind() {
        let addButtonTap = PublishSubject<Void>()
        
        let input = PlaylistListViewModel.Input(loadDataTrigger:loadDataTrigger, addButtonTap: addButtonTap, likeButtonTap : likeButtonTapSubject, purchaseButtonTap : purchaseButtonTapSubject)
        let output = vm.transform(input: input)
        
        loadDataTrigger.onNext(nil)
        
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
                let vc = PostPlaylistViewController()
                vc.reloadListData = {
                    owner.viewManager.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
                    owner.loadDataTrigger.onNext(nil)
                }
                owner.pageTransition(to: vc, type: .push)
            }
            .disposed(by: disposeBag)
        
        output.errorMessage
            .bind(to: errorMessage)
            .disposed(by: disposeBag)
        
        output.isLoading
            .bind(to: isLoading)
            .disposed(by: disposeBag)
        
        output.playlistsData
            .bind(with: self) { owner, data in
                print("💎💎💎💎💎💎💎💎")
                owner.updateSnapshot()
            }
            .disposed(by: disposeBag)
        
        output.pushToPostPurchaseVC
            .bind(with: self) { owner, index in
                let data = owner.vm.playlistsData[index]
                
                //이미 구매한 플리에 대해서는 구매창으로 넘어가지 않도록
                guard let userId = owner.userInfo?.id, !data.buyers.contains(userId) else{return}
                
                let vc = PurchaseViewController()
                vc.purchaseInfo = PurchaseInfo(postId : data.post_id, productName: data.title, editorName: data.creator.nick ?? "-", price: data.price ?? 0, buyerName: "하연주")

                owner.pageTransition(to: vc, type: .push)
            }
            .disposed(by: disposeBag)
        
    }
    
    
    func configureDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource<Int, PlaylistResponse>(collectionView: viewManager.collectionView) {[weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCollectionViewCell.description(), for: indexPath) as! PlaylistCollectionViewCell
            guard let self, let userId = userInfo?.id else {return cell}
            
            indexPath.row == previousIndex ? increaseAnimation(zoomCell: cell) : decreaseAnimation(zoomCell: cell)
            
//            let data = vm.playlistsData[indexPath.row]
            let isLiked = item.likes.contains(userId)
            let isPurchased = item.buyers.contains(userId)
            cell.configureData(data: item, isLiked : isLiked, isPurchased : isPurchased)
            
            cell.likeButton.rx.tap
                .map{ !isLiked }
                .bind(with: self) { owner, toggleTo in
                    owner.likeButtonTapSubject.onNext((indexPath.row, toggleTo))
                }
                .disposed(by: cell.disposeBag)
            
            cell.purchaseButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.purchaseButtonTapSubject.onNext(indexPath.row)
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
//        diffableDataSource.applySnapshotUsingReloadData(snapshot)
    }
    
}


extension PlaylistListViewController : UITableViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let data = diffableDataSource.itemIdentifier(for: indexPath) else {return}
        
        let vc = PlaylistDetailViewController()
        vc.postId = data.post_id
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
        print("🧡increaseAnimation🧡")
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            zoomCell.transform = .identity
        }, completion: nil)
    }
    
    func decreaseAnimation(zoomCell: UICollectionViewCell) {
        print("🧡🧡decreaseAnimation🧡🧡")
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            zoomCell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: nil)
    }

    
    
    
}

