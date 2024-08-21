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
    
    let searchMusicButton = OvalShapeButton(title: "추가할 노래 찾기", image: Assets.SystemImage.plus, imageTintColor: Assets.Colors.pointPink)
    
    let postPlaylistButton = MainNormalButton(title: "내 플리 등록하기")
    
    let selectedMusicTableView = {
        let tv = UITableView()
        tv.rowHeight = 70
        return tv
    }()
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cameraIconView.layer.cornerRadius = cameraIconView.frame.width/2
    }

    
    
    // MARK: - ConfigureUI
    
    override func configureSubView() {
        [postPlaylistButton, titleTextField, photoImageView, cameraIconView, searchMusicButton, selectedMusicTableView]
            .forEach{
                addSubview($0)
            }
        [cameraIconButton]
            .forEach {
                cameraIconView.addSubview($0)
            }
    }
    
    override func configureLayout() {

        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(10)
            make.height.equalTo(40)
        }
        
        photoImageView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.leading.equalTo(safeAreaLayoutGuide).inset(10)
//            make.centerX.equalTo(safeAreaLayoutGuide)
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
            make.leading.equalTo(safeAreaLayoutGuide).offset(10)
            make.height.equalTo(40)
            
        }
        
        selectedMusicTableView.backgroundColor = .gray3
        selectedMusicTableView.snp.makeConstraints { make in
            make.top.equalTo(searchMusicButton.snp.bottom).offset(10)
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(postPlaylistButton.snp.top)
        }
        
        postPlaylistButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
    }

}
