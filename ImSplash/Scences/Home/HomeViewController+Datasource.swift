//
//  HomeVCHelper.swift
//  ImSplash
//
//  Created by Lam Pham on 4/22/20.
//  Copyright © 2020 Lam Pham. All rights reserved.
//
import UIKit

extension HomeViewController: WaterfallLayoutDelegate {
    func waterfallLayout(_ layout: WaterfallLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let photo = dataSource?.item(at: indexPath.item) else { return .zero }
        return CGSize(width: photo.width, height: photo.height)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let photo = dataSource?.item(at: indexPath.item) else { return .zero }
        let width = collectionView.frame.width
        let height = CGFloat(photo.height) * width / CGFloat(photo.width)
        return CGSize(width: width, height: height)
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let prefetchCount = 19
        if indexPath.item == (dataSource?.items.count ?? prefetchCount) - prefetchCount {
            fetchNextItems()
        } else {}
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let photo = dataSource?.item(at: indexPath.item), collectionView.hasActiveDrag == false else { return }
        let vc = PhotoViewViewController.instantiateFromNib()
        vc.imgURLData = photo
        navigationController?.present(vc, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.items.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath)
        guard let photoCell = cell as? PhotoCell, let photo = dataSource?.item(at: indexPath.item) else { return cell }
        photoCell.configure(with: photo)
        photoCell.photoView.addCornerRadius()
        photoCell.hideFavourite(isHidden: true)
        return photoCell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PagingView.reuseIdentifier, for: indexPath)
        guard let pagingView = view as? PagingView else { return view }
        pagingView.isLoading = ((dataSource?.isFetching) != nil)
        return pagingView
    }
}

