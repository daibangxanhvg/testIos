//
//  Session.swift
//  ImSplash
//
//  Created by Lam Pham on 4/22/20.
//  Copyright © 2020 Lam Pham. All rights reserved.
//

import Foundation

class Session: NSObject {
    static let shared = Session()
    
    private override init(){}
    
    //Favourite
    func getListFavorite() -> [FavouriteItem] {
        if let favoriteList = UserDefaults.standard.value([FavouriteItem].self, forKey: "UserFavorites") {
            return favoriteList
        } else {
            return [FavouriteItem]()
        }
    }
    
    func addFavorite(_ favoriteItem: FavouriteItem) {
        var userFavoriteList = getListFavorite()
        for element in  userFavoriteList {
            if element.identifier == favoriteItem.identifier {
                return
            } else {}
        }
        
        userFavoriteList.append(favoriteItem)
        
        UserDefaults.standard.set(encodable: userFavoriteList, forKey: "UserFavorites")
        UserDefaults.standard.synchronize()
        
    }
    
    func clearUserFavorite() {
        UserDefaults.standard.set(nil, forKey: "UserFavorites")
    }
    
    
    func removeFavorite(_ favoriteItem: FavouriteItem) {
        var downLoadList = getListDownload()
        if let index = downLoadList.firstIndex(where: {$0.identifier == favoriteItem.identifier}) {
            downLoadList[index].isLike = false
        } else {}
        UserDefaults.standard.set(encodable: downLoadList, forKey: "UserDownload")
        UserDefaults.standard.synchronize()
            
        var userFavoriteList = getListFavorite()
        if let index = userFavoriteList.firstIndex(where: {$0.identifier == favoriteItem.identifier}) {
          userFavoriteList.remove(at: index)
        } else {}
        
        UserDefaults.standard.set(encodable: userFavoriteList, forKey: "UserFavorites")
        UserDefaults.standard.synchronize()
    }
    
    //Download
    func getListDownload() -> [FavouriteItem] {
        if let dowloadList = UserDefaults.standard.value([FavouriteItem].self, forKey: "UserDownload") {
            
            var id = ""
            dowloadList.forEach { (dlItem) in
                getListFavorite().forEach { (fvItem) in
                    if dlItem.identifier == fvItem.identifier {
                        id = dlItem.identifier
                    }
                }
            }
            var newList = dowloadList
            
            if let index = dowloadList.firstIndex(where: {$0.identifier == id}) {
                newList[index].isLike = true
            } else {}
            
            return newList
        } else {
            return [FavouriteItem]()
        }
    }
    
    func updateDownLoad(_ favoriteItem: FavouriteItem) {
        var newList = getListDownload()
        if let index = newList.firstIndex(where: {$0.identifier == favoriteItem.identifier}) {
            newList[index].isLike = true
        } else {}
        UserDefaults.standard.set(encodable: newList, forKey: "UserDownload")
        UserDefaults.standard.synchronize()
    }
    
    func addDownload(_ favoriteItem: FavouriteItem) {
        var dowloadList = getListDownload()
        for element in dowloadList {
            if favoriteItem.identifier == element.identifier {
                return
            } else {}
        }
        
        dowloadList.append(favoriteItem)
        
        UserDefaults.standard.set(encodable: dowloadList, forKey: "UserDownload")
        UserDefaults.standard.synchronize()
    }
    
    func clearDownload() {
        UserDefaults.standard.set(nil, forKey: "UserDownload")
    }
    
    
    func removeFavouriteInDownload(_ favoriteItem: FavouriteItem) {
        var dowloadList = getListDownload()
        if let index = dowloadList.firstIndex(where: {$0.identifier == favoriteItem.identifier}) {
            dowloadList[index].isLike = false
        } else {}
        
        UserDefaults.standard.set(encodable: dowloadList, forKey: "UserDownload")
        UserDefaults.standard.synchronize()
    }
    
}

extension UserDefaults {

    func set<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
        }
    }

    func value<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = object(forKey: key) as? Data,
            let value = try? JSONDecoder().decode(type, from: data) {
            return value
        }
        return nil
    }
}
