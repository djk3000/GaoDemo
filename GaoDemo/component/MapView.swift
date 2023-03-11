//
//  MapView.swift
//  GaoDeDemo
//
//  Created by 邓璟琨 on 2023/2/6.
//

import Foundation
import SwiftUI

struct MapView: UIViewControllerRepresentable {
    let controller: MapViewController
    
    func makeUIViewController(context: Context) -> MapViewController {
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
    }
    
    typealias UIViewControllerType = MapViewController
}
