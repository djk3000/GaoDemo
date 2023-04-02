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

struct CitiesLocation: Codable, Hashable {
    let city: String?
    let latitude: CGFloat?
    let longitude: CGFloat?
    var hilton: Int? = 0
    var starbucks: Int? = 0
    var mcdonalds: Int? = 0
    var count: Int? = 0
}

struct AllCitiesData: Codable {
    let id: ID
    let title: String
    let point: Point
    let address, province, city: String
    let phoneNumber: String?
    let image: String
    let v: Int
    let rating: Double?
    let sort: String
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, point, address, province, city, phoneNumber, image, rating
        case v = "__v"
        case sort
    }
}

struct ID: Codable {
    let oid: String
    
    enum CodingKeys: String, CodingKey {
        case oid = "$oid"
    }
}

struct Point: Codable {
    let lat, lng: Double
}
