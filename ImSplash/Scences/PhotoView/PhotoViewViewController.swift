//
//  PhotoViewViewController.swift
//  ImSplash
//
//  Created by Lam Pham on 4/22/20.
//  Copyright © 2020 Lam Pham. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoViewViewController: UIViewController {
    
    @IBOutlet weak var imvAvater: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var imvPhoto: UIImageView!
    @IBOutlet weak var btnFavourite: UIButton!
    @IBOutlet weak var btnDownload: UIButton!
    
    var imgURLData: UnsplashPhoto? {
        didSet {
            DispatchQueue.main.async {
                self.lbName.text = self.imgURLData?.user.displayName
                self.lbEmail.text = self.imgURLData?.user.username
                self.getImage(from: self.imgURLData, to: self.imvPhoto, type: .full, isAvatar: false)
                self.getImage(from: self.imgURLData, to: self.imvAvater, isAvatar: true)
                
                let id = self.imgURLData?.identifier
                Session.shared.getListFavorite().forEach { (item) in
                    if item.identifier == id {
                        self.btnFavourite.setImage(UIImage(named: "ic_favo_tapped"), for: .normal)
                    } else {}
                }
                
                Session.shared.getListDownload().forEach { (item) in
                    if item.identifier == id {
                        self.btnDownload.setImage(UIImage(named: "ic_done"), for: .normal)
                    } else {}
                }
            }
        }
    }
    
    var dataImage: Data?
    var responseImage: URLResponse?
    var urlRequest: URLRequest?
    var imageID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imvAvater.addCornerRadius(radius: 20)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func favouriteTapped(_ sender: Any) {
        guard let imgURL = imgURLData?.urls[.full]?.absoluteURL.absoluteString else { return }
        let itemFavo = FavouriteItem(imageURL: imgURL, identifier: imgURLData?.identifier ?? "", isLike: true, width: imgURLData?.width ?? 0, height: imgURLData?.height ?? 0)
        
        let id = self.imgURLData?.identifier
        
        if Session.shared.getListFavorite().isEmpty {
            self.btnFavourite.setImage(UIImage(named: "ic_favo_tapped"), for: .normal)
            Session.shared.addFavorite(itemFavo)
        } else {
            Session.shared.getListFavorite().forEach { (item) in
                if item.identifier == id {
                    self.btnFavourite.setImage(UIImage(named: "ic_favo"), for: .normal)
                    Session.shared.removeFavorite(itemFavo)
                } else {
                    self.btnFavourite.setImage(UIImage(named: "ic_favo_tapped"), for: .normal)
                    Session.shared.addFavorite(itemFavo)
                }
            }
        }
        
        
    }
    
    @IBAction func downloadTapped(_ sender: Any) {
        guard let imgURL = imgURLData?.urls[.full]?.absoluteURL.absoluteString else { return }
        let item = FavouriteItem(imageURL: imgURL, identifier: imgURLData?.identifier ?? "",
                                 isLike: false, width: imgURLData?.width ?? 0,
                                 height: imgURLData?.height ?? 0)
        
        Session.shared.addDownload(item)
        self.btnDownload.setImage(UIImage(named: "ic_done"), for: .normal)
    }
}

extension PhotoViewViewController {
    func getImage(from data: UnsplashPhoto?, to imageView: UIImageView, type: UnsplashPhoto.URLKind? = .full, isAvatar: Bool) {
        guard let data = data else { return }
        var url: URL?
        if isAvatar {
            url = data.user.profileImage[.small]
        } else {
            url = data.urls[type ?? .full]
        }
        guard let urlImage = url else { return }
        imageView.sd_setImage(with: urlImage, placeholderImage: nil, options: .transformAnimatedImage, completed: nil)
    }
}
