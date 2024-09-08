# Mapl-Upl | 플레이리스트 공유 앱

<p align="center">  
	<img src="https://github.com/user-attachments/assets/e3afc871-3e0d-44a3-a784-3cafcefcfe80" align="center" width="22%">  
	<img src="https://github.com/user-attachments/assets/8e276768-060b-4176-b6da-b49c53a737f7" align="center" width="22%">  
	<img src="https://github.com/user-attachments/assets/afd53b43-1592-4bfd-9d7c-fe4b6d464012" align="center" width="22%">  
	<img src="https://github.com/user-attachments/assets/9e612acb-7709-438a-92c7-1aaaf8c07f5d" align="center" width="22%">  
</p>



<br/><br/><br/>


## 🪗Mapl-Upl

- 앱 소개 : 나만의 플레이리스트를 공유하고 타인의 플레이리스트를 구매하여 음악을 들을 수 있는 플랫폼
- 개발 인원 : 1인
- 개발 기간 : 8/15 - 8/31 ( 17 일 )
- 최소 버전 : 17.0



<br/><br/><br/>

## 📎기술 스택

- UIKit, RxSwift, RxDataSource, Alamofire, FSPagerView, Kingfisher, snapkit, Toast
- MusicKit, AVFoundation
- PortOne SDK( 구 IamPort)
- SPM, CocoaPods



<br/><br/><br/>



## 📝핵심 기능
- 특정 음악 검색
- 원하는 음악으로 플레이리스트를 만들어 공유
- 타인의 플레이리스트를 결제 / 좋아요
- 결제한 플레이리스트의 음악 재생 (플레이리스트 내 음악 자동 반복 재생)


<br/><br/><br/>



## 주요 구현 내용
### 1. MusicKit 프레임워크를 이용해 apple music 음악 데이터 검색

<details>
  <summary>앱이 Apple Music의 데이터에 접근할 수 있도록 권한을 요청 / 권한 확인</summary>
  
  #### 권한 요청/확인 코드
  ```swift
Task {
    let status = await MusicAuthorization.request()
    if status == .authorized {
        print("Apple Music access authorized")
    } else {
        print("Apple Music access denied")
    }
}
  ```
</details>

<details>
  <summary>MusicKit의 MusicCatalogSearchRequest 구조체 활용해서 검색 결과 수집</summary>
  
  #### 노래 검색 코드
  ```swift
Task {
    do {
        var request = MusicCatalogSearchRequest(term: query, types: [Song.self ,Artist.self, Album.self, MusicVideo.self])
        request.limit = 20
        request.offset = 1
        request.includeTopResults = true
        
        let response = try await request.response()
        let songs = response.songs
        
        //...
        
    }catch {
        single(.success(.failure(error)))
    }
}

  ```
</details>


<br/><br/>


### 2. AVPlayer + Notification Center 기능을 결합해 해 preview 음원 재생
<details>
  <summary>음원재생</summary>
  

  ```swift
private let avPlayer = AVPlayer()
private var avPlayerItem : AVPlayerItem?
    
func play() {
	avPlayerItem = AVPlayerItem(url: currentSongpPreviewURL)
	avPlayer.replaceCurrentItem(with: avPlayerItem )
	avPlayer.play()
}

  ```
</details>

<details>
  <summary>NotificationCenter의 AVPlayerItemDidPlayToEndTime를 활용하여 노래 끝난 시점을 감지하고 다음 노래 재생 </summary>
  

  ```swift
NotificationCenter.default
    .addObserver(self,
    selector: #selector(playerDidFinishPlaying),
    name: .AVPlayerItemDidPlayToEndTime,
    object: avPlayer.currentItem)


  ```
</details>


<br/><br/>


### 3. Alamofire 의 interceptor를 사용해서 엑세스 토큰 만료 시 토큰 리프레시 로직 구현
<details>
  <summary>에러코드 419, 418 에서의 로직 구상 </summary>
- 419 에러 ( 엑세스 토큰 만료) 시, 엑세스 토큰을 갱신하도록 서버에 요청하고 새로 받은 엑세스 토큰으로 원래 하려고 했던 request를 retry
- 418 에러 ( 리프레시 토큰 만료) 시, 로그인 뷰로 전환


