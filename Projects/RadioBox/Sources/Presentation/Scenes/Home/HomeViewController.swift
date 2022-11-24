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
        
        vm.send(action: .ready)
    }
    
    func configureSubviews() {
        indicatorView.color = .red
        indicatorView.hidesWhenStopped = true
        
        cv = UICollectionView(frame: view.bounds, collectionViewLayout: Self.createCollectionViewLayout())
        cv.delegate = self
        cv.backgroundColor = .systemBackground
        
        dataSource = createDataSource()
        
        layoutSubviews()
    }
    
    func layoutSubviews() {
        view.subviews (
            cv,
            indicatorView
        )
        
        view.layout {
        }
        
        cv.fillContainer()
        indicatorView.centerInContainer()
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
                return NSCollectionLayoutSection.stationList(itemCountInRow: 2)
            default:
                fatalError("No definition for section \(section)")
            }
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
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let station = dataSource.itemIdentifier(for: indexPath),
              let coordinator = vm.coordinator as? HomeCoordinator
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
            guard let coordinator = self?.vm.coordinator as? HomeCoordinator else { return }
            coordinator.coordinate(.pop(vc))
        }
    }
}
