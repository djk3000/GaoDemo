//
//  ViewModel.swift
//  GaoDemo
//
//  Created by 邓璟琨 on 2023/2/23.
//

import Foundation
import Combine

class GaoViewModel: ObservableObject {
    @Published var allHotal: [POIModel] = []
    @Published var selectedHotal: POIModel?
    @Published var selectedNamePoi: POIModel?
    
    @Published var isShowDetail: Bool = true
    @Published var showDetial: Bool = false
    var service: MapViewController = MapViewController.instance
    var cancelable = Set<AnyCancellable>()
    
    init() {
        getJson()
        addSubcribers()
    }
    
    func addSubcribers(){
        service.$selectedHotalName
            .sink { [weak self] name in
                self?.selectedNamePoi = self?.allHotal.first(where: { $0.name == name })
            }
        .store(in: &cancelable)
        
        service.$showDetial
            .sink { [weak self] _ in
                if self?.selectedNamePoi == nil { return }
                self?.showDetial = true
            }
        .store(in: &cancelable)

        
        service.$tapInfo
            .sink { [weak self] _ in
//                print(self?.service.selectedHotalName)
                self?.isShowDetail.toggle()
            }
        .store(in: &cancelable)
    }
    
    func getJson() {
        if let jsonPath = Bundle.main.url(forResource: "config", withExtension: "json") {
            let jsonData = try! Data(contentsOf: jsonPath)
            let result = try! JSONDecoder().decode([POIModel].self, from: jsonData)
            allHotal = result
        }
    }
}
