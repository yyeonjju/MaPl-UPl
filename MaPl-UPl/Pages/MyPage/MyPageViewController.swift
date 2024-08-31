//
//  MyPageViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/31/24.
//

import UIKit
import SnapKit
import RxSwift
import RxDataSources

struct MyPageMenu {
    enum MenuTitle : String {
        case likeItem = "좋아요한 플리"
        case buyItem = "구매한 플리"
        case editProfile = "프로필 수정"
    }
    let title : MenuTitle
    let icon : UIImage?
}

struct MyPageSection {
    let header: String
    var items: [Item]
}

extension MyPageSection: SectionModelType {
    typealias Item = MyPageMenu
    
    init(original: MyPageSection, items: [Item]) {
        self = original
        self.items = items
    }
}

final class MyPageViewController : UIViewController {
    // MARK: - UI
    private let tableView = UITableView()
    
    // MARK: - Properties
    //    let sections = MyPageSection.allCases
    private let disposeBag = DisposeBag()
    private let sections = [
        MyPageSection(header: "보관함", items: [MyPageMenu(title: .likeItem, icon: Assets.SystemImage.likeFill),MyPageMenu(title: .buyItem, icon: Assets.SystemImage.banknoteFill)]),
        MyPageSection(header: "설정", items: [MyPageMenu(title: .editProfile, icon: nil)])
    ]
    private var dataSource : RxTableViewSectionedReloadDataSource<MyPageSection>?
    
    // MARK: - Initializer
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setupDataSource()
        cofigureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.configureBackgroundColor()
        setupBind()
    }
    
    private func setupDataSource() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
        dataSource = RxTableViewSectionedReloadDataSource<MyPageSection>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description(), for: indexPath)
                cell.textLabel?.text = item.title.rawValue
                cell.accessoryType = .disclosureIndicator
              return cell
          })
        dataSource?.titleForHeaderInSection = { dataSource, index in
          return dataSource.sectionModels[index].header
        }
    }
    
    private func setupBind() {
        guard let dataSource else{return}
        
        Observable.just(sections)
          .bind(to: tableView.rx.items(dataSource: dataSource))
          .disposed(by: disposeBag)
        
        Observable.zip(
            tableView.rx.itemSelected,
            tableView.rx.modelSelected(MyPageMenu.self)
        )
        .bind(with: self) { (owner, selectedItem : (IndexPath, MyPageMenu)) in
            let item = selectedItem.1
            
            switch item.title {
            case .likeItem:
                owner.pageTransition(to: LikeItemListViewController(), type: .push)
            case .buyItem:
                owner.pageTransition(to: BuyItemListViewController(), type: .push)
            case .editProfile:
                print("editProfile")
            }
        }
        .disposed(by: disposeBag)
    }
    
    
    
    // MARK: - ConfiureUI
    private func cofigureUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

}
