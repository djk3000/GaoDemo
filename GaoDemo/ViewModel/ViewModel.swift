//
//  ViewModel.swift
//  GaoDemo
//
//  Created by 邓璟琨 on 2023/2/23.
//

import Foundation
import Combine

class GaoViewModel: ObservableObject {
    @Published var allPlaces: [POIModel] = []
    @Published var citiesCenterList: [CitiesLocation] = []
    @Published var selectedHotal: POIModel?
    @Published var selectedNamePoi: POIModel?
    
    @Published var isShowDetial: Bool = true
    @Published var showDetial: Bool = false
    var controller: MapViewController = MapViewController.instance
    var cancelable = Set<AnyCancellable>()
    
    init() {
        getJson()
        addSubcribers()
    }
    
    func addSubcribers(){
        controller.$selectedName
            .sink { [weak self] name in
                self?.selectedNamePoi = self?.allPlaces.first(where: { $0.name == name })
            }
            .store(in: &cancelable)
        
        controller.$showDetial
            .sink { [weak self] _ in
                if self?.selectedNamePoi == nil { return }
                self?.showDetial = true
            }
            .store(in: &cancelable)
        
        
        controller.$tapInfo
            .sink { [weak self] _ in
                //                print(self?.service.selectedHotalName)
                self?.isShowDetial.toggle()
            }
            .store(in: &cancelable)
        
        controller.$poiDataList
            .sink { [weak self] data in
                self?.allPlaces = data
            }
            .store(in: &cancelable)
        
        controller.$defaultName
            .sink { [weak self] data in
                guard let self = self else { return }
                for (i, city) in self.citiesCenterList.enumerated() {
                    if data == self.controller.options[0] {
                        self.citiesCenterList[i].count = city.hilton! + city.mcdonalds! + city.starbucks!
                    } else if data == self.controller.options[1] {
                        self.citiesCenterList[i].count = city.mcdonalds!
                    } else if data == self.controller.options[2] {
                        self.citiesCenterList[i].count = city.starbucks!
                    } else if data == self.controller.options[3] {
                        self.citiesCenterList[i].count = city.hilton!
                    }
                }
            }
            .store(in: &cancelable)
    }
    
    func getJson() {
        if let jsonPath = Bundle.main.url(forResource: "citiesCenter", withExtension: "json") {
            let jsonData = try! Data(contentsOf: jsonPath)
            let result = try! JSONDecoder().decode([CitiesLocation].self, from: jsonData)
            citiesCenterList = result
        }
    }
    
    /**
     切换Content
     */
    func changeContent() {
        controller.contentTypes = []
        controller.setClear()
        controller.selectedSearchContent()
    }
}
