# Mapl-Upl | 플레이리스트 공유 앱
![image](https://github.com/user-attachments/assets/9db687a6-b640-439c-9919-20ca78e0a424)


<br/><br/><br/>


## Mapl-Upl

- 앱 소개 : 나만의 플레이리스트를 공유하고 타인의 플레이리스트를 구매하여 음악을 들을 수 있는 플랫폼
- 개발 인원 : 1인
- 개발 기간 : 8/15 - 8/31 ( 17 일 )
- 최소 버전 : 17.0



<br/><br/><br/>

## 기술 스택

- UIKit, RxSwift, RxDataSource, Alamofire, FSPagerView, Kingfisher, snapkit, Toast
- MusicKit, AVFoundation
- PortOne SDK( 구 IamPort)
- SPM, CocoaPods



<br/><br/><br/>



## 핵심 기능
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








