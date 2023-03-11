//
//  GaoDemoApp.swift
//  GaoDemo
//
//  Created by 邓璟琨 on 2023/2/6.
//

import SwiftUI

@main
struct GaoDemoApp: App {
    init() {
        AMapServices.shared().apiKey = "a58aaac8a666bcc664fda472457d21f8"
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
