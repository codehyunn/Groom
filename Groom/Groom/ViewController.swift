//
//  ViewController.swift
//  Groom
//
//  Created by 박서영 on 2022/12/26.
//

import UIKit
import CoreML
import Foundation
import CoreLocation


public var day: Double = 0.0
public var startTime: Double = 0.0
public var startlat: Double = 0.0
public var startlong: Double = 0.0

class Input: UIViewController, CLLocationManagerDelegate {
    
    var hour: Double = 0.0
    var min: Double = 0.0
    var startTimeString: String = "2022"
    
    @IBOutlet weak var Lat: UILabel!
    @IBOutlet weak var Long: UILabel!
    
    @IBAction func nextBtn(_ sender: Any) {
        //화면전환버튼
          guard let nextVC = self.storyboard?.instantiateViewController(identifier: "Output") else {return}
          self.present(nextVC, animated: true)
        }
    
    // 시간 가져오기
    @IBAction func TimePick(_ sender: UIDatePicker) {
        let datePickerView = sender
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd HH mm EEE"
        if startTimeString.contains("2022"){
            startTimeString = formatter.string(from: datePickerView.date)
            hour = Double(startTimeString.split(separator: " ")[3])!
            min = Double(startTimeString.split(separator: " ")[4])!
        }
        
        startTime = hour * 60 + min // 호출 시간

        
        // 요일
        if startTimeString.split(separator: " ")[5].contains("Mon"){
            day = 0
        }
        if startTimeString.split(separator: " ")[5].contains("Tue"){
            day = 1
        }
        if startTimeString.split(separator: " ")[5].contains("Wed"){
            day = 2
        }
        if startTimeString.split(separator: " ")[5].contains("Thu"){
            day = 3
        }
        if startTimeString.split(separator: " ")[5].contains("Fri"){
            day = 4
        }
        if startTimeString.split(separator: " ")[5].contains("Sat"){
            day = 5
        }
        if startTimeString.split(separator: " ")[5].contains("Sun"){
            day = 6
        }
    }
    
    // 위치 가져오기
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
           locationManager.startUpdatingLocation()
        }
        else {
            print("위치 서비스 허용 off")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        startlat = 37.58534
        startlong = 127.006417
        Lat.text = "위도 : " + String(startlat)
        Long.text = "경도 : " + String(startlong)
        /*
        if let location = locations.first {
            startlat = location.coordinate.latitude
            startlong = location.coordinate.longitude
            Lat.text = "위도 : " + String(location.coordinate.latitude)
            Long.text = "경도 : " + String(location.coordinate.longitude)
        }*/
    }
        
    // 위치 가져오기 실패
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
}

class Output: UIViewController{
    @IBOutlet weak var pred: UILabel!
    
    @IBAction func backBtn(_ sender: Any) {
      //뒤로가기
      self.dismiss(animated: true)
    }
    
    let model: receipt_to_set_time = {
        do {
            return try receipt_to_set_time(configuration: .init())
        } catch {
            print(error)
            fatalError(String(localized: "Couldn't create Model"))
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let float_array: [Double] = [startTime, startlat, startlong, day]
        func convertToMLMultiArray(from array: [Double]) -> MLMultiArray {
            let length = NSNumber(value: 4)
            
            // Define shape of array
            guard let mlMultiArray = try? MLMultiArray(shape:[1, length], dataType:MLMultiArrayDataType.float) else {
                fatalError("Unexpected runtime error. MLMultiArray")
            }
            
            // Insert elements
            for (index, element) in array.enumerated() {
                mlMultiArray[index] = NSNumber(floatLiteral: element)
            }
            
            return mlMultiArray
        }
        
        let receipt_to_set_Input = convertToMLMultiArray(from: float_array)
        
        let receipt_to_set_timeOutput = try! model.prediction(my_input_name: receipt_to_set_Input)
        
        let predTime = receipt_to_set_timeOutput.my_output_name //MLMultiArray
        
        pred.text = String(Int(round(Float(predTime[0])))) + " 분 걸릴 것으로 예상됩니다."

    }
}
