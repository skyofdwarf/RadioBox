//
//  HomeViewController.swift
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
        
        title = "Most voted"
        
        tabBarItem = UITabBarItem(title: "Home",
                                  image: UIImage(systemName: "waveform.circle"),
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
        indicatorView.color = .red
        indicatorView.hidesWhenStopped = true
        
        cv = UICollectionView(frame: view.bounds, collectionViewLayout: Self.createCollectionViewLayout())
        cv.delegate = self
        cv.backgroundColor = .systemBackground
        cv.register(StationCell.self, forCellWithReuseIdentifier: StationCell.identifier)
        cv.register(StationSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: StationSectionHeaderView.identifier)
        
        dataSource = createDataSource()
        
        layoutSubviews()
    }
    
    func layoutSubviews() {
        view.subviews (
            cv,
            indicatorView
        )
        
        cv.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        indicatorView.centerInContainer()
    }
    
    func bindViewModel() {
        vm.state.$fetching
            .drive(indicatorView.rx.isAnimating)
            .disposed(by: dbag)
        
        vm.state.$stations
            .asObservable()
            .bind(with: self) { this, stations in
                this.applyDataSource(stations: stations)
            }
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
        return UICollectionViewDiffableDataSource(collectionView: cv)
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
        }.then {
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

extension HomeViewController {
    static func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, environment in
            switch Section(rawValue: section) {
            case .mostVoted:
                return NSCollectionLayoutSection.stationList(itemCountInRow: 2, environment: environment)
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
        
        vm.send(action: .play(station))
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
//            guard let coordinator = self?.vm.coordinator as? HomeCoordinator else { return }
//            coordinator.coordinate(.pop(vc))
//        }
//    }
}
