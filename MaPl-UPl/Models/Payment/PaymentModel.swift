//
//  PaymentModel.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/30/24.
//

import Foundation

struct PaymentValidationQuery : Encodable {
    let imp_uid : String
    let post_id : String
}

struct PaymentValidationResponse : Decodable {
    let buyerId, postId, merchantUid, productName: String

    enum CodingKeys: String, CodingKey {
        case buyerId = "buyer_id"
        case postId = "post_id"
        case merchantUid = "merchant_uid"
        case productName
    }
}
