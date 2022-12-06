//
//  FavoritesViewController.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/12/01.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import Stevia
import RxSwift
import RxRelay
import RxCocoa

class FavoritesViewController: UIViewController {
    let label = UILabel()
    let indicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    
    var cv: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, RadioStation>!
    
    let searchBar = UISearchBar()
    let queryRelay = PublishRelay<String?>()
    
    var vm: FavoritesViewModel!
    var dbag = DisposeBag()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        tabBarItem = UITabBarItem(title: "Favorites",
                                  image: UIImage(systemName: "star.circle"),
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
        
        vm.send(action: .fetch)
    }
    
    func configureSubviews() {
        label.text = "No favorites"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        indicatorView.color = .red
        indicatorView.hidesWhenStopped = true
        
        cv = UICollectionView(frame: view.bounds, collectionViewLayout: Self.createCollectionViewLayout())
        cv.delegate = self
        cv.backgroundColor = .systemBackground
        
        dataSource = createDataSource()
        
        searchBar.placeholder = "Search favorited stations"
        searchBar.delegate = self
        
        navigationItem.titleView = searchBar
        
        layoutSubviews()
    }
    
    func layoutSubviews() {
        view.subviews {
            cv!
            label
            indicatorView
        }
        
        view.layout {
            |-label-|
            6
            |-indicatorView-|
        }
        
        cv.fillContainer()
        label.centerInContainer()
    }
    
    func bindViewModel() {
        // input
                
        // output
        vm.state.$fetching
            .drive(indicatorView.rx.isAnimating)
            .disposed(by: dbag)
        
        vm.state.$stations
            .map { !$0.isEmpty }
            .drive(label.rx.isHidden)
            .disposed(by: dbag)

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

extension FavoritesViewController {
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
            cell.toggleFavorites = { [weak self] _ in
                self?.vm.send(action: .remove(station))
            }
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

extension FavoritesViewController {
    static func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, environment in
            switch Section(rawValue: section) {
            case .mostVoted:
                return NSCollectionLayoutSection.stationList(itemCountInRow: 2)
            default:
                fatalError("No definition for section \(section)")
            }
        }
    }
}

// MARK: - CollectionViewDelegate

extension FavoritesViewController: UICollectionViewDelegate {
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
            vm.send(action: .fetchNext)
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

extension FavoritesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        let query = searchBar.text
        self.queryRelay.accept(query)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
