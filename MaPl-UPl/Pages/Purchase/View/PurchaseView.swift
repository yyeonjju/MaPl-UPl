//
//  PurchaseView.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/29/24.
//

import UIKit
import SnapKit

final class PurchaseSectionView : UIView {
    // MARK: - UI
    private let text = {
        let label = UILabel()
        label.text = "플레이리스트 이름"
        label.font = Font.bold18
        label.textColor = Assets.Colors.gray3
        return label
    }()
    let inputLabel = {
        let label = UILabel()
        label.font = Font.bold14
        label.textColor = Assets.Colors.gray2
        label.text = "productName"
        return label
    }()
    private let underline = {
       let view = UIView()
        view.backgroundColor = Assets.Colors.pointPink
        return view
    }()
    
    // MARK: - Initializer
    
    init(sectionName : String, input : String) {
        super.init(frame: .zero)
        
        text.text = sectionName
        inputLabel.text = input
        
        configureSubView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - ConfigureUI
    
    private func configureSubView() {
        [text, inputLabel, underline]
            .forEach{
                addSubview($0)
            }
    }
    
    private func configureLayout() {
        text.snp.makeConstraints { make in
            make.top.leading.equalTo(self).inset(10)
            make.height.equalTo(24)
        }
        
        inputLabel.snp.makeConstraints { make in
            make.top.equalTo(text.snp.bottom).offset(8)
            make.leading.equalTo(self).inset(10)
            make.height.equalTo(24)
        }
        
        underline.snp.makeConstraints { make in
            make.top.equalTo(inputLabel.snp.bottom).offset(2)
            make.leading.equalTo(self).inset(10)
            make.height.equalTo(2)
            make.width.equalTo(250)
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(80)
        }
        
    }

}






final class PurchaseView : BaseView {
    
    // MARK: - UI
    let section1 = PurchaseSectionView(sectionName: "프로덕트 이름", input: "랄랄라 플레이리스트")
    let section2 = PurchaseSectionView(sectionName: "에디터 이름", input: "하연주")
    let section3 = PurchaseSectionView(sectionName: "가격", input: "0")
    
    let buyButton = MainNormalButton(title: "구매하기", bgColor: Assets.Colors.gray2)
    

    // MARK: - Initializer
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Assets.Colors.gray4
        configureSubView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - ConfigureUI
    
    override func configureSubView() {
        [section1, section2, section3, buyButton]
            .forEach{
                addSubview($0)
            }
    }
    
    override func configureLayout() {
        //프로덕트 이름
        section1.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        //에디터 이름
        section2.snp.makeConstraints { make in
            make.top.equalTo(section1.snp.bottom).offset(12)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        //가격
        section3.snp.makeConstraints { make in
            make.top.equalTo(section2.snp.bottom).offset(12)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        
        buyButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
    }

}