![image](https://github.com/user-attachments/assets/ec773d57-fee7-41f7-b0c4-4dc1dd10aa32)

  
</details>

<details>
  <summary>interceptor 의 adapt, retry 메서드 사용 코드 </summary>
  

  ```swift
final class APIRequestInterceptor2: RequestInterceptor {
    @UserDefaultsWrapper(key : .userInfo) var userInfo : LoginResponse?
    let disposeBag = DisposeBag()
    
    //💎 adapt : 요청이 시작되기 직전에 dapt가 실행되기 떄문에 여기서 헤더에 엑세스 토큰 값을 넣어준다
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.setValue((userInfo?.access ?? ""), forHTTPHeaderField: HeaderKey.authorization)
        completion(.success(urlRequest))
    }
    
    //💎 retry : 에러를 캐치해서 요청에 대해 retry할 수 있도록 하는 메서드
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {

        guard let response = request.task?.response as? HTTPURLResponse, request.retryCount <  4 else{
            completion(.doNotRetryWithError(error))
            return
        }
        
        if response.statusCode == 419 {
            // 419일 때 : 엑세스 토큰을 갱신하도록 서버에 요청하고 새로 받은 엑세스 토큰으로 원래 하려고 했던 request를 retry
            
            NetworkManager.shared.tokenRefresh()
                .subscribe(with: self, onSuccess: { owner, result in
                    switch result{
                    case .success(let value) :
                        owner.userInfo?.access = value.accessToken //갱신한 엑세스 토큰 다시 저장
                        completion(.retry) // 이전 요청 retry
                    case .failure(let error as FetchError) :
                        //엑세스 토큰 갱신 요청에서의 실패 result (418 리프레시 만료 시 에러날 수 있다)
                        completion(.doNotRetryWithError(error))
                    default:
                        print("default")
                        
                    }
                })
                .disposed(by: disposeBag)

        } else if response.statusCode == 418 {
            // 418 일 떄 : 로그인 화면으로  루트뷰 변경
        } else {
            completion(.doNotRetryWithError(error))
        }

    }
}

  ```
</details>


<br/><br/>


### 4. FetchError 열거형 정의 하여 네트워킹 에러 분기 처리  

<details>
  <summary>FetchError 열거형 </summary>
  

  ```swift
enum FetchError : Error {
    case fetchEmitError // 만에 하나 리턴한 single에서 에러를 방출했을떄 발생하는 에러
    
    case url
    case urlRequestError
    case failedRequest
    case noData
    case invalidResponse
    case failResponse(code : Int, message : String)
    case invalidData
    
    case noUser
    
    var errorMessage : String {
        switch self {
        case .fetchEmitError :
            return "알 수 없는 에러입니다."
        case .url :
            return "잘못된 url입니다"
        case .urlRequestError:
            return "urlRequest 에러"
        case .failedRequest:
            return "요청에 실패했습니다."
        case .noData:
            return "데이터가 없습니다."
        case .invalidResponse:
            return "유효하지 않은 응답입니다."
        case .failResponse(let errorCode, let message):
            return "\(errorCode)error : \(message)"
        case .invalidData:
            return "데이터 파싱 에러"
        case .noUser :
            return "유저가 명확하지 않습니다."
        }
    }
}

  ```
</details>

<details>
  <summary>재사용가능한 네트워킹 요청 제네릭 함수 생성 하여 response 받고 데이터 디코딩 하는 과정의 에러 분기처리 </summary>
  

  ```swift
class NetworkManager {
    @UserDefaultsWrapper(key : .userInfo) var userInfo : LoginResponse?
    
    static let shared = NetworkManager()
    private init() { }
    
    
    private func fetch<M : Decodable>(fetchRouter : Router, model : M.Type) -> Single<Result<M,Error>> {
        
        let single = Single<Result<M,Error>>.create { single in
            do {
                let request = try fetchRouter.asURLRequest()
                
                
                AF.request(request, interceptor: APIRequestInterceptor())
                .responseDecodable(of: model.self) { response in
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
            }catch {
                print("asURLRequest -", error)
                return single(.success(.failure(FetchError.urlRequestError))) as! Disposable
            }
            
            return Disposables.create()
        }
        
        return single

        
    }
}

  ```
</details>



<br/><br/>


### 5. RxSwift 와 input/output 패턴 기반의 MVVM 패턴 구현
<details>
  <summary>BaseViewController, BaseView, BaseViewModelProtocol</summary>
  

  ```swift
protocol BaseViewModelProtocol : AnyObject{
    associatedtype Input
    associatedtype Output
    
    init()
    
    var disposeBag : DisposeBag {get}
    
    func transform(input : Input) -> Output
}
  ```



  ```swift
class BaseView : UIView {
    let spinner = UIActivityIndicatorView()
    
    // MARK: - Initializer
    override init(frame : CGRect) {
        super.init(frame: frame)
        
        configureBackgroundColor()
        configureSpinnerUI()
        
        configureSubView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - ConfigureUI
    private func configureSpinnerUI() {
        self.addSubview(spinner)
        spinner.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
    }
    
    func configureSubView() {
    }
    
    func configureLayout() {
    }
    
}

  ```


  ```swift

class BaseViewController<BV : BaseView, VM : BaseViewModelProtocol> : UIViewController {
    let viewManager = BV.init()
    let vm = VM.init()
    let disposeBag = DisposeBag()
    
    let errorMessage = PublishSubject<String>()
    let isLoading = PublishSubject<Bool>()
    
    override func loadView() {
        view = viewManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBackButtonItem()
        hideKeyboardWhenTappedAround()
        setupBind()
    }
    
    
    // MARK: - ConfigureUI
    private func setupBind() {
        isLoading
            .bind(with: self) { owner, isLoading in
                if isLoading {
                    owner.viewManager.spinner.startAnimating()
                }else {
                    owner.viewManager.spinner.stopAnimating()
                }
            }
            .disposed(by: disposeBag)
        
        errorMessage
            .bind(with: self) { owner, message in
                owner.view.makeToast(message, position: .top)
            }
            .disposed(by: disposeBag)
    }
    
}
  ```

</details>


<br/><br/>






