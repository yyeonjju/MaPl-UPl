//
//  PaymentViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/30/24.
//

import UIKit
import WebKit
import SnapKit
import iamport_ios
import RxSwift
import Toast

final class PaymentViewController : UIViewController {
    
    // MARK: - Properties
    var purchaseInfo : PurchaseInfo?
    
    private let disposeBag = DisposeBag()
    private let validatePayment = PublishSubject<PaymentValidationQuery>()
    
    // MARK: - UI

    let wkWebView: WKWebView = {
        var view = WKWebView()
        view.backgroundColor = Assets.Colors.white
        return view
    }()
    let returnToHomeButton = MainNormalButton(title: "홈화면으로 돌아가기", bgColor: Assets.Colors.gray2)
    let completeTextLabel = {
        let label = UILabel()
        label.text = "결제가 완료되었습니다"
        label.font = Font.regular13
        label.textColor = Assets.Colors.black
        return label
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = Assets.Colors.white
        
        configureUI()
        payment()
        setupBind()
    }
    
    private func setupBind() {
        returnToHomeButton.rx.tap
            .bind(with: self) { owner, _ in
                ///루트뷰 변경
                let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                sceneDelegate?.changeRootViewController(to: PlaylistListViewController())
                
            }
            .disposed(by: disposeBag)
        
        validatePayment
            .flatMap{ query in
                NetworkManager.shared.validatePayment(query: query)
            }
            .asDriver(onErrorJustReturn: .failure(FetchError.fetchEmitError))
            .drive(with: self) { owner, result in
                switch result {
                case .success(let value) :
                    print("🌸success🌸",value)
                    owner.configureCompleteUI()
                case .failure(let error as FetchError) :
                    owner.view.makeToast(error.errorMessage)
                default:
                    print("default")
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    
    private func configureUI() {
        view.addSubview(wkWebView)
        
        wkWebView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    private func configureCompleteUI () {
        view.addSubview(completeTextLabel)
        view.addSubview(returnToHomeButton)
        completeTextLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
        returnToHomeButton.snp.makeConstraints { make in
            make.top.equalTo(completeTextLabel.snp.bottom).offset(4)
            make.centerX.equalTo(view)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
    }
    
    private func payment() {
        guard let purchaseInfo else {return}
        
        let payment = IamportPayment(
            pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
            merchant_uid: "ios_\(HeaderKey.sesacKey)_\(Int(Date().timeIntervalSince1970))",
            amount: "\(purchaseInfo.price)").then {
                $0.pay_method = PayMethod.card.rawValue
                $0.name = purchaseInfo.productName
                $0.buyer_name = purchaseInfo.buyerName
                $0.app_scheme = "heidi"
            }
        
        Iamport.shared.paymentWebView(
            webViewMode: wkWebView,
            userCode: PortOne.userCode,
            payment: payment) { [weak self] iamportResponse in
                guard let self, let impUid = iamportResponse?.imp_uid else{return}
                let query = PaymentValidationQuery(imp_uid: impUid, post_id: purchaseInfo.postId)
                print("💎💎query💎💎💎", query)
                
                validatePayment.onNext(query)
            }
    }

}

