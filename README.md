# Mapl-Upl | 플레이리스트 공유 앱


![image.jpg1](https://github.com/user-attachments/assets/e3afc871-3e0d-44a3-a784-3cafcefcfe80) |![image.jpg2](https://github.com/user-attachments/assets/8e276768-060b-4176-b6da-b49c53a737f7) |![image.jpg3](https://github.com/user-attachments/assets/afd53b43-1592-4bfd-9d7c-fe4b6d464012) |![image.jpg4](https://github.com/user-attachments/assets/9e612acb-7709-438a-92c7-1aaaf8c07f5d)
--- | --- | --- | --- | 


<br/><br/>

## 🪗 Mapl-Upl 

- 앱 소개 : 나만의 플레이리스트를 공유하고 타인의 플레이리스트를 구매하여 음악을 들을 수 있는 플랫폼
- 개발 인원 : 1인
- 개발 기간 : 8/17 - 8/31 ( 15 일 )
- 최소 버전 : 17.0


<br/><br/>

## 📎 기술 스택
- Music : MusicKit, AVFoundation
- UI : UIKit, FSPagerView, Kingfisher, SnapKit, Toast
- Reactive : RxSwift, RxDataSource
- Network & Etc. : Alamofire, PG(PortOne SDK)
- Architecture : MVVM


<br/><br/>



## 📝 핵심 기능
- 인증 | 회원가입 / 로그인 / 엑세스토큰 리프레시
- 특정 음악 검색 / 원하는 음악 선택해 플레이리스트를 만들어 공유
- 타인의 플레이리스트를 결제 / 좋아요
- 결제한 플레이리스트의 음악 재생 (플레이리스트 내 음악 자동 반복 재생)


<br/><br/>


## ✅ 핵심 기술 구현 사항

- TargetType 프로토콜을 정의하여 네트워킹 URL 생성에 필요한 요구사항 추상화
- Request Router 클래스를 통해서 API 요청 로직을 일관적으로 관리/생성할 수 있도록 Router Pattern  적용
- 엑세스 토큰 만료 시, 에러를 캐치하고 네트워킹을 재요청할 수 있도록 RequestInterceptor 프로토콜의 adapt, retry 메서드 정의
- 네트워킹 시점에 발생할 수 있는 에러들에 대한 예외 처리를 할 수 있도록 커스텀 에러 정의
- 이벤트 스트림의 시점과 이벤트를 처리하고 이벤트에 대한 결과를 반환하는 시점을 명시적으로 구분하기 위해  ViewModel class 내부에 Input/Output 구조체를 정의하여 MVVM 패턴으로 구현
- 음원 재생이 완료된 후 다음 음원을 자동적으로 재생시키기 위해 Notification Center를 통해 음원 재생 완료 시점 감지
- 유저 정보에 대한 값을 가공하여 저장하고 조회하는 로직에 대한 보일러 플레이트를 줄이기 위해 커스텀 PropertyWrapper 생성


<br/><br/>



## 💎 주요 구현 내용
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


### 2. AVPlayer + Notification Center 기능을 결합해 preview 음원 재생
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
<p> - 419 에러 ( 엑세스 토큰 만료) 시, 엑세스 토큰을 갱신하도록 서버에 요청하고 새로 받은 엑세스 토큰으로 원래 하려고 했던 request를 retry </p>
<p> - 418 에러 ( 리프레시 토큰 만료) 시, 로그인 뷰로 전환 </p> 

<image width="500" src="https://github.com/user-attachments/assets/ec773d57-fee7-41f7-b0c4-4dc1dd10aa32" />
  
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


### 4. RxSwift 와 input/output 패턴 기반의 MVVM 패턴 구현
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




## 🔥 트러블 슈팅


<br/>

### 1️. RxSwift의 .bind(with:onNext:)사용 시, 메모리 누수 해결


#### 📍 이슈 : 뷰컨트롤러 pop 이후에도 객체가 deinit되지 않는 문제
#### 📍 문제 코드
```swift
output.presentPhotoLibrary
    .bind(with: self) { owner, _ in
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .any(of: [.images])
    
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        
        owner.pageTransition(to: picker, type: .present)
    }
    .disposed(by: disposeBag)
```
#### 📍 문제 원인
onNext 클로저 내부에서 `self`를 사용해주었기 때문에 발생한 메모리 누수.

.bind(with:onNext:)에서 with 파라미터의 인자로는 `“참조가 retain되지 않도록 하고 싶은 객체”`를 넣어주어야하고, onNext 클로저에서 위 코드에서 지정해 준 owner 같은 파라미터 이름으로 사용해 주어야 비로소 객체를 retain하지 않으며 사용할 수 있다. 해당 문제가 발생한 코드에서는 owner와 함께 self 또한 사용해주고 있었기 때문에 메모리 릭이 발생했다. 

#### 📍 해결 코드 및 인사이트
사소한 문제였지만, 클로저 내부에서 owner로 사용되도록 강제된 것도, self를 썼다고 컴파일 에러를 띄워주는 것도 아니기 때문에 .bind(with:onNext:)를 사용할 때는 이런 부분도 잘 고려해야갰다.

```swift
output.presentPhotoLibrary
    .bind(with: self) { owner, _ in
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .any(of: [.images])
    
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = owner
        
        owner.pageTransition(to: picker, type: .present)
    }
    .disposed(by: disposeBag)
```



<br/><br/><br/>

### 2️. 중첩 클로저에서의 객체 참조 중 발생한 메모리 누수

#### 📍 이슈 : 중첩 클로저의 내부 클로저에서 `[weak self]`를 썼을 때 메모리 누수가 생김
#### 📍 문제 코드
``` swift
output.pushToSearchMusicVC
    .bind(with: self) { owner, _ in
        let vc = SearchMusicViewController()
        vc.addSongs = { [weak self]songs in
            owner.vm.selectedSongList.append(contentsOf: songs)
        }
        self?.pageTransition(to: vc, type: .push)
    }
    .disposed(by: disposeBag)


```

#### 📍 문제 원인
외부 클로저에서 객체를 어떻게 참조하고 있는지 고려하지 않고 내부 클로저에 [weak self]로 객체를 참조하고 있음.

코드 상으로만 보면, 외부 클로저에서도 .bind(with:onNext:)로 객체의 강한 참조를 “방지”해주었고, 내부클로저에서도  [weak self]를 써주었기 때문에 메모리 누수가 일어나지 않을 것이라고 생각할 수 있지만, 중첩된 클로저의 경우에는 외부 클로저에서 객체를 어떻게 잡아주고 있는지가 내부클로저에도 영향을 끼치기 때문에 위에서 봤던 코드는 아래 코드와 동일하다고 볼 수 있다.

즉, 외부 클로저에서 [weak self]를 쓰지 않고 내부 클로저에서 [weak self]를 쓰는 순간 외부 클로저에서 강하게 self를 캡처하게되기 때문에 메모리릭이 발생한 것.
```swift
output.pushToSearchMusicVC
    .bind(with: self) { [self] owner, _ in
        let vc = SearchMusicViewController()
        vc.addSongs = { [weak self]songs in
            self?.vm.selectedSongList.append(contentsOf: songs)
        }
        owner.pageTransition(to: vc, type: .push)
    }
    .disposed(by: disposeBag)
```


#### 📍 해결 코드 및 인사이트
중첩클로저를 다룰 때는 '외부 클로저에서 객체를 어떻게 잡아주고 있는지가 내부클로저에도 영향을 끼친다'는 것을 유의하며 코드를 구성해야한다.

```swift

output.pushToSearchMusicVC
    .bind(with: self) { owner, _ in
        let vc = SearchMusicViewController()
        vc.addSongs = { songs in
            owner.vm.selectedSongList.append(contentsOf: songs)
        }
        owner.pageTransition(to: vc, type: .push)
    }
    .disposed(by: disposeBag)

```




<br/><br/><br/>




### 3️. 네트워킹 에러 분기 처리

 
#### 📍 이슈 : 네트워킹이 정상적으로 완료되지 않았으 때 사용자에게 토스트 메세지로 보여줄 에러 처리에 대한 고민
#### 📍 해결 코드 및 인사이트


<details>
  <summary>1. Error프로토콜을 채택한 FetchError열거형을 생성하여 네트워킹 시에 일어날 수 있는 에러 정의</summary>

``` swift
//FetchError.swift

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
  <summary>2. 재사용가능한 네트워킹 요청 제네릭 함수 생성 하여 response 받고 데이터 디코딩 하는 과정에서 발생할 수 있는 에러에 대해 분기처리</summary>

 ``` swift

// NetworkManager.swift

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


<details>
  <summary>3. 네트워킹 결과를 리턴받아 사용하는 곳에서 FetchError 열거형에서 정의해준 errorMessage 연산 프로퍼티의 문자열을 토스트로 띄워줌</summary>
	
```swift
validatePayment
    .flatMap{ query in
        NetworkManager.shared.validatePayment(query: query)
    }
    .asDriver(onErrorJustReturn: .failure(FetchError.fetchEmitError))
    .drive(with: self) { owner, result in
        switch result {
        case .success(let value) :
            owner.configureCompleteUI()
        case .failure(let error as FetchError) :
            owner.view.makeToast(error.errorMessage) //⭐️
        default:
            print("default")
        }
    }
    .disposed(by: disposeBag)

```
</details>
 









