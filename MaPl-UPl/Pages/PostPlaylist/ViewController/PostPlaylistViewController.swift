//
//  PostPlaylistViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import UIKit
import RxSwift
import PhotosUI
import Toast

final class PostPlaylistViewController : BaseViewController<PostPlaylistView, PostPlaylistViewModel> {
    // MARK: - Properties
    var reloadListData : (() -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegate()
        setupBind()
    }
    
    // MARK: - SetupDelegate

    private func setupDelegate() {

        viewManager.selectedMusicTableView.register(SelectedMusicTableViewCell.self, forCellReuseIdentifier: SelectedMusicTableViewCell.description())
        
        viewManager.selectedMusicTableView.dragDelegate = self
        viewManager.selectedMusicTableView.dropDelegate = self
        viewManager.selectedMusicTableView.dragInteractionEnabled = true
        
    }
    
    // MARK: - SetupBind

    private func setupBind() {
        let postPlaylistButtonTap = PublishSubject<Void>()
        let searchMusicButtonTap = PublishSubject<Void>()
        let addPhotoButtonTap = PublishSubject<Void>()
        let titleInputText = PublishSubject<String>()
        let selectedBgImageData = PublishSubject<Data?>()
        let removeItemIndex = PublishSubject<Int>()
        
        let input = PostPlaylistViewModel.Input(titleInputText:titleInputText, postPlaylistButtonTap : postPlaylistButtonTap, selectedBgImageData : selectedBgImageData, searchMusicButtonTap:searchMusicButtonTap, addPhotoButtonTap:addPhotoButtonTap, removeItemIndex:removeItemIndex)
        let output = vm.transform(input: input)
        
        
        viewManager.titleTextField.rx.text.orEmpty
            .bind(to: titleInputText)
            .disposed(by: disposeBag)
        
        viewManager.postPlaylistButton.rx.tap
            .bind(with:self, onNext: { owner, _ in
                let data = owner.viewManager.photoImageView.image?.jpegData(compressionQuality: 0.5)
                selectedBgImageData.onNext(data)
                postPlaylistButtonTap.onNext(())
            })
//            .bind(to:postPlaylistButtonTap)
            .disposed(by: disposeBag)
        
        viewManager.searchMusicButton.rx.tap
            .bind(to: searchMusicButtonTap)
            .disposed(by: disposeBag)
        
        viewManager.cameraIconButton.rx.tap
            .bind(to: addPhotoButtonTap)
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
                owner.reloadListData?()
            }
            .disposed(by: disposeBag)
        
        output.pushToSearchMusicVC
            .bind(with: self) { owner, _ in
                let vc = SearchMusicViewController()
                vc.addSongs = {songs in
                    owner.vm.selectedSongList.append(contentsOf: songs)
                }
                
                owner.pageTransition(to: vc, type: .push)
            }
            .disposed(by: disposeBag)
        
        output.selectedSongList
            .bind(to: viewManager.selectedMusicTableView.rx.items(cellIdentifier: SelectedMusicTableViewCell.description(), cellType: SelectedMusicTableViewCell.self)) { (row, element, cell : SelectedMusicTableViewCell) in
                cell.selectionStyle = .none
                cell.confiureData(data: element)
                cell.removeItem = {
                    removeItemIndex.onNext(row)
                }
                
            }
            .disposed(by: disposeBag)
        
        output.presentPhotoLibrary
            .bind(with: self) { owner, _ in
                var config = PHPickerConfiguration()
                config.selectionLimit = 1
                config.filter = .any(of: [.images])
            
                let picker = PHPickerViewController(configuration: config)
                picker.delegate = self
                
                owner.pageTransition(to: picker, type: .present)
            }
            .disposed(by: disposeBag)
        
        output.invalidMessage
            .bind(with: self) { owner, message in
                owner.view.makeToast(message, position: .top)
            }
            .disposed(by: disposeBag)
    }
    
}


//drag & drop
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
        
        
        guard let item = coordinator.items.first else{return}
        guard let sourceIndexPath = item.sourceIndexPath else { return }
        guard coordinator.proposal.operation == .move  else {return }
        tableView.performBatchUpdates {
            let sourceItem = vm.selectedSongList[sourceIndexPath.row]
            var newSonglist = vm.selectedSongList
            newSonglist.remove(at: sourceIndexPath.row)
            newSonglist.insert(sourceItem, at: destinationIndexPath.row)
            vm.selectedSongList = newSonglist
            
            //주석치니까 버벅거리진 않는데 아래 finish에서 false가 나옴(찝찝..)

//            tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
//            tableView.insertRows(at: [destinationIndexPath], with: .automatic)
            
            //datasource에 있는 moveRowAt 메서드를 여기 써주면 에러 없긴한데..
            // tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)

            
        } completion: { finish in
            print("finish : ", finish)
            coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
//            tableView.reloadData()
        }
    }
}


extension PostPlaylistViewController : PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider // 2
        
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) { // 3
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in // 4
                guard let self, let image else { return }
                
                DispatchQueue.main.async {
                    self.viewManager.photoImageView.image = image as? UIImage
                }
            }
        } else {
            view.makeToast("로드할 수 없는 이미지 입니다", position: .top)
            // provider not being able load UIImage
        }
        
    }
}
