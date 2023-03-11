//
//  Model.swift
//  GaoDemo
//
//  Created by 邓璟琨 on 2023/2/22.
//

import Foundation

struct POIModel: Codable, Hashable {
    let city: String?
    let name: String?
    let address: String?
    let latitude: CGFloat?
    let longitude: CGFloat?
    
    let type: String?
    let tel: String?
    let rating: CGFloat? //评分
    let image: [String]? //图片
}
