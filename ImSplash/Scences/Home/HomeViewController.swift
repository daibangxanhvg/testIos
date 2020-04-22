//
//  HomeViewController.swift
//  ImSplash
//
//  Created by Lam Pham on 4/22/20.
//  Copyright © 2020 Lam Pham. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var clvImageList: UICollectionView!
  
    private lazy var layout = WaterfallLayout(with: self)
    private let editorialDataSource = PhotosDataSourceFactory.collection(identifier: Configuration.shared.editorialCollectionId).dataSource
   
    private let spinner: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.hidesWhenStopped = true
            return spinner
        } else {
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.hidesWhenStopped = true
            return spinner
        }
    }()
    
    private lazy var emptyView: EmptyView = {
        let view = EmptyView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var dataSource: PagedDataSource? {
        didSet {
            oldValue?.cancelFetch()
            dataSource?.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        setUpView()
        setUpComponent()
    }
    
    func setUpView() {
        clvImageList.collectionViewLayout = layout
        clvImageList.translatesAutoresizingMaskIntoConstraints = false
        clvImageList.dataSource = self
        clvImageList.delegate = self
        clvImageList.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        clvImageList.register(PagingView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: PagingView.reuseIdentifier)
        clvImageList.contentInsetAdjustmentBehavior = .automatic
        clvImageList.layoutMargins = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
        clvImageList.backgroundColor = UIColor.photoPicker.background
        clvImageList.allowsMultipleSelection = false
        
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: clvImageList.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: clvImageList.centerYAnchor)
        ])
    }
    
    func setUpComponent() {
        dataSource = editorialDataSource
        fetchNextItemsIfNeeded()
        dataSource?.delegate = self
    }
    
    func fetchNextItems() {
        dataSource?.fetchNextPage()
    }
    
    private func fetchNextItemsIfNeeded() {
        dataSource = PhotosDataSourceFactory.search(query: "viet nam").dataSource
        fetchNextItems()
    }
    
    private func showEmptyView(with state: EmptyViewState) {
        emptyView.state = state
        
        guard emptyView.superview == nil else { return }
        
        spinner.stopAnimating()
        
        view.addSubview(emptyView)
        
        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyView.leftAnchor.constraint(equalTo: view.leftAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    private func hideEmptyView() {
        emptyView.removeFromSuperview()
    }
    
    
    //MARK: Action tapped
    @IBAction func btnDownloadTapped(_ sender: Any) {
        let vc = PhotoListViewController.instantiateFromNib()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - PagedDataSourceDelegate
extension HomeViewController: PagedDataSourceDelegate {
    func dataSourceWillStartFetching(_ dataSource: PagedDataSource) {
        if dataSource.items.count == 0 {
            spinner.startAnimating()
        }
    }

    func dataSource(_ dataSource: PagedDataSource, didFetch items: [UnsplashPhoto]) {
        guard dataSource.items.count > 0 else {
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.showEmptyView(with: .noResults)
            }
            return
        }

        let newPhotosCount = items.count
        let startIndex = (self.dataSource?.items.count ?? 0) - newPhotosCount
        let endIndex = startIndex + newPhotosCount
        var newIndexPaths = [IndexPath]()
        for index in startIndex..<endIndex {
            newIndexPaths.append(IndexPath(item: index, section: 0))
        }

        DispatchQueue.main.async { [unowned self] in
            self.spinner.stopAnimating()
            self.hideEmptyView()

            let hasWindow = self.clvImageList.window != nil
            let collectionViewItemCount = self.clvImageList.numberOfItems(inSection: 0)
            if hasWindow && collectionViewItemCount < dataSource.items.count {
                self.clvImageList.insertItems(at: newIndexPaths)
            } else {
                self.clvImageList.reloadData()
            }
        }
    }

    func dataSource(_ dataSource: PagedDataSource, fetchDidFailWithError error: Error) {
        let state: EmptyViewState = (error as NSError).isNoInternetConnectionError() ? .noInternetConnection : .serverError

        DispatchQueue.main.async {
            self.showEmptyView(with: state)
        }
    }
}
