//
//  SearchViewController.swift
//  Radiow
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
        
//        vm.send(action: .lookup)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard isViewLoaded else { return }
        
        defer {
            super.viewWillTransition(to: size, with: coordinator)
        }
        
        if #available(iOS 14, *) {
            // Do nothing
        } else {
            if let layout = cv.collectionViewLayout as? UICollectionViewCompositionalLayout {
                coordinator.animate { _ in
                    layout.invalidateLayout()
                }
            }
        }
    }
    
    func configureSubviews() {
        label.text = "Search stations by name"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        indicatorView.color = .red
        indicatorView.hidesWhenStopped = true
        
        cv = UICollectionView(frame: view.bounds, collectionViewLayout: Self.createCollectionViewLayout())
        cv.delegate = self
        cv.backgroundColor = .systemBackground
        cv.keyboardDismissMode = .interactive
        cv.register(StationCell.self, forCellWithReuseIdentifier: StationCell.identifier)
        cv.register(StationSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: StationSectionHeaderView.identifier)
        
        dataSource = createDataSource()
        
        searchBar.placeholder = "Search stations by name"
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
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
        
        cv.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        label.centerInContainer()
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
        return UICollectionViewDiffableDataSource<Section, RadioStation>(collectionView: cv)
        { (collectionView, indexPath, station) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { return nil }

            switch section {
            case .mostVoted:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StationCell.identifier, for: indexPath) as? StationCell
                else { return nil }
                cell.configure(station: station)
                cell.toggleFavorites = { [weak self] _ in
                    self?.vm.send(action: .toggleFavorites(station))
                }
                return cell
            }
        } .then {
            $0.supplementaryViewProvider = { (cv, kind, indexPath) in
                guard let header = cv.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                    withReuseIdentifier: StationSectionHeaderView.identifier,
                                                                       for: indexPath) as? StationSectionHeaderView,
                      let section = Section(rawValue: indexPath.section)
                else {
                    return nil
                }

                header.configure(title: section.title)

                return header
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
                return NSCollectionLayoutSection.stationList(itemCountInRow: 3, environment: environment)
            default:
                fatalError("No definition for section \(section)")
            }
        }
    }
}

// MARK: - CollectionViewDelegate

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let station = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        vm.send(action: .play(station))
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
        
        let playStation = UIAction(title: "Play") { [weak self] _ in
            self?.vm.send(action: .play(station))
        }

        return coordinator.contextMenu(for: station, actions: [playStation])
    }
    
//    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
//        guard let vc = animator.previewViewController else {
//            return
//        }
//
//        animator.addCompletion { [weak self] in
//            guard let coordinator = self?.vm.coordinator as? SearchCoordinator else { return }
//            coordinator.coordinate(.pop(vc))
//        }
//    }
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