//
//  ViewController.swift
//  URLSessionPractice
//
//  Created by Adam Moore on 6/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var weatherIcon: UIImageView!
    
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var zipTextField: UITextField!
    
    @IBAction func getTempButton(_ sender: UIButton) {
        
        if let zip = Int(zipTextField.text!) {
            
            getTempAndUVIndexFromZip(zip: zip)
            
        }
        
        zipTextField.text = ""
        
    }
    
    var city = String()
    
    var temperature = Double()
    
    var uvIndex = Double()
    
    var iconForPngDisplay = String()
    
    var weatherDescription = String()
    
    let apiKeys = API()
    
    let unsplashAPI = UnsplashAPICall()
    
    
    
    
    func getTempAndUVIndexFromZip(zip: Int) {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(String(zip)) { (cLLocations, error) in
            
            if error != nil {
                
                print(error!)
                
            } else {
                
                if let locations = cLLocations {
                    
                    for cLLocation in locations {
                        
                        if let location = cLLocation.location {
                            
//                            print("Lat: \(location.coordinate.latitude)")
//
//                            print("Lon: \(location.coordinate.longitude)")
                            
                            self.getUVIndexFromLatAndLon(zip: zip, lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func getUVIndexFromLatAndLon(zip: Int, lat: Double, lon: Double) {
        
//        print(lat)
        
//        print(lon)
        
        let url = URL(string: "http://api.openweathermap.org/data/2.5/uvi?appid=\(apiKeys.openWeatherMapAPIKey)&lat=\(lat)&lon=\(lon)")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
                print(error!)
            } else {
                
                if let urlContent = data {
                    
                    do {
                        
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
//                        print(jsonResult)
                        
//                        print(jsonResult["value"])
                        
                        if let uv = jsonResult["value"] as? Double {

                            self.uvIndex = uv
                            
                        } else {
                            
                            self.uvIndex = 0.0
                            
                        }
                        
//                        print(uvIndexReturned)
                        
//                        print(jsonResult["main"])
                        
                        DispatchQueue.main.async {
                            
                            self.getCurrentTemperature(zipCode: zip)
                            
                        }
                        
                    } catch {
                        
                        print("JSON Processing Error.")
                        
                    }
                    
                }
                
            }
            
        }
        
        task.resume()
        
    }
    
    func getCurrentTemperature(zipCode: Int) {
        
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?zip=\(String(zipCode)),us&appid=\(apiKeys.openWeatherMapAPIKey)")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
                print(error!)
            } else {
                
                if let urlContent = data {
                    
                    do {
                        
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
//                        print(jsonResult)
                        
//                        print(jsonResult["name"])
                        
                        if let city = jsonResult["name"] as? String {
                            
                            self.city = city
                            
                        }
                        
                        if let weatherDict = jsonResult["weather"] as? [[String: Any]] {
                            
//                            print(weatherDict)
                            
                            if let icon = weatherDict[0]["icon"] as? String {
                                
//                                print(icon)
                                
                                self.iconForPngDisplay = icon
                                
                            }
                            
                            if let weatherDesc = weatherDict[0]["description"] as? String {
                                
                                print(weatherDesc)
                                
                                self.weatherDescription = weatherDesc
                                
                            }
                            
                        }
                        
//                        print(jsonResult["main"])
                        
                        if let main = jsonResult["main"] as? [String: Any] {
                            
                            if let temp = main["temp"] as? Double {
                                
                                self.temperature = (Double(temp) - 273.15)
                                
                            }
                            
                        }

//                        print(self.temperature)

                        DispatchQueue.main.async {

                            self.tempLabel.text = "\(self.city):\n\(String(self.temperature))°C\nUV: \(self.uvIndex)"
                            
                            let imageURL = URL(string: "http://openweathermap.org/img/w/\(self.iconForPngDisplay).png")

                            let imageData = try! Data(contentsOf: imageURL!)

                            self.weatherIcon.image = UIImage(data: imageData)
                            
                            self.unsplashAPI.getAndSetImage(descriptionQuery: self.weatherDescription, image: self.image)

                        }
                        
                    } catch {
                        
                        print("JSON Processing Error.")
                        
                    }
                    
                }
                
            }
            
        }
        task.resume()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tempLabel.text = ""
     
//        let url = URL(string: "https://api.unsplash.com/photos/random?client_id=\(apiKeys.unsplashClientID)&page=1&query=overcast%20clouds")
//
//        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
//
//            if error != nil {
//                print(error!)
//            } else {
//
//                if let urlContent = data {
//
//                    do {
//
//                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
//
////                        print(jsonResult)
//
////                        print(jsonResult["urls"])
//
//                        let urls = jsonResult["urls"] as? [String: String]
//
////                        print(urls)
//                        if let urls = urls {
//
//                            if let fullURL = urls["full"] {
//
////                                print(fullURL)
//
//                                DispatchQueue.main.async {
//
//                                    let imageURL = URL(string: fullURL)
//
//                                    let imageData = try! Data(contentsOf: imageURL!)
//
//                                    self.image.image = UIImage(data: imageData)
//
//                                }
//
//
//                            }
//
//                        }
//
//
//                    } catch {
//
//                        print("JSON Processing Error.")
//
//                    }
//
//                }
//
//            }
//
//        }
//        task.resume()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

