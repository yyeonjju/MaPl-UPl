//
//  NetworkManager.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import Foundation
import Alamofire
import RxSwift
import UIKit

class NetworkManager {
    @UserDefaultsWrapper(key : .userInfo) var userInfo : LoginResponse?
    
    static let shared = NetworkManager()
    private init() { }
    
    
    private func fetch<M : Decodable>(fetchRouter : Router, model : M.Type) -> Single<Result<M,Error>> {
        
        let single = Single<Result<M,Error>>.create { single in
            do {
                let request = try fetchRouter.asURLRequest()
                print("💚 url", request.url)
                print("💚 header", request.headers)
                print("💚request💚", request)
                print("💚httpBody💚", request.httpBody)
                
                
                AF.request(request, interceptor: APIRequestInterceptor())
                .responseDecodable(of: model.self) { response in
//                    print("💚statusCode", response.response?.statusCode)
                    
                    //response.error 로 에러를 판별하면 거기에서 캐치되어 밑으로 진행되지 않아서
                    //statusCode가 nil값인걸로 request 에러 걸러주기
                    
                    guard response.response != nil else {
                        return single(.success(.failure(FetchError.invalidResponse)))
                    }
                    
                    
                    guard let statusCode = response.response?.statusCode else {
                        return single(.success(.failure(FetchError.failedRequest)))
                    }
                    
                    guard let data = response.data else {
                        return single(.success(.failure(FetchError.noData)))
                    }
                    

                    
                    if statusCode != 200 {
                        var errorMessage: String?
                        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                            errorMessage = json["message"]
                        }

                        print("errorMessage -> ", errorMessage)
                        return single(.success(.failure(FetchError.failResponse(code: statusCode, message: errorMessage ?? ""))))
                    }
                    
                    
                    
                    switch response.result {
                    case .success(let value):
                        return single(.success(.success(value)))
                        
                    case .failure(let failure):
                        return single(.success(.failure(FetchError.invalidData)))
                    }
                    
                }
            }catch {
                print("asURLRequest -", error)
                return single(.success(.failure(FetchError.urlRequestError))) as! Disposable
            }
            
            return Disposables.create()
        }
        
        return single

        
    }
    
    
    
    func uploadFile<M : Decodable>(fetchRouter : Router, imageData : Data, model : M.Type) -> Single<Result<M,Error>> {
        
        let single = Single<Result<M,Error>>.create { single in
            do {
                let request = try fetchRouter.asURLRequest()
                guard let url = request.url else {
                    return single(.success(.failure(FetchError.urlRequestError))) as! Disposable
                }
                let header : HTTPHeaders? = request.headers
                print("💚 url", url)
                print("💚 header", header)
                print("💚request💚", request)
                
                AF.upload(
                    multipartFormData: { multipartFormData in
                        // mimeType : 폼데이터  중에 어떤 파일로 분기해줄 것인지 정해준다.
                        multipartFormData.append(imageData,withName: "files", fileName: "image.jpeg",mimeType: "image/jpeg")
                    },
                    to: url,
                    headers: header,
                    interceptor: APIRequestInterceptor()
                )
                .validate(statusCode: 200..<300)
                .responseDecodable(of: model.self) { response in
                    print("💚response", response.response)
                    print("💚statusCode", response.response?.statusCode)
                    guard let statusCode = response.response?.statusCode else {
                        return single(.success(.failure(FetchError.failedRequest)))
                    }
                    
                    guard let data = response.data else {
                        return single(.success(.failure(FetchError.noData)))
                    }
                    
                    guard response.response != nil else {
                        return single(.success(.failure(FetchError.invalidResponse)))
                    }
                    
                    
                    if statusCode != 200 {
                        var errorMessage: String?
                        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                            errorMessage = json["message"]
                        }

                        print("errorMessage -> ", errorMessage)
                        return single(.success(.failure(FetchError.failResponse(code: statusCode, message: errorMessage ?? ""))))
                    }
                    
                    
                    
                    switch response.result {
                    case .success(let value):
                        return single(.success(.success(value)))
                        
                    case .failure(let failure):
                        return single(.success(.failure(FetchError.invalidData)))
                    }

                }
                
            } catch {
                return single(.success(.failure(FetchError.urlRequestError))) as! Disposable
                
            }
            return Disposables.create()
        }
        
        return single
    }

}


extension NetworkManager {
    
