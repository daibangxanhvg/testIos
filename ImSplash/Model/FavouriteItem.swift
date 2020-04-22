//
//  FavouriteItem.swift
//  ImSplash
//
//  Created by Lam Pham on 4/22/20.
//  Copyright © 2020 Lam Pham. All rights reserved.
//

import Foundation

struct FavouriteItem: Codable {
    let imageURL: String
    let identifier: String
    var isLike: Bool = false
    
    let width: Int
    let height: Int
}
