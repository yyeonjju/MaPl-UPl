//
//  NameSpace.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/16/24.
//

import UIKit

enum ProductId {
    static let playlist = "Mapl-Upl-playlist"
}

enum Assets {
    enum Colors {
        static let pointPink = UIColor(named: "pointPink")!
        static let black = UIColor(named: "black")!
        static let gray1 = UIColor(named: "gray1")!
        static let gray2 = UIColor(named: "gray2")!
        static let gray3 = UIColor(named: "gray3")!
        static let gray4 = UIColor(named: "gray4")!
        static let gray5 = UIColor(named: "gray5")!
        static let white = UIColor(named: "white")!
    }
    
    enum SystemImage {
        static let plus = UIImage(systemName: "plus")
        static let line = UIImage(systemName: "minus")
        static let threeLines = UIImage(systemName: "line.3.horizontal")
        static let options = UIImage(systemName: "ellipsis")
        static let xmarkCircle = UIImage(systemName: "xmark.circle")
        static let likeFill = UIImage(systemName: "heart.fill")
        static let likeEmpty = UIImage(systemName: "heart")
        static let banknoteFill = UIImage(systemName: "banknote.fill")
        static let banknoteEmpty = UIImage(systemName: "banknote")
        static let playFill = UIImage(systemName: "play.fill")
        static let pauseFill = UIImage(systemName: "pause.fill")
        static let chevronLeft = UIImage(systemName: "chevron.left")
        static let chevronRight = UIImage(systemName: "chevron.right")
        static let checkmark = UIImage(systemName: "checkmark")
    }
    
    enum Font {
        static let continuous40 = UIFont(name: "Continuous", size: 40)
    }
}

enum Font {
    static let title = UIFont.boldSystemFont(ofSize: 24)
    
    static let regular13 = UIFont.systemFont(ofSize: 13)
    static let regular14 = UIFont.systemFont(ofSize: 14)
    static let regular15 = UIFont.systemFont(ofSize: 15)
    static let regular16 = UIFont.systemFont(ofSize: 16)
    static let regular17 = UIFont.systemFont(ofSize: 17)
    static let regular18 = UIFont.systemFont(ofSize: 18)
    
    static let bold11 = UIFont.boldSystemFont(ofSize: 11)
    static let bold12 = UIFont.boldSystemFont(ofSize: 12)
    static let bold13 = UIFont.boldSystemFont(ofSize: 13)
    static let bold14 = UIFont.boldSystemFont(ofSize: 14)
    static let bold15 = UIFont.boldSystemFont(ofSize: 15)
    static let bold16 = UIFont.boldSystemFont(ofSize: 16)
    static let bold17 = UIFont.boldSystemFont(ofSize: 17)
    static let bold18 = UIFont.boldSystemFont(ofSize: 18)
}