    func login(email: String, password: String) -> Single<Result<LoginResponse,Error>>  {
        let body = LoginQuery(email: email, password: password)
        let fetchRouter = Router.login(query: body)
        return fetch(fetchRouter: fetchRouter, model : LoginResponse.self)
    }
    
    func postPlaylist(body : PostPlaylistQuery) -> Single<Result<PlaylistResponse,Error>>  {
        let fetchRouter = Router.postPlaylist(query: body)
        return fetch(fetchRouter: fetchRouter, model : PlaylistResponse.self)
    }
    
    func uploadImage(imageData : Data) -> Single<Result<FileModel,Error>> {
        let fetchRouter = Router.updloadImage
        return uploadFile(fetchRouter: fetchRouter, imageData: imageData, model : FileModel.self)
    }
    
    func tokenRefresh() -> Single<Result<TokenRefreshResponse,Error>> {
        let fetchRouter = Router.tokenRefresh
        return fetch(fetchRouter: fetchRouter, model : TokenRefreshResponse.self)
    }
    
    func getPlaylistPosts(productId : String, nextCursor : String) -> Single<Result<PlaylistPostsResponse,Error>> {
        let fetchRouter = Router.getPosts(productId: productId, nextCursor : nextCursor)
        return fetch(fetchRouter: fetchRouter, model : PlaylistPostsResponse.self)
    }
    
    func likePost(body: LikeModel,postId : String) -> Single<Result<LikeModel,Error>> {
        let fetchRouter = Router.likePost(query: body, postId: postId)
        return fetch(fetchRouter: fetchRouter, model : LikeModel.self)
    }
    
    func getPlaylistInfo(id : String) -> Single<Result<PlaylistResponse,Error>> {
        let fetchRouter = Router.getPlaylistInfo(id: id)
        return fetch(fetchRouter: fetchRouter, model : PlaylistResponse.self)
    }
    
    func validatePayment(query : PaymentValidationQuery) -> Single<Result<PaymentValidationResponse,Error>> {
        let fetchRouter = Router.validatePayment(query: query)
        return fetch(fetchRouter: fetchRouter, model : PaymentValidationResponse.self)
    }
    
    func getLikes(nextCursor : String) -> Single<Result<PlaylistPostsResponse,Error>> {
        let fetchRouter = Router.getLikes(nextCursor : nextCursor)
        return fetch(fetchRouter: fetchRouter, model : PlaylistPostsResponse.self)
    }
    
    func getPayments() -> Single<Result<PlaylistPaymentsResponse,Error>> {
        let fetchRouter = Router.getPayments
        return fetch(fetchRouter: fetchRouter, model : PlaylistPaymentsResponse.self)
    }
}


//토큰 리프레시 로직
final class APIRequestInterceptor: RequestInterceptor {
    @UserDefaultsWrapper(key : .userInfo) var userInfo : LoginResponse?
    let disposeBag = DisposeBag()
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        //TODO: 로그인 url 아닐 때만 setValu하기
        
        urlRequest.setValue((userInfo?.access ?? ""), forHTTPHeaderField: HeaderKey.authorization)
        
        print("adapt", urlRequest.headers)
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        print("💜💜💜retry")

        guard let response = request.task?.response as? HTTPURLResponse, request.retryCount <  4 else{
            completion(.doNotRetryWithError(error))
            return
        }
        
        if response.statusCode == 419 { // 419일 때
            print("💜💜💜retry -> 419이다!!")
            
            NetworkManager.shared.tokenRefresh()
                .subscribe(with: self, onSuccess: { owner, result in
                    switch result{
                    case .success(let value) :
                        owner.userInfo?.access = value.accessToken
                        completion(.retry)
                    case .failure(let error as FetchError) :
                        //엑세스 토큰 갱신 요청에서의 실패 result (418 리프레시 만료 시 에러날 수 있다)
                        completion(.doNotRetryWithError(error))
                    default:
                        print("default")
                        
                    }
                })
                .disposed(by: disposeBag)

        } else if response.statusCode == 418 { //418 일 떄
            print("💜💜💜retry -> 418이다!")
            
            ///로그인 화면으로  루트뷰 변경
            DispatchQueue.main.async {
                let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                sceneDelegate?.changeRootViewController(to: LoginViewController())
                completion(.doNotRetryWithError(error))
            }
        } else {
            print("💜💜💜 418❌ 419❌")
            completion(.doNotRetryWithError(error))
        }

    }
}
