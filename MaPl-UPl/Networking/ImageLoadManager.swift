//
//  ImageLoadManager.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/25/24.
//

import UIKit
import Alamofire

extension UIImageView {
    func loadImage(filePath : String) {
        ImageLoadManager.shared.downloadImage(filePath: filePath) { data in
            self.image = UIImage(data: data)
        }
    }
}

class ImageLoadManager {
    static let shared = ImageLoadManager()
    private init() {}

    func downloadImage(filePath: String, completion: @escaping (_ data : Data) -> Void ) {
        let fetchRouter = Router.getImageData(filePath: filePath)
        do{
            let request = try fetchRouter.asURLRequest()
            AF.request(request, interceptor: APIRequestInterceptor())
                .responseData(completionHandler: { response in
                    guard let data = response.data else {return }
                    completion(data)
                })
            
        }catch {
            print("downloadImage error")
        }

    }
    
}
