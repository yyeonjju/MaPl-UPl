//
//  UserDefaultsWrapper.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import Foundation

enum UserDefaultsKey : String {
    case userInfo
}

@propertyWrapper
struct UserDefaultsWrapper<T : Codable> {
    let key : UserDefaultsKey
    
    var wrappedValue: T? {
        get {
            
            guard let data = UserDefaults.standard.object(forKey: key.rawValue) as? Data else {return nil}
            let decoder = JSONDecoder()
            let decodedObject = try? decoder.decode(T.self, from: data)
            guard let decodedObject else {return nil}
            return decodedObject
        }
        set {
            let encoder = JSONEncoder()
            if let encodedStruct = try? encoder.encode(newValue) {
                UserDefaults.standard.setValue(encodedStruct, forKey: key.rawValue)
            }
        }

    }
}
