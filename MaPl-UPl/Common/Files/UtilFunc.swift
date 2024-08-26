//
//  UtilFunc.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/23/24.
//

import UIKit

func stringToDecodedModel<T : Decodable>(string : String, model : T.Type) -> T? {
    let songInfoData = string.data(using: .utf8)!
    let decodedSongData = try? JSONDecoder().decode(T.self, from: songInfoData)
    return decodedSongData
}


func configureCollectionVewLayout (scrollDirection :  UICollectionView.ScrollDirection = .vertical, numberofItemInrow : Int, cellIneterSpacing : CGFloat = 10, sectionSpacing :  CGFloat = 30, height: CGFloat? = nil) -> UICollectionViewLayout{
    let layout = UICollectionViewFlowLayout()
    let numberofItemInrow : CGFloat = CGFloat(numberofItemInrow)
    
    let cellIneterSpacing : CGFloat = cellIneterSpacing
    let sectionSpacing : CGFloat = sectionSpacing
    let inset = UIEdgeInsets(top: sectionSpacing, left: sectionSpacing, bottom: sectionSpacing, right: sectionSpacing)
    let availableWidth = UIScreen.main.bounds.width - (cellIneterSpacing*numberofItemInrow) - inset.left - inset.right
    
    
    layout.itemSize = CGSize(width: availableWidth/numberofItemInrow, height: height ?? availableWidth/numberofItemInrow)
    layout.scrollDirection = scrollDirection
    layout.minimumLineSpacing = 10
    layout.minimumInteritemSpacing = cellIneterSpacing
    layout.sectionInset = inset
    
    return layout
}
