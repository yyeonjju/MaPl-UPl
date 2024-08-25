//
//  PlaylistCollectionViewCell.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/25/24.
//

import UIKit
import SnapKit
import RxSwift

func randomColor() -> UIColor {
    let red = CGFloat.random(in: 0...1)
    let green = CGFloat.random(in: 0...1)
    let blue = CGFloat.random(in: 0...1)
    let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    return color
}






final class PlaylistCollectionViewCell : UICollectionViewCell {
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    // MARK: - UI
    let bgView  = {
        let view = UIView()
        view.backgroundColor = randomColor()
        return view
    }()
    
    // MARK: - Initializer
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        
        configureSubView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - ConfigureUI
    
    private func configureSubView() {
        [bgView]
            .forEach{
                contentView.addSubview($0)
            }
    }
    
    private func configureLayout() {
        bgView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }

}



