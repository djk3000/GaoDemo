//
//  MapView.swift
//  GaoDeDemo
//
//  Created by 邓璟琨 on 2023/2/6.
//

import Foundation
import SwiftUI
import Combine

class MapViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate {
    static let instance = MapViewController()
    var mapView: MAMapView!
    var search: AMapSearchAPI?
    let data: DataFile = DataFile.instance
    @Published var selectedHotalName: String?
    @Published var tapInfo: Bool = false
    @Published var showDetial: Bool = false
    
    
    var poiDataList: [POIModel] = []
    
    override func viewDidLoad() {
        setAnnotation()
        dispalyHotal()
        //                searchHotal(searchText: "希尔顿")
    }
    
    func setAnnotation() {
        mapView = MAMapView(frame: self.view.bounds)
        AMapServices.shared().enableHTTPS = true
        if let mapView = mapView {
            mapView.delegate = self
            
            //            mapView.setZoomLevel(17, animated: true)
            //            mapView.showsUserLocation = false
            //            mapView.userTrackingMode = .follow
            //                        let r = MAUserLocationRepresentation()
            //                        r.showsHeadingIndicator = true
            //                        r.fillColor = .red
            //                        mapView.update(r)
            
            //标记
            //            let pointAnnotation = MAPointAnnotation()
            //            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: 31.164395, longitude: 121.394605)
            //            pointAnnotation.title = "宝石大楼"
            //            pointAnnotation.subtitle = "宝石大楼20号楼"
            //            mapView.addAnnotation(pointAnnotation)
            
            self.view.addSubview(mapView)
        }
    }
    
    func dispalyHotal() {
        if let jsonPath = Bundle.main.url(forResource: "config", withExtension: "json") {
            let jsonData = try! Data(contentsOf: jsonPath)
            
            let result = try! JSONDecoder().decode([POIModel].self, from: jsonData)
            for poi in result{
                if poi.latitude == nil || poi.longitude == nil { continue }
                let pointAnnotation = MAPointAnnotation()
                pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: poi.latitude!, longitude: poi.longitude!)
                pointAnnotation.title = poi.name
                pointAnnotation.subtitle = poi.address
                mapView!.addAnnotation(pointAnnotation)
            }
        }
    }
    
    func searchHotal(searchText: String, city: String = "") {
        search = AMapSearchAPI()
        if let search = search {
            search.delegate = self
            
            let request = AMapPOIKeywordsSearchRequest()
            request.keywords = searchText
            request.requireExtension = true
            request.city = city
            
            //                        request.cityLimit = true
            request.requireSubPOIs = true
            search.aMapPOIKeywordsSearch(request)
        }
    }
    
    //回调poi信息
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if response.count == 0 {
            if data.cities.count == 0 {
                for city in response.suggestion.cities {
                    
                    data.setCity(city: city.city)
                }
            } else {
                data.cities.remove(at: 0)
            }
            
            self.searchHotal(searchText: "希尔顿", city: data.cities.first!)
            
            //            print(data.cities.count)
            return
        }
        
        //解析response获取POI信息，具体解析见 Demo
        //        for poi in response.pois {
        //            print(poi.name)
        //
        //            let pointAnnotation = MAPointAnnotation()
        //            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: poi.location.latitude, longitude: poi.location.longitude)
        //            pointAnnotation.title = poi.name
        //            pointAnnotation.subtitle = poi.address
        //            mapView!.addAnnotation(pointAnnotation)
        //        }
        
        for poi in response.pois {
            var imageUrlList: [String] = []
            for imageUrl in poi.images {
                imageUrlList.append(imageUrl.url)
            }
            
            let encoderPos = POIModel(city: poi.city, name: poi.name, address: poi.address, latitude: poi.location.latitude, longitude: poi.location.longitude, type: poi.type, tel: poi.tel, rating: poi.extensionInfo.rating, image: imageUrlList)
            poiDataList.append(encoderPos)
        }
        
        data.cities.remove(at: 0)
        if data.cities.count == 0 {
            let encoder = JSONEncoder()
            let encoded = (try? encoder.encode(poiDataList))!
            let stringData = String(data: encoded, encoding: .utf8)!
            print(String(data: encoded, encoding: .utf8)!)
            
            return
        }
        self.searchHotal(searchText: "希尔顿", city: data.cities.first!)
    }
    
    //点击map
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        //        print(view.annotation.title)
        mapView.setCenter(CLLocationCoordinate2D(latitude: view.annotation.coordinate.latitude, longitude: view.annotation.coordinate.longitude), animated: true)
        selectedHotalName = view.annotation.title
        showDetial.toggle()
    }
    
    //点击list
    func setMapCenter(_ poi: POIModel) {
        let selectedAnnotation = (mapView.annotations as [MAPointAnnotation])
            .first(where: { $0.title == poi.name })
        mapView.selectAnnotation(selectedAnnotation, animated: true)
    }
    
    //回调是否显示标记等信息
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as! MAPinAnnotationView?
            
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView!.image = UIImage(named: "map")
            //设置中心点偏移，使得标注底部中间点成为经纬度对应点
            annotationView!.centerOffset = CGPoint(x: 0, y: -18);
            
            let button: SubclassedUIButton = SubclassedUIButton(type: UIButton.ButtonType.detailDisclosure)
            
            button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
            button.title = annotation.title!
            
            annotationView!.canShowCallout = true
            annotationView!.animatesDrop = true
            annotationView!.isDraggable = true
            annotationView!.rightCalloutAccessoryView = button
            
            return annotationView!
        }
        
        return nil
    }
    
    @objc func tapped(sender: SubclassedUIButton) {
        tapInfo.toggle()
    }
    
    class SubclassedUIButton: UIButton {
        var title: String?
    }
}
