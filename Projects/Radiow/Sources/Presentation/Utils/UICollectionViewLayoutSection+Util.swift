//
//  NSCollectionLayoutSection+Util.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/11/24.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import Then

extension NSCollectionLayoutSection {
    static func stationList(itemCountInRow: @autoclosure () -> Double, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemCountInRow = environment.traitCollection.verticalSizeClass == .compact ? itemCountInRow() * 2: itemCountInRow()
        let sectionInset = 10.0
        let itemSpacing = 5.0
        let contentWidth = environment.container.effectiveContentSize.width - (sectionInset * 2) - (itemSpacing * itemCountInRow - 1)
        let itemWidth = floor(contentWidth / itemCountInRow)
        let itemHeight = itemWidth + 40
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth),
                                              heightDimension: .estimated(itemHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(itemHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        group.interItemSpacing = .flexible(itemSpacing)
        
        return NSCollectionLayoutSection(group: group).then {
            $0.contentInsets = NSDirectionalEdgeInsets(top: sectionInset, leading: sectionInset, bottom: sectionInset, trailing: sectionInset)
            $0.interGroupSpacing = 4
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
}
