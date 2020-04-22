//
//  PhotoCachingHelper.swift
//  ImSplash
//
//  Created by Lam Pham on 4/22/20.
//  Copyright © 2020 Lam Pham. All rights reserved.
//

import Foundation

class PhotoCachingHelper {
    
    static let shared = PhotoCachingHelper()
    
    var cache: URLCache = {
        let memoryCapacity = 100 * 1024 * 1024
        let diskCapacity = 1000 * 1024 * 1024
        let diskPath = "ImSplashDatabase"
        
        if #available(iOS 13.0, *) {
            return URLCache(
                memoryCapacity: memoryCapacity,
                diskCapacity: diskCapacity,
                directory: URL(fileURLWithPath: diskPath, isDirectory: true)
            )
        }
        else {
            #if !targetEnvironment(macCatalyst)
            return URLCache(
                memoryCapacity: memoryCapacity,
                diskCapacity: diskCapacity,
                diskPath: diskPath
            )
            #else
            fatalError()
            #endif
        }
    }()
    
    private init() {}
    
}
