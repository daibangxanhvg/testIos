//
//  PhotoListViewController.swift
//  ImSplash
//
//  Created by Lam Pham on 4/22/20.
//  Copyright © 2020 Lam Pham. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoListViewController: UIViewController {
    @IBOutlet weak var clvImage: UICollectionView!
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var btnFavourite: UIButton!
    
    private lazy var layout = WaterfallLayout(with: self)
    
    var isDownloadTapped: Bool = true
    
    var imageList: [FavouriteItem]? {
        didSet {
            DispatchQueue.main.async {
                self.clvImage.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        imageList = Session.shared.getListDownload()
    }
    
    func setUpView() {
        clvImage.collectionViewLayout = layout
        clvImage.translatesAutoresizingMaskIntoConstraints = false
        clvImage.dataSource = self
        clvImage.delegate = self
        clvImage.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        clvImage.register(PagingView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: PagingView.reuseIdentifier)
        clvImage.contentInsetAdjustmentBehavior = .automatic
        clvImage.layoutMargins = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
        clvImage.backgroundColor = UIColor.photoPicker.background
        clvImage.allowsMultipleSelection = false
        
        btnDownload.setTitleColor(.red, for: .normal)
    }
    
    @IBAction func downloadTapped(_ sender: Any) {
        isDownloadTapped = true
        btnDownload.setTitleColor(.red, for: .normal)
        btnFavourite.setTitleColor(.darkGray, for: .normal)
        imageList = Session.shared.getListDownload()
    }
    
    @IBAction func favourtieTapped(_ sender: Any) {
        isDownloadTapped = false
        btnDownload.setTitleColor(.darkGray, for: .normal)
        btnFavourite.setTitleColor(.red, for: .normal)
        imageList = Session.shared.getListFavorite()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension PhotoListViewController: WaterfallLayoutDelegate {
    func waterfallLayout(_ layout: WaterfallLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let photo = imageList else { return .zero}
        return CGSize(width: photo[indexPath.item].width, height: photo[indexPath.item].height)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let photo = imageList?[indexPath.item] else { return .zero }
        let width = collectionView.frame.width
        let height = CGFloat(photo.height) * width / CGFloat(photo.width)
        return CGSize(width: width, height: height)
    }
}


// MARK: - UICollectionViewDataSource
extension PhotoListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath)
        guard let photoCell = cell as? PhotoCell, let photo = imageList?[indexPath.item] else { return cell }
        
        photoCell.photoView.imageView.sd_setImage(with: URL(string: photo.imageURL)!, placeholderImage: nil, options: .continueInBackground, completed: nil)
        photoCell.hideCheckMark(isHidden: true)
        photoCell.hideFavourite(isHidden: false)
        photoCell.photoView.addCornerRadius()
        photoCell.cellDelegate = self
        photoCell.indexPath = indexPath
        photoCell.configLike(isLike: photo.isLike)
        photoCell.identifier = photo.identifier
        
        return photoCell
    }
}

extension PhotoListViewController: CellDelegate {
    
    func removeFavourite(at id: String, isLike: Bool) {
        var index: Int?
        if let indexItem = self.imageList?.firstIndex(where: {$0.identifier == id}) {
            index = indexItem
        }
        guard var item = self.imageList?[index ?? 0] else { return }
        
        if isLike {
            item.isLike = true
            if isDownloadTapped {
                Session.shared.updateDownLoad(item)
                Session.shared.addFavorite(item)
                imageList = Session.shared.getListDownload()
            } else {
                // noone here
            }
        } else {
            Session.shared.removeFavorite(item)
            if isDownloadTapped {
                imageList = Session.shared.getListDownload()
            } else {
                imageList = Session.shared.getListFavorite()
            }
        }
        
    }
}
