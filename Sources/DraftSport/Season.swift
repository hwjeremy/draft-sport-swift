//
//  Season.swift
//  
//
//  Created by Hugh Jeremy on 11/3/20.
//

import Foundation


public struct Season {
    
    public static let SUPER_RUGBY_2020 = Season(publicId: "2020")
    
    let publicId: String
    
    public init(publicId: String) {
        self.publicId = publicId
    }
    
}
