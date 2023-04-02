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
    var request: AMapReGeocodeSearchRequest?
    let data: DataFile = DataFile.instance
    var previousZoomLevel: CGFloat = 0.0
    var previousRegion: MACoordinateRegion?
    
    var zoomLevel: Double = 9
    
    @Published var defaultName: String = "全部"
    
    let options = ["全部", "麦当劳", "星巴克", "希尔顿酒店"]
    
    var contentTypes: [String] = []
    
    var isDetial: Bool = true
    var isLocalUser: Bool = false
    var isFirstData: Bool = true
    @Published var showCities: Bool = false
    
    @Published var selectedName: String?
    @Published var tapInfo: Bool = false
    @Published var showDetial: Bool = false
    private let locationManager = CLLocationManager()
    
    @Published var poiDataList: [POIModel] = []
    @Published var citiesCenterList: [CitiesLocation] = []
    
    var cancelable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        setData()
        setAnnotation()
        getJson()
    }
    
    func setData() {
        mapView = MAMapView(frame: self.view.bounds)
        
        AMapServices.shared().enableHTTPS = true
        request = AMapReGeocodeSearchRequest()
        
        search = AMapSearchAPI()
        search!.delegate = self
    }
    
    func getJson() {
        if let jsonPath = Bundle.main.url(forResource: "citiesCenter", withExtension: "json") {
            let jsonData = try! Data(contentsOf: jsonPath)
            let result = try! JSONDecoder().decode([CitiesLocation].self, from: jsonData)
            citiesCenterList = result
        }
    }
    
    /**当前位置**/
    func setAnnotation() {
        if let mapView = mapView {
            mapView.delegate = self
            
            mapView.setZoomLevel(15, animated: true)
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
            self.view.addSubview(mapView)
        }
    }
    
    /**搜索内容**/
    func searchPlace(place: String, currentCoordinate: CLLocationCoordinate2D, city: String = "", isZoomOut: Bool) {
        if let search = search {
            let request = AMapPOIKeywordsSearchRequest()
            request.keywords = place
            if isZoomOut {
                request.location = AMapGeoPoint.location(withLatitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
            }
            
            request.offset = 20
            request.city = city
            request.requireExtension = true
            request.requireSubPOIs = true
            search.aMapPOIKeywordsSearch(request)
        }
    }
    
    /**回调poi信息，并添加标记**/
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if contentTypes.contains(response.pois.first?.type ?? "") {
            setClear()
        }
        
        //屏幕外的移除
        //        let visibleRect = mapView.visibleMapRect
        //        for annotation in mapView.annotations {
        //            // 将标记的经纬度坐标转换为地图上的点坐标
        //            let annotationPoint = MAMapPointForCoordinate((annotation as! MAAnnotation).coordinate)
        //            if !MAMapRectContainsPoint(visibleRect, annotationPoint) {
        //                // 标记不在可见区域内，移除标记
        //                mapView.removeAnnotation(annotation as? MAAnnotation)
        //                poiDataList.removeAll(where: { $0.name == (annotation as? MAAnnotation)?.title })
        //            }
        //        }
        
        //画详细图及加入list
        for poi in response.pois {
            if poiDataList.contains(where: { $0.name == poi.name }) {
                return
            }
            let pointAnnotation = MAPointAnnotation()
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: poi.location.latitude, longitude: poi.location.longitude)
            pointAnnotation.title = poi.name
            pointAnnotation.subtitle = poi.address
            mapView!.addAnnotation(pointAnnotation)
            
            //加入list
            var imageUrlList: [String] = []
            for imageUrl in poi.images {
                imageUrlList.append(imageUrl.url)
            }
            
            let encoderPos = POIModel(city: poi.city, name: poi.name, address: poi.address, latitude: poi.location.latitude, longitude: poi.location.longitude, type: poi.type, tel: poi.tel, rating: poi.extensionInfo.rating, image: imageUrlList)
            poiDataList.append(encoderPos)
        }
        
        contentTypes.append(response.pois.first(where: {$0.type != nil})?.type ?? "1")
    }
    
    /**点击map**/
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        let annotation = view.annotation
        if annotation?.isKind(of: MAUserLocation.self) ?? false {
            print("当前标注为用户位置")
            isLocalUser = true
            return
        }
        isLocalUser = false
        mapView.setCenter(CLLocationCoordinate2D(latitude: view.annotation.coordinate.latitude, longitude: view.annotation.coordinate.longitude), animated: true)
        selectedName = view.annotation.title
        showDetial.toggle()
    }
    
    /**点击list**/
    func setMapCenter(_ poi: POIModel) {
        if !isDetial{
            mapView.setZoomLevel(15, animated: true)
            mapView.setCenter(CLLocationCoordinate2D(latitude: poi.latitude!, longitude: poi.longitude!), animated: true)
            
            selectedName = poi.name
        }
        
        print(self.mapView.annotations.count)
        let selectedAnnotation = (self.mapView.annotations as! [MAPointAnnotation])
            .first(where: { $0.title == poi.name })
        self.mapView.selectAnnotation(selectedAnnotation, animated: true)
    }
    
    /**回调是否显示标记等信息（画图标）**/
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as! MAPinAnnotationView?
            
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            if mapView.zoomLevel > zoomLevel {
                let title = ((annotation.title ?? "") as String)
                if title.contains(options[1]){
                    annotationView!.image = UIImage(named: "mcdonalds")
                } else if title.contains(options[2]) || title.contains("STAR"){
                    annotationView!.image = UIImage(named: "starbucks")
                } else if title.contains(options[3]) || title.contains("酒店") {
                    annotationView!.image = UIImage(named: "hilton")
                } else {
                    annotationView!.image = UIImage(named: "map")
                }
                
                //设置中心点偏移，使得标注底部中间点成为经纬度对应点
                annotationView!.centerOffset = CGPoint(x: 0, y: -18);
                annotationView!.bounds.size = CGSize(width: 30, height: 30)
                for subview in annotationView!.subviews {
                    if let label = subview as? UILabel {
                        label.removeFromSuperview()
                    }
                    
                    view.backgroundColor = UIColor(.clear)
                    
                }
            } else {
                //大地图
                let label = UILabel(frame: CGRect(x: 10, y: 40, width: 25, height: 25))
                label.text = annotation.subtitle
                label.textColor = UIColor.white
                label.font = UIFont.systemFont(ofSize: 14)
                label.textAlignment = .center
                
                let circleView = UIView(frame: CGRect(x: label.frame.origin.x, y: label.frame.origin.y, width: label.frame.size.width, height: label.frame.size.height))
                
                //                if defaultName == options[1] {
                //                    annotationView!.image = UIImage(named: "mcdonalds")
                //                    circleView.backgroundColor = UIColor.yellow
                //                } else if defaultName == options[2] {
                //                    annotationView!.image = UIImage(named: "starbucks")
                //                    circleView.backgroundColor = UIColor.green
                //                } else if defaultName == options[3] {
                //                    annotationView!.image = UIImage(named: "hilton")
                //                    circleView.backgroundColor = UIColor.blue
                //                } else {
                //                    annotationView!.image = UIImage(named: "map")
                //                    circleView.backgroundColor = UIColor.red
                //                }
                
                let originalImage = UIImage(named: "map") // 获取原始图片
                let imageSize = CGSize(width: 0, height: 0) // 设置新图片的大小
                let renderer = UIGraphicsImageRenderer(size: imageSize) // 创建一个图像渲染器
                let newImage = renderer.image { context in
                    originalImage?.withRenderingMode(.alwaysOriginal).draw(in: CGRect(origin: .zero, size: imageSize)) // 在图像上绘制原始图片并调整大小
                }
                
                annotationView!.image = newImage
                
                annotationView!.centerOffset = CGPoint(x: 0, y: -18);
                annotationView!.bounds.size = CGSize(width: 40, height: 40)
                
                
                circleView.layer.cornerRadius = (label.frame.size.width) / 2.0
                circleView.backgroundColor = UIColor.red
                annotationView!.addSubview(label)
                annotationView!.insertSubview(circleView, belowSubview: label)
            }
            
            let button: SubclassedUIButton = SubclassedUIButton(type: UIButton.ButtonType.detailDisclosure)
            
            button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
            button.title = annotation.title!
            
            annotationView!.canShowCallout = isDetial
            annotationView!.animatesDrop = false
            annotationView!.isDraggable = false
            annotationView!.rightCalloutAccessoryView = button
            
            return annotationView!
        }
        
        return nil
    }
    
    /**
     1. 将自己的位置信息图片至为空
     2. 触发第一次的搜索
     **/
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if let annotationView = mapView.view(for: userLocation) {
            annotationView.image = UIImage(named: "map")
            if isFirstData {
                selectedSearchContent()
                isFirstData = false
            }
        }
    }
    
    /**点击弹出框的信息按钮**/
    @objc func tapped(sender: SubclassedUIButton) {
        if isLocalUser { return }
        tapInfo.toggle()
    }
    
    class SubclassedUIButton: UIButton {
        var title: String?
    }
    
    /**地图停止滑动时触发**/
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        //地图停止滑动调用
        if wasUserAction {
            print("停止滑动")
            if mapView.annotations.count > 80 {
                setClear()
            }
            contentTypes = []
            selectedSearchContent()
        }
    }
    
    /**判断是移动还是缩放地图**/
    func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool) {
        if previousZoomLevel == mapView.zoomLevel {
            // 如果当前地图的zoomLevel和之前地图的zoomLevel相等，那么判断当前操作是移动地图
            if let previousRegion = previousRegion, previousRegion.center.latitude != mapView.region.center.latitude || previousRegion.center.longitude != mapView.region.center.longitude || previousRegion.span.latitudeDelta != mapView.region.span.latitudeDelta || previousRegion.span.longitudeDelta != mapView.region.span.longitudeDelta {
            }
        } else {
            // 如果当前地图的zoomLevel和之前地图的zoomLevel不相等，那么判断当前操作是缩放地图
            print("当前缩放级别：\(mapView.zoomLevel)")
            if mapView.zoomLevel < zoomLevel {
                if isDetial{
                    print("缩小到城市")
                    setClear()
                    isDetial = false
                    setCitiesAnno()
                    showCities = true
                }
            } else {
                if !isDetial {
                    print("放大到具体-----重新画图")
                    setClear()
                    isDetial = true
                    selectedSearchContent()
                    showCities = false
                }
            }
        }
        // 更新previousZoomLevel和previousRegion
        previousZoomLevel = mapView.zoomLevel
        previousRegion = mapView.region
    }
    
    /**添加城市标记**/
    func setCitiesAnno() {
        for city in citiesCenterList {
            var count = 0
            if defaultName == options[0] {
                count = city.starbucks! + city.mcdonalds! + city.hilton!
            } else if defaultName == options[1] {
                count = city.mcdonalds!
            } else if defaultName == options[2] {
                count = city.starbucks!
            } else if defaultName == options[3] {
                count = city.hilton!
            }
            let pointAnnotation = MAPointAnnotation()
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: city.latitude!, longitude: city.longitude!)
            pointAnnotation.title = city.city
            pointAnnotation.subtitle = String(count)
            mapView!.addAnnotation(pointAnnotation)
        }
    }
    
    /**切换搜索项目**/
    func selectedSearchContent() {
        if mapView == nil { return }
        if mapView.zoomLevel > zoomLevel {
            if defaultName == "全部" {
                for option in options {
                    if option == "全部" { continue }
                    searchPlace(place: option, currentCoordinate: mapView.centerCoordinate, isZoomOut: true)
                }
            } else {
                searchPlace(place: defaultName, currentCoordinate: mapView.centerCoordinate, isZoomOut: true)
            }
        }
    }
    
    func setClear() {
        mapView.removeAnnotations(mapView.annotations)
        poiDataList = []
        if mapView.zoomLevel < zoomLevel {
            contentTypes = []
        }
    }
}
