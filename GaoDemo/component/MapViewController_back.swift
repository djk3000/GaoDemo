//
//  MapView.swift
//  GaoDeDemo
//
//  Created by 邓璟琨 on 2023/2/6.
//

import Foundation
import SwiftUI
import Combine

class MapViewController_back: UIViewController, MAMapViewDelegate, AMapSearchDelegate, CLLocationManagerDelegate {
    static let instance = MapViewController()
    var mapView: MAMapView!
    var search: AMapSearchAPI?
    var request: AMapReGeocodeSearchRequest?
    let data: DataFile = DataFile.instance
    @Published var selectedHotalName: String?
    @Published var tapInfo: Bool = false
    @Published var showDetial: Bool = false
    private let locationManager = CLLocationManager()
    
    var firstLocation: CLLocationCoordinate2D?
    
    var poiDataList: [POIModel] = []
    
    override func viewDidLoad() {
        setData()
        setAnnotation()
        //        dispalyHotal()
    }
    
    func setData() {
        AMapServices.shared().enableHTTPS = true
        request = AMapReGeocodeSearchRequest()
        
        search = AMapSearchAPI()
        search!.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func setAnnotation() {
        mapView = MAMapView(frame: self.view.bounds)
        
        if let mapView = mapView {
            mapView.delegate = self
            
            mapView.setZoomLevel(17, animated: true)
            mapView.showsUserLocation = false
            mapView.userTrackingMode = .follow
            //            let r = MAUserLocationRepresentation()
            //            r.showsHeadingIndicator = true
            //            r.fillColor = .red
            //            mapView.update(r)
            
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
        if let search = search {
            let request = AMapPOIKeywordsSearchRequest()
            request.keywords = searchText
            request.location = AMapGeoPoint.location(withLatitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
            request.requireExtension = true
            request.city = city
            
            //            request.cityLimit = true
            request.requireSubPOIs = true
            search.aMapPOIKeywordsSearch(request)
        }
    }
    
    //回调poi信息
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        print("搜索结果Count----\(response.pois.count)")
        mapView.removeAnnotations(mapView.annotations)
        for poi in response.pois {
            let pointAnnotation = MAPointAnnotation()
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: poi.location.latitude, longitude: poi.location.longitude)
            pointAnnotation.title = poi.name
            pointAnnotation.subtitle = poi.address
            mapView!.addAnnotation(pointAnnotation)
        }
        //        if response.count == 0 {
        //            if data.cities.count == 0 {
        //                for city in response.suggestion.cities {
        //
        //                    data.setCity(city: city.city)
        //                }
        //            } else {
        //                data.cities.remove(at: 0)
        //            }
        //
        //            self.searchHotal(searchText: "希尔顿", city: data.cities.first!)
        //
        //            //            print(data.cities.count)
        //            return
        //        }
        
        //        for poi in response.pois {
        //            var imageUrlList: [String] = []
        //            for imageUrl in poi.images {
        //                imageUrlList.append(imageUrl.url)
        //            }
        //
        //            let encoderPos = POIModel(city: poi.city, name: poi.name, address: poi.address, latitude: poi.location.latitude, longitude: poi.location.longitude, type: poi.type, tel: poi.tel, rating: poi.extensionInfo.rating, image: imageUrlList)
        //            poiDataList.append(encoderPos)
        //        }
        //
        //        data.cities.remove(at: 0)
        //        if data.cities.count == 0 {
        //            let encoder = JSONEncoder()
        //            let encoded = (try? encoder.encode(poiDataList))!
        //            let stringData = String(data: encoded, encoding: .utf8)!
        //            print(String(data: encoded, encoding: .utf8)!)
        //
        //            return
        //        }
        //        self.searchHotal(searchText: "希尔顿", city: data.cities.first!)
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
            annotationView!.animatesDrop = false
            annotationView!.isDraggable = false
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
    
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        //地图停止滑动调用
        if wasUserAction {
            print("停止滑动")
            searchHotal(searchText: "麦当劳")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        print("当前位置经纬度\(location.coordinate.longitude)-\(location.coordinate.latitude)")
        firstLocation = location.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("定位error-\(error.localizedDescription)")
    }
    
    
}


//func sendUrl(location: String) {
//    // 1. 创建URL对象，设置请求URL和query参数
//    let baseUrl = "http://172.16.40.48:19009/map/center"
//    let encodedName = location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//
//    let queryItems = [
//        URLQueryItem(name: "type", value: "amap"),
//        URLQueryItem(name: "region", value: encodedName)
//    ]
//
//    var urlComponents = URLComponents(string: baseUrl)
//    urlComponents?.queryItems = queryItems
//    let url = urlComponents?.url
//    // 2. 创建URLSession对象
//    let session = URLSession.shared
//    // 3. 创建URLSessionDataTask对象，设置请求方法和请求头
//    let task = session.dataTask(with: URLRequest(url: url!)) { (data, response, error) in
//        // 4. 处理响应数据
//        if let data = data {
//            let result = String(data: data, encoding: .utf8)
//            let jsonData = result!.data(using: .utf8)!
//            let decoder = JSONDecoder()
//            let locationJson = try! decoder.decode(Location.self, from: jsonData)
//            self.list.append(CitiesLocation(city: location, latitude: locationJson.lat, longitude: locationJson.lng))
//
//            do {
//                let encoder = JSONEncoder()
//                encoder.outputFormatting = .prettyPrinted
//                let jsonData = try encoder.encode(self.list)
//                if let jsonString = String(data: jsonData, encoding: .utf8) {
//                    print(jsonString)
//                }
//            } catch {
//                print("Encoding failed: \(error.localizedDescription)")
//            }
//        }
//    }
//    // 5. 发送请求
//    task.resume()
//}

//let pointAnnotation = MAPointAnnotation()
//var city = citiesCenterList.first(where: { $0.city == response.pois[0].province })
//if city == nil { return; }
//if defaultName == "星巴克" {
//    city?.starbucks = response.count
//    citiesCenterList1.append(city!)
//}else if defaultName == "麦当劳" {
//    city?.mcdonalds = response.count
//    citiesCenterList2.append(city!)
//}else if defaultName == "希尔顿" {
//    city?.hilton = response.count
//    citiesCenterList3.append(city!)
//}
//
//            do {
//                let encoder = JSONEncoder()
//                encoder.outputFormatting = .prettyPrinted
//                let jsonData = try encoder.encode(self.citiesCenterList3)
//                if let jsonString = String(data: jsonData, encoding: .utf8) {
//                    print(jsonString)
//                }
//            } catch {
//                print("Encoding failed: \(error.localizedDescription)")
//            }


//func getJson() {
//    var citiesCenterList: [CitiesLocation] = []
//    if let jsonPath = Bundle.main.url(forResource: "citiesCenter", withExtension: "json") {
//        let jsonData = try! Data(contentsOf: jsonPath)
//        let result = try! JSONDecoder().decode([CitiesLocation].self, from: jsonData)
//        citiesCenterList = result
//    }
//    
//    if let jsonPath = Bundle.main.url(forResource: "pois", withExtension: "json") {
//        let jsonData = try! Data(contentsOf: jsonPath)
//        let result = try! JSONDecoder().decode([AllCitiesData].self, from: jsonData)
//        
//        for i in 0..<citiesCenterList.count {
//            var starCount = result.filter { $0.province == citiesCenterList[i].city && $0.sort == "星巴克" }.count
//            citiesCenterList[i].starbucks = starCount
//            
//            var mcCount = result.filter { $0.province == citiesCenterList[i].city && $0.sort == "麦当劳" }.count
//            citiesCenterList[i].mcdonalds = mcCount
//            
//            var hiCount = result.filter { $0.province == citiesCenterList[i].city && $0.sort == "希尔顿酒店" }.count
//            citiesCenterList[i].hilton = hiCount
//        }
//        
//        do {
//            let encoder = JSONEncoder()
//            encoder.outputFormatting = .prettyPrinted
//            let jsonData = try encoder.encode(citiesCenterList)
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print(jsonString)
//            }
//        } catch {
//            print("Encoding failed: \(error.localizedDescription)")
//        }
//    }
//}
