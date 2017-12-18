//
//  TotalMapViewController.swift
//  BusanPark
//
//  Created by D7702_10 on 2017. 12. 19..
//  Copyright © 2017년 Jang Gyu Sik. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TotalMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, XMLParserDelegate{
    
    @IBOutlet weak var totalMapView: MKMapView!
    @IBOutlet weak var segControl: UISegmentedControl!
    
    var locationManager: CLLocationManager!
    
    var viewTitle: String?
    var curLat: Double?
    var curLong: Double?
    
    var item:[String:String] = [:]
    var items:[[String:String]] = []
    var key = ""
    //    var servieKey = "nsGYsnRIMYDW2RwmA8hMBTGFXYN6LyB4rJC71IIGNVGIplpzE3iahHPLqCU4BnTjhOGT4b%2FgbTLg3vfGFtIffQ%3D%3D"
    var servieKey = "XRcD2BtScfry3R19eGO%2FNR7cx9DTbKu4EOQjZiaDgTC48fA6Y1R7unCSNHsnKVzpSjVPfYtXFuzwEPclYn0Rew%3D%3D"
    var listEndPoint = "http://opendata.busan.go.kr/openapi/service/CityPark/getCityParkInfoList"
    let detailEndPoint = "http://opendata.busan.go.kr/openapi/service/CityPark/getCityParkInfoDetail"
    var totalCount = 0 //총 갯수를 저장하는 변수

    override func viewDidLoad() {
        super.viewDidLoad()
        totalMapView.delegate = self
        // Do any additional setup after loading the view.
        
        let path = Bundle.main.path(forResource: "data", ofType: "plist")
        items = NSArray(contentsOfFile: path!) as! [[String : String]]
        
        
//        let fileManager = FileManager.default
//        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("data.plist")
//
//        print(url)
//
//        //        시작할때마다 TotalCount를 받아옴
//        getList(numOfRows: 0)
//
//        if fileManager.fileExists(atPath: (url?.path)!) {
//            //파일이 있으면 파일에서 읽어옴
//            items = NSArray(contentsOf: url!) as! Array
//
//            //파일에서 읽어본 갯수와 totalCount를 비교
//            if (items.count != totalCount) {
//                //파일에서 읽어본 갯수와 totalCount가 다르면(변화가 있으면) 다시 읽어와서 저장
//                getList(numOfRows: totalCount)
//                saveDetail(url: url!)
//            }
//        } else {
//            //******* 파일이 없으면
//            getList(numOfRows: totalCount)
//            saveDetail(url: url!)
//        }
        
        // 현재 위치 트랙킹
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        /////////////////////////////
        curLat = locationManager.location?.coordinate.latitude
        curLong = locationManager.location?.coordinate.longitude
        
        // 지도에 현재 위치 마크를 보여줌
        totalMapView.showsUserLocation = true
        
        self.title = "부산 공원 지도"
        zoomToRegion()
        
        //print("tItems = \(tItems)")
        // lat, lng
        var annos = [MKPointAnnotation]()
        
        for item in items {
            let anno = MKPointAnnotation()
            
            let name = item["parkName"]
            
            
            if name == "동양어린이공원"{
                let lat = 35.1761836
                let long = 129.0299758
                anno.coordinate.latitude = lat
                anno.coordinate.longitude = long
                anno.title = item["parkName"]
                anno.subtitle = item["addrJibun"]
                
                annos.append(anno)
                
            } else if name == "은하수어린이공원"{
                let lat = 35.1746046
                let long = 129.0315324
                anno.coordinate.latitude = lat
                anno.coordinate.longitude = long
                anno.title = item["parkName"]
                anno.subtitle = item["addrJibun"]
                
                annos.append(anno)
                
            }else if name == "굿거리언덕공원"{
                let lat = 35.198900
                let long = 129.207662
                anno.coordinate.latitude = lat
                anno.coordinate.longitude = long
                anno.title = item["parkName"]
                anno.subtitle = item["addrJibun"]
                
                annos.append(anno)
                
            }else {
                let lat = item["latitude"]
                let long = item["longitude"]
                let fLat = (lat! as NSString).doubleValue
                let fLong = (long! as NSString).doubleValue
                
                anno.coordinate.latitude = fLat
                anno.coordinate.longitude = fLong
                anno.title = item["parkName"]
                anno.subtitle = item["addrJibun"]
                
                annos.append(anno)
                
            }
            
        }
        totalMapView.showAnnotations(annos, animated: true)
        totalMapView.addAnnotations(annos)
        //totalMapView.selectAnnotation(annos[0], animated: true)
      
        
        
    }
    
    func getList(numOfRows:Int) { //numOfRows를 입력
        //let str = detailEndPoint + "?serviceKey=\(servieKey)&numsofRows=20"
        let str = listEndPoint + "?serviceKey=\(servieKey)&numOfRows=\(numOfRows)"
        print(str)
        
        if let url = URL(string: str) {
            if let parser = XMLParser(contentsOf: url) {
                
                parser.delegate = self
                let success = parser.parse()
                if success {
                    print("parse success in getList")
                    print("totalCount = \(totalCount)")
                    
                } else {
                    print("parse failed in hetList")
                }
            }
        }
    }
    
    func getDetail(managementNum: String) {
        let str = detailEndPoint + "?serviceKey=\(servieKey)&managementNum=\(managementNum)"
        
        if let url = URL(string: str) {
            if let parser = XMLParser(contentsOf: url) {
                parser.delegate = self
                let success = parser.parse()
                if success {
                    print("parse success in getDetail")
                    //print(items)
                    
                } else {
                    print("parse fail in getDeatil")
                }
            }
        }
    }
    
    //*******새로 추가된 함수 - 목록데이터를 가지고 상세데이터를 가져와서 저장하는 함수
    // Detail Data 가져오는 부분을 saveDetail 메소드로 extract
    func saveDetail(url:URL) {
        
        // "loc" key로 items를 sort
        let sortedItems = items.sorted{($1["managementNum"])! > ($0["managementNum"])!}
        let tempItems = sortedItems  // tableView에서 재활용
        //print("items = \(items)")
        
        items = []
        
        //-----------------thread controll----------------------
        //-------DispatchQueue선언(멀티 thread)-------------------
        //qos 속성에 따라 우선순위 변경
        let equeue = DispatchQueue(label:"com.yangsoo.queue", qos:DispatchQoS.userInitiated)
        //-------xml parxer(background thread사용)---------------
        equeue.async {
            for dic in tempItems {
                // 상세 목록 파싱
                self.getDetail(managementNum: dic["managementNum"]!)
                //-------tableview(main thread사용(ui는 main thread 사용 필수))---
                DispatchQueue.main.async {
//                    self.myTableView.reloadData()
                    let temp = self.items as NSArray  // NSArry는 화일로 저장하기 위함
                    temp.write(to: url, atomically: true)
                }
            }
            
        }
        //-----------------thread controll------------------------
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        //key = elementName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        key = elementName
        if key == "item" {
            item = [:]
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        // foundCharacters가 두번 호출
        if item[key] == nil {
            item[key] = string.trimmingCharacters(in: .whitespaces)
            //print("item(\(key)) = \(item[key])")
            
            //*******key가 totalCount 이면 totalCount 변수에 저장
            if key == "totalCount" {
                totalCount = Int(string.trimmingCharacters(in: .whitespaces))!
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            items.append(item)
        }
    }
    func zoomToRegion() {
        
        segControl.selectedSegmentIndex = 3
        // 35.199990, 129.083200
        //        curLat = locationManager.location?.coordinate.latitude
        //        curLong = locationManager.location?.coordinate.longitude
        print("curLat = \(String(describing: curLat))")
        print("curLong = \(String(describing: curLong))")
        
        let center = CLLocationCoordinate2DMake(35.230990, 129.083200)
        //let center = CLLocationCoordinate2DMake(curLat!, curLong!)
        
        let span = MKCoordinateSpanMake(0.41, 0.41)
        let region = MKCoordinateRegionMake(center, span)
        totalMapView.setRegion(region, animated: true)
    }
    
    
    @IBAction func segmentBt(_ sender: Any) {
        switch segControl.selectedSegmentIndex {
        case 0:
            let center = CLLocationCoordinate2DMake(curLat!, curLong!)
            let region = MKCoordinateRegionMakeWithDistance(center, 2000, 2000)
            totalMapView.setRegion(region, animated: true)
            
        case 1:
            let center = CLLocationCoordinate2DMake(curLat!, curLong!)
            let region = MKCoordinateRegionMakeWithDistance(center, 4000, 4000)
            totalMapView.setRegion(region, animated: true)
            
        case 2:
            let center = CLLocationCoordinate2DMake(curLat!, curLong!)
            let region = MKCoordinateRegionMakeWithDistance(center, 8000, 8000)
            totalMapView.setRegion(region, animated: true)
            
        case 3:
            let center = CLLocationCoordinate2DMake(35.230990, 129.083200)
            //let center = CLLocationCoordinate2DMake(curLat!, curLong!)
            let span = MKCoordinateSpanMake(0.41, 0.41)
            let region = MKCoordinateRegionMake(center, span)
            totalMapView.setRegion(region, animated: true)
            
        default:
            print("out of index")
        }
    }
    
 
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        //if annotation is MKUserLocation {return nil}
        if annotation .isKind(of: MKUserLocation.self) {
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            let calloutButton = UIButton(type: .detailDisclosure)
            pinView!.rightCalloutAccessoryView = calloutButton
            pinView!.sizeToFit()
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        print("callout Accessory Tapped!")
        
        let viewAnno = view.annotation
        viewTitle = ((viewAnno?.title)!)!
        print("공원이름 = \(viewTitle)")
        
        if control == view.rightCalloutAccessoryView {
            self.performSegue(withIdentifier: "goSingle", sender: self)
        }
    }
    
    
    //    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "goSingle" {
            let detailVC = segue.destination as! SingleMapTableViewController
            
            detailVC.sItems = items
            detailVC.sParkName = viewTitle
            
            //            naviVC.nLat = fLat
            //            naviVC.nLong = fLong
            //            naviVC.nLoc = viewTitle
        }
    }
}
