//
//  PostPlaylistViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import UIKit
import RxSwift

final class PostPlaylistViewController : BaseViewController<PostPlaylistView, PostPlaylistViewModel> {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegate()
        setupBind()
    }
    
    private func setupDelegate() {
        viewManager.selectedMusicTableView.dataSource = self
        viewManager.selectedMusicTableView.delegate = self
        viewManager.selectedMusicTableView.register(SelectedMusicTableViewCell.self, forCellReuseIdentifier: SelectedMusicTableViewCell.description())
        
        viewManager.selectedMusicTableView.dragDelegate = self
        viewManager.selectedMusicTableView.dropDelegate = self
        viewManager.selectedMusicTableView.dragInteractionEnabled = true
        
    }
    
    private func setupBind() {
        let postPlaylistButtonTap = PublishSubject<Void>()
        let selectedBgImageData = PublishSubject<Data>()
        let searchMusicButtonTap = PublishSubject<Void>()
        
        let input = PostPlaylistViewModel.Input(postPlaylistButtonTap : postPlaylistButtonTap, selectedBgImageData : selectedBgImageData, searchMusicButtonTap:searchMusicButtonTap)
        let output = vm.transform(input: input)
        
        
        //TODO: 이미지 바뀔 때마다 바인딩
        viewManager.postPlaylistButton.rx.tap
            .bind(onNext: { _ in
                selectedBgImageData.onNext(UIImage(systemName: "star")!.pngData()!)
            })
            .disposed(by: disposeBag)
        
        viewManager.postPlaylistButton.rx.tap
            .bind(to: postPlaylistButtonTap)
            .disposed(by: disposeBag)
        
        viewManager.searchMusicButton.rx.tap
            .bind(to: searchMusicButtonTap)
            .disposed(by: disposeBag)
        
        
        //output
        output.errorMessage
            .bind(with: self) { owner, message in
                owner.view.makeToast(message, position: .top)
            }
            .disposed(by: disposeBag)
        
        output.isLoading
            .bind(with: self) { owner, isLoading in
                owner.viewManager.postPlaylistButton.isEnabled = !isLoading
                owner.viewManager.postPlaylistButton.configuration?.showsActivityIndicator = isLoading // spin ui 보여주기
            }
            .disposed(by: disposeBag)
        
        output.uploadComplete
            .bind(with: self) { owner, complete in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.pushToSearchMusicVC
            .bind(with: self) { owner, _ in
                owner.pageTransition(to: SearchMusicViewController(), type: .push)
            }
            .disposed(by: disposeBag)
        
    }
}

extension PostPlaylistViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectedMusicTableViewCell.description(), for: indexPath) as! SelectedMusicTableViewCell
        let data = selectedSongList[indexPath.row]
        
        cell.confiureData(data: data)
        return cell
    }
}

extension PostPlaylistViewController : UITableViewDragDelegate, UITableViewDropDelegate {

    ///itemsForBeginning : 드레그 시작
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        // NSItemProvider: 현재 앱이 다른 앱에 데이터를 전달하는 목적으로 사용
        // 화면 하나에 여러 가지 앱이 띄워져 있을 경우, 다른 앱으로 drop하여 아이템을 전달할 때, 이 NSItemProvider()에 담아서 전송한다
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
    ///dropSessionDidUpdate : 드래그의 상태에 따라 DropProposal 반환
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        var dropProposal = UITableViewDropProposal(operation: .cancel)
        
        // 아이템 개수가 1개가 아니면 cancel 반환 ( 한개의 드래그 아이템만들 관리)
        guard session.items.count == 1 else { return dropProposal }
        
        // 현재 앱의 테이블뷰에서 활성화된 드래그가 있다면
        //.move drag operation is available
        if tableView.hasActiveDrag {
            dropProposal = UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return dropProposal
    }
    
    
    ///performDropWith : 드롭을 완료했을 떄 ( 사용자가 손을 뗐을 때)
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        
        guard let sourceItem = coordinator.items.first else{return}
        guard let sourceIndexPath = sourceItem.sourceIndexPath else { return }
        guard coordinator.proposal.operation == .move  else {return }
        tableView.performBatchUpdates {
            let sourceItem = selectedSongList[sourceIndexPath.row]
            
            selectedSongList.remove(at: sourceIndexPath.row)
            tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
            
            selectedSongList.insert(sourceItem, at: destinationIndexPath.row)
            tableView.insertRows(at: [destinationIndexPath], with: .automatic)
        } completion: { finish in
            print("finish : ", finish)
            coordinator.drop(sourceItem.dragItem, toRowAt: destinationIndexPath)
            tableView.reloadData()
        }
    }
}
