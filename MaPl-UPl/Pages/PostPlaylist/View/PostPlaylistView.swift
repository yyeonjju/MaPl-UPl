//
//  PostPlaylistView.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/19/24.
//

import UIKit
import SnapKit

final class PostPlaylistView : BaseView {
    // MARK: - UI
    
    private lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    
    var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    let titleTextField = UnderlinedTextField(placeholder: "제목")
    
    let photoImageView = {
        let iv = UIImageView()
        iv.configureDefaultImageView()
        return iv
    }()
    
    private let cameraIconView : UIView = {
        let view = UIView()
        view.backgroundColor = Assets.Colors.pointPink
        view.layer.borderColor = .none
        return view
    }()
    
    let cameraIconButton : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        btn.tintColor = Assets.Colors.white
        return btn
    }()
    
    let searchMusicButton = CapsuleShapeButton(title: "추가할 노래 찾기", image: Assets.SystemImage.plus, imageTintColor: Assets.Colors.pointPink)
    let selectMusicNotificationLabel = {
        let label = UILabel()
        label.text = "* 1~5개의 노래를 선택해 주세요."
        label.font = Font.bold11
        label.textColor = Assets.Colors.pointPink
        return label
    }()
    
    let postPlaylistButton = MainNormalButton(title: "내 플리 등록하기")
    
    let selectedMusicTableView = {
        let tv =  AutoResizingTableView()
        tv.rowHeight = 80
        tv.isScrollEnabled = false
        return tv
    }()
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cameraIconView.layer.cornerRadius = cameraIconView.frame.width/2
    }

    
    
    // MARK: - ConfigureUI
    
    override func configureSubView() {

        self.addSubview(scrollView)
        self.addSubview(postPlaylistButton)
        scrollView.addSubview(contentView)
        [ titleTextField, photoImageView, cameraIconView, searchMusicButton, selectMusicNotificationLabel, selectedMusicTableView]
            .forEach{
                contentView.addSubview($0)
            }
        [cameraIconButton]
            .forEach {
                cameraIconView.addSubview($0)
            }
    }
    
    override func configureLayout() {

        scrollView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(postPlaylistButton.snp.top)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.centerX.equalTo(scrollView.snp.centerX)
            make.bottom.equalTo(selectedMusicTableView.snp.bottom)
        }
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.leading.trailing.equalTo(contentView).inset(10)
            make.height.equalTo(40)
        }
        
        photoImageView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.leading.equalTo(contentView).inset(10)
            make.size.equalTo(200)
        }
        
        cameraIconView.snp.makeConstraints { make in
            make.size.equalTo(35)
            make.centerX.equalTo(photoImageView.snp.trailing).inset(10)
            make.centerY.equalTo(photoImageView.snp.bottom).inset(10)
        }
        
        cameraIconButton.snp.makeConstraints { make in
            make.size.equalTo(25)
            make.center.equalToSuperview()
        }
        
        searchMusicButton.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(20)
            make.leading.equalTo(contentView).offset(10)
            make.height.equalTo(40)
            
        }
        selectMusicNotificationLabel.snp.makeConstraints { make in
            make.leading.equalTo(searchMusicButton.snp.trailing).offset(2)
            make.bottom.equalTo(searchMusicButton).inset(4)
        }
        selectedMusicTableView.snp.makeConstraints { make in
            make.top.equalTo(searchMusicButton.snp.bottom).offset(10)
            make.leading.trailing.equalTo(contentView)
        }
        
        postPlaylistButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(10)
        }
        
    }

}
