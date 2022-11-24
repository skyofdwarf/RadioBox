//
//  SearchViewController.swift
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

class SearchViewController: UIViewController {
    let label = UILabel()
    let indicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    
    var cv: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, RadioStation>!
    
    let searchBar = UISearchBar()
    let queryRelay = PublishRelay<String?>()
    
    let playerBar = PlayerBar()
    
    var vm: SearchViewModel!
    var dbag = DisposeBag()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        tabBarItem = UITabBarItem(title: "Search",
                                  image: UIImage(systemName: "magnifyingglass.circle"),
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
        
//        vm.send(action: .lookup)
    }
    
    func configureSubviews() {
        label.text = "Search stations by name"
        label.textAlignment = .center
        indicatorView.color = .red
        indicatorView.hidesWhenStopped = true
        
        cv = UICollectionView(frame: view.bounds, collectionViewLayout: Self.createCollectionViewLayout())
        cv.delegate = self
        cv.backgroundColor = .systemBackground
        
        dataSource = createDataSource()
        
        searchBar.placeholder = "Search stations by name"
        searchBar.delegate = self
        
        navigationItem.titleView = searchBar
        
        layoutSubviews()
    }
    
    func layoutSubviews() {
        view.subviews {
            cv!
            label
            indicatorView
            playerBar
        }
        
        view.layout {
            |-indicatorView-|
            |-label-|
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
        // input
        queryRelay
            .compactMap { $0 }
            .map { SearchAction.search($0) }
            .bind(to: vm.action)
            .disposed(by: dbag)
        
        // output
        vm.state.$fetching
            .drive(indicatorView.rx.isAnimating)
            .disposed(by: dbag)
        
        vm.state.$stations
            .map { !$0.isEmpty }
            .drive(label.rx.isHidden)
            .disposed(by: dbag)
    }
        
    func bindPlayer() {
        playerBar.bind(player: vm.player)
        
        vm.state.$stations
            .drive(with: self) { this, stations in
                this.applyDataSource(stations: stations)
            }
            .disposed(by: dbag)
        
        vm.event
            .emit(with: self) { this, _ in
                this.scrollToTop()
            }
            .disposed(by: dbag)
    }
    
    func scrollToTop() {
        cv.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}

// MARK: CollectioNView

extension SearchViewController {
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

extension SearchViewController {
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
        }
    }
}

// MARK: - CollectionViewDelegate

extension SearchViewController: UICollectionViewDelegate {
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
            vm.send(action: .trySearchNextPage)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let station = dataSource.itemIdentifier(for: indexPath),
              let coordinator = vm.coordinator as? SearchCoordinator
        else {
            return nil
        }
        
        return coordinator.contextMenu(for: station)
    }
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let vc = animator.previewViewController else {
            return
        }
        
        animator.addCompletion { [weak self] in
            guard let coordinator = self?.vm.coordinator as? SearchCoordinator else { return }
            coordinator.coordinate(.pop(vc))
        }
    }
}

// MARK: UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        let query = searchBar.text
        self.queryRelay.accept(query)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
