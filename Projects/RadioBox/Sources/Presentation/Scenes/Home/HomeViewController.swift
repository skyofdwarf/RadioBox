//
//  HomeViewController.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import Stevia
import RxSwift
import RxRelay
import RxCocoa
import RadioBrowser

class HomeViewController: UIViewController {
    let indicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    var cv: UICollectionView!
    
    let playerBar = PlayerBar()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, RadioStation>!
    
    var vm: HomeViewModel!
    var dbag = DisposeBag()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        title = "RadioBox"
        
        tabBarItem = UITabBarItem(title: "Home",
                                  image: UIImage(systemName: "dot.radiowaves.left.and.right"),
                                  tag: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configureSubviews()        
        bindViewModel()
        bindPlayer()
        
        vm.send(action: .ready)
    }
    
    func configureSubviews() {
        indicatorView.color = .red
        indicatorView.hidesWhenStopped = true
        
        cv = UICollectionView(frame: view.bounds, collectionViewLayout: Self.createCollectionViewLayout())
        cv.delegate = self
        
        dataSource = createDataSource()
        
        layoutSubviews()
    }
    
    func layoutSubviews() {
        view.subviews (
            cv,
            indicatorView,
            playerBar
        )
        
        view.layout {
        }
        
        cv.fillContainer()
        indicatorView.centerInContainer()
        
        playerBar.fillHorizontally()
        playerBar.Top == view.safeAreaLayoutGuide.Bottom
        
        additionalSafeAreaInsets = UIEdgeInsets(top: 0,
                                                left: 0,
                                                bottom: playerBar.intrinsicContentSize.height,
                                                right: 0)
    }
    
    func bindViewModel() {
        vm.state.$fetching
            .drive(indicatorView.rx.isAnimating)
            .disposed(by: dbag)
        
        vm.state.$stations
            .asObservable()
            .withUnretained(self)
            .bind(onNext: { vc, stations in
                vc.applyDataSource(stations: stations)
            })
            .disposed(by: dbag)
    }
    
    func bindPlayer() {
        playerBar.bind(player: vm.player)
    }
}

// MARK: CollectioNView

extension HomeViewController {
    enum Section: Int, CaseIterable {
        case mostVoted
        
        var title: String {
            switch self {
            case .mostVoted: return "Most voted"
            }
        }
               
        enum Item {
            case station(RadioStation)
        }
    }
    
    func createDataSource() -> UICollectionViewDiffableDataSource<Section, RadioStation> {
        let stationCellRegistration = UICollectionView.CellRegistration<StationCell, RadioStation>
        { (cell, indexPath, station) in
            cell.configure(station: station)
        }
        
        return UICollectionViewDiffableDataSource(collectionView: cv)
        { (collectionView, indexPath, identifier) in
            guard let section = Section(rawValue: indexPath.section) else { return nil }
            
            switch section {
            case .mostVoted:
                return collectionView.dequeueConfiguredReusableCell(using: stationCellRegistration, for: indexPath, item: identifier)
            }
        }.then {
            let headerRegistration = UICollectionView.SupplementaryRegistration<StationSectionHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) {
                (view, kind, indexPath) in
                
                guard let section = Section(rawValue: indexPath.section) else { return }
                
                view.configure(title: section.title)
            }
            
            $0.supplementaryViewProvider = { (cv, kind, indexPath) in
                return cv.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            }
        }
    }
    
    func applyDataSource(stations: [RadioStation]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, RadioStation>()
        
        snapshot.appendSections(Section.allCases)
        
        snapshot.appendItems(stations, toSection: .mostVoted)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - CollectionView layouts

extension HomeViewController {
    static func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, environment in
            switch Section(rawValue: section) {
            case .mostVoted:
                return verticalStationList()
            default:
                fatalError("No definition for section \(section)")
            }
        }
    }
    
    
    static func horizontalStationList() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4),
                                               heightDimension: .fractionalWidth(0.4*1.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        return NSCollectionLayoutSection(group: group).then {
            $0.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            $0.interGroupSpacing = 10
            $0.orthogonalScrollingBehavior = .continuous
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(40))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                            elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            $0.boundarySupplementaryItems = [sectionHeader]
        }
    }
    
    static func verticalStationList() -> NSCollectionLayoutSection {
        let sectionInset = 10.0
        let itemSpacing = 5.0
        let itemCountInLIne = 3.0
        let contentWidth = UIScreen.main.bounds.width - (sectionInset * 2)
        let itemWidth = ceil((contentWidth - (itemSpacing * (itemCountInLIne - 1))) / itemCountInLIne)
        let itemHeight = itemWidth + 40
                
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth),
                                              heightDimension: .absolute(itemHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(itemHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        group.interItemSpacing = .flexible(itemSpacing)
        
        return NSCollectionLayoutSection(group: group).then {
            $0.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: sectionInset, bottom: 0, trailing: sectionInset)
            $0.interGroupSpacing = 6
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(40))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                            elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            $0.boundarySupplementaryItems = [sectionHeader]
        }
    }
}

// MARK: - CollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let station = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        vm.player.play(station: station)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let numberOfItems = dataSource.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        let isLastItem = indexPath.row == numberOfItems - 1
        
        if isLastItem {
            vm.send(action: .tryFetchNextPage)
        }
    }
}
