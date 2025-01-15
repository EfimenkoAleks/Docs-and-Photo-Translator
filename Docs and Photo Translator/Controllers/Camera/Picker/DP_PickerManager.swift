//
//  DP_PickerManager.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 28.07.2024.
//

import UIKit
import Photos

struct DP_Pickture: Hashable {
    var image: URL?
    var date: String
    var isSelected: Bool
}


enum SectionPhotos: Int, CaseIterable {
    case one
}

typealias DP_PickerManagerExtension = DP_PickerManager

class DP_PickerManager : NSObject {
    
    typealias DataSource = UICollectionViewDiffableDataSource<SectionPhotos, DP_Pickture>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionPhotos, DP_Pickture>
    
    var eventHandler: Block<DP_Pickture>?
    
    private var collection: UICollectionView
    private lazy var dataSource = dp_makeDataSource()
    private var imageData: [DP_Pickture] = []
    private let helper: DP_CameraHelper = DP_CameraHelper()
    private var snapshot = Snapshot()
    private var isSelecting: Bool = false
    
    init(_ collection: UICollectionView) {
      //  self.imageData = data
        self.collection = collection
        super.init()
        
        dp_registerCollectionViewCells()
        dp_setLayout()
        dp_getPhotoData()

        self.collection.delegate = self
    }
    
    func dp_selectingElements(isSelecting: Bool) {
        self.isSelecting = isSelecting
        
        let filtred = imageData.filter({$0.isSelected == true})
        if !filtred.isEmpty {
            for (i, event) in imageData.enumerated() {
                if event.isSelected {
                    imageData[i].isSelected = false
                }
            }
            dp_reloadDataSource(pictures: imageData, animatingDifferences: true)
        }
    }
}

// MARK: - create data source
private extension DP_PickerManagerExtension {
    
    func dp_getPhotoData() {
        if imageData.isEmpty {
            helper.dp_getPhotos(completion: { [weak self] result in
                self?.imageData = result
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.dp_reloadDataSource(pictures: self.imageData, animatingDifferences: false)
                }
            })
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.dp_reloadDataSource(pictures: self.imageData, animatingDifferences: false)
            }
        }
        
    }
    
    func dp_makeDataSource() -> DataSource {
    
        let dataSource = DataSource(
            collectionView: collection,
            cellProvider: { (collectionView, indexPath, img) ->
                UICollectionViewCell? in
    
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: DP_ConstantId.pickerCell,
                    for: indexPath) as? DP_PickerCell
                cell?.sm_configure(img)
                return cell
            })
        return dataSource
    }
    
    func dp_reloadDataSource(pictures: [DP_Pickture], animatingDifferences: Bool) {
        snapshot.deleteAllItems()
        snapshot.appendSections([.one])
        snapshot.appendItems(pictures)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func dp_registerCollectionViewCells() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.collection.register(DP_PickerCell.nib, forCellWithReuseIdentifier: DP_ConstantId.pickerCell)
        }
    }
    
    func dp_setLayout() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.collection.collectionViewLayout = self.helper.dp_section()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension DP_PickerManagerExtension: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageData[indexPath.item].isSelected = true
        dp_reloadDataSource(pictures: imageData, animatingDifferences: true)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.eventHandler?(self.imageData[indexPath.item])
        }
    }
}
