//
//  SingleMapTableViewController.swift
//  BusanPark
//
//  Created by D7702_10 on 2017. 12. 19..
//  Copyright © 2017년 Jang Gyu Sik. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SingleMapTableViewController: UITableViewController, CLLocationManagerDelegate{
    
    var sItem:[String:String] = [:]
    var sItems:[[String:String]] = []
    var sParkName: String?
    var sLat: Double?
    var sLong: Double?
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var tel: UITableViewCell!
    @IBOutlet weak var facilityConvenience: UITableViewCell!
    @IBOutlet weak var facilityCulture: UITableViewCell!
    @IBOutlet weak var facilityEct: UITableViewCell!
    @IBOutlet weak var facilityExercise: UITableViewCell!
    @IBOutlet weak var facilityPlay: UITableViewCell!
    @IBOutlet weak var instName: UITableViewCell!
    
    
    @IBOutlet weak var singleMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 현재 위치 트랙킹
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        self.title = sParkName
        
        // 전체 items 배열에서 loc 값과 같은 item 뽑기
        for item in sItems {
            if item["parkName"] == sParkName {
                sItem = item
                print("sItem = \(sItem)")
            }
        }
        
        
        sLat = (sItem["latitude"]! as NSString).doubleValue
        sLong = (sItem["longitude"]! as NSString).doubleValue
        
        let sPark = sItem["parkName"]
        let sAddr = sItem["addrJibun"]
        
        zoomToRegion()
        
        let anno = MKPointAnnotation()
        anno.coordinate.latitude = sLat!
        anno.coordinate.longitude = sLong!
        anno.title = sPark
        anno.subtitle = sAddr
        
        singleMapView.addAnnotation(anno)
        singleMapView.selectAnnotation(anno, animated: true)
        
        tel.textLabel?.text = "연락처"
        tel.detailTextLabel?.text = sItem["tel"]
        facilityConvenience.textLabel?.text = "공원보유 편익시설 "
        facilityConvenience.detailTextLabel?.text = sItem["facilityConvenience"]
        facilityCulture.textLabel?.text = "공원보유 교양시설"
        facilityCulture.detailTextLabel?.text = sItem["facilityCulture"]
        facilityEct.textLabel?.text = "공원보유 기타시설"
        facilityEct.detailTextLabel?.text = sItem["facilityEct"]
        facilityExercise.textLabel?.text = "공원보유 운동시설"
        facilityExercise.detailTextLabel?.text = sItem["facilityExercise"]
        facilityPlay.textLabel?.text = "공원보유 유희시설"
        facilityPlay.detailTextLabel?.text = sItem["facilityPlay"]
        instName.textLabel?.text = "관리기관명"
        instName.detailTextLabel?.text = sItem["instName"]
        
        if tel.detailTextLabel?.text == nil{
            tel.detailTextLabel?.text = "없음"
        }
        if facilityConvenience.detailTextLabel?.text == nil{
            facilityConvenience.detailTextLabel?.text = "없음"
        }
        if facilityCulture.detailTextLabel?.text == nil{
            facilityCulture.detailTextLabel?.text = "없음"
        }
        if facilityEct.detailTextLabel?.text == nil{
            facilityEct.detailTextLabel?.text = "없음"
        }
        if facilityExercise.detailTextLabel?.text == nil{
            facilityExercise.detailTextLabel?.text = "없음"
        }
        if facilityPlay.detailTextLabel?.text == nil{
            facilityPlay.detailTextLabel?.text = "없음"
        }
        if instName.detailTextLabel?.text == nil{
            instName.detailTextLabel?.text = "없음"
        }
    }
    
    func zoomToRegion() {
        // 35.162685, 129.064238
        let center = CLLocationCoordinate2DMake(sLat!, sLong!)
        let span = MKCoordinateSpanMake(0.4, 0.4)
        let region = MKCoordinateRegionMake(center, span)
        singleMapView.setRegion(region, animated: true)
    }
    
    @IBAction func launchMap(_ sender: Any) {
        sLat = locationManager.location?.coordinate.latitude
        sLong = locationManager.location?.coordinate.longitude
        
        let regionDistance:CLLocationDistance = 1000;
        let coordinates = CLLocationCoordinate2DMake(sLat!, sLong!)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = sParkName
        mapItem.openInMaps(launchOptions: options)
        
    }
}

