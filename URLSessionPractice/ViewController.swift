//
//  ViewController.swift
//  URLSessionPractice
//
//  Created by Adam Moore on 6/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var weatherIcon: UIImageView!
    
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var zipTextField: UITextField!
    
    @IBOutlet weak var goButton: UIButton!
    
    func getWeatherAndImage(zipCode: String) {
        
        if let zip = Int(zipCode) {
            
            getTempAndUVIndexFromZip(zip: zip)
            
        }
        
        zipTextField.text = ""
        
    }
    
    @IBAction func getTempButton(_ sender: UIButton) {
        
        getWeatherAndImage(zipCode: zipTextField.text!)
        
    }
    
    var city = String()
    
    var temperature = Double()
    
    var uvIndex = Double()
    
    var iconForPngDisplay = String()
    
    var weatherDescription = String()
    
    let weatherModel = WeatherModel()
    
    let unsplashModel = UnsplashModel()
    
    let apiKeys = API()
    
    func getTempAndUVIndexFromZip(zip: Int) {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(String(zip)) { (cLLocations, error) in
            
            if error != nil {
                
                print(error!)
                
                self.tempLabel.text = "Invalid ZIP"
                
                
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
                            
                            self.weatherModel.saveUVIndex(uvIndex: self.uvIndex)
                            
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
                                
//                                print(weatherDesc)
                                
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
                            
                            self.weatherModel.saveCity(city: self.city)
                            
                            self.weatherModel.saveIconNumber(iconNumber: self.iconForPngDisplay)
                            
                            self.weatherModel.saveTemperature(temperature: self.temperature)
                            
                            self.updateUI(city: self.city, iconForPngDisplay: self.iconForPngDisplay, temperature: self.temperature)
                            
//                            self.unsplashAPI.getAndSetImage(descriptionQuery: self.weatherDescription, image: self.image)

                        }
                        
                    } catch {
                        
                        print("JSON Processing Error.")
                        
                    }
                    
                }
                
            }
            
        }
        task.resume()
        
    }
    
    func updateUI(city: String, iconForPngDisplay: String, temperature: Double) {
        
        tempLabel.text = "\(city):\n\(String(format: "%0.1f", temperature)) °C"
        
        let imageURL = URL(string: "http://openweathermap.org/img/w/\(iconForPngDisplay).png")
        
        let imageData = try! Data(contentsOf: imageURL!)
        
        weatherIcon.image = UIImage(data: imageData)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unsplashModel.downloadAndSaveAllImages()
        
        if UserDefaults.standard.object(forKey: "month") == nil {
            
            let month = unsplashModel.returnMonth()
            
            UserDefaults.standard.set(month, forKey: "month")
            
        } else {
            
            let setMonth = UserDefaults.standard.object(forKey: "month") as! Int
            
            let currentMonth = unsplashModel.returnMonth()
            
            if setMonth != currentMonth {
                
                UserDefaults.standard.set(currentMonth, forKey: "month")
                
                // Download new images to save
                // Save new images
                // Load these new images
                
            } else {
                
                // Load saved images
                
            }
            
        }
        
        if UserDefaults.standard.object(forKey: "weatherInfo") == nil {
            
            UserDefaults.standard.set(true, forKey: "weatherInfo")
            
            let initialWeatherDataSetup = WeatherDetails(context: weatherModel.context)
            
            initialWeatherDataSetup.city = ""
            initialWeatherDataSetup.iconNumber = ""
            initialWeatherDataSetup.temperature = 0.0
            
            weatherModel.saveData()
            
        } else {
            
            if !weatherModel.weatherDetails.isEmpty {
                
                let city = weatherModel.weatherDetails[0].city!
                let iconNumber = weatherModel.weatherDetails[0].iconNumber!
                let temperature = weatherModel.weatherDetails[0].temperature
//                let uvIndex = saveAndLoad.weatherDetails[0].uvIndex
                
                updateUI(city: city, iconForPngDisplay: iconNumber, temperature: temperature)
                
//                print(saveAndLoad.weatherDetails[0].city!)
//                print(saveAndLoad.weatherDetails[0].iconNumber!)
//                print(saveAndLoad.weatherDetails[0].temperature)
//                print(saveAndLoad.weatherDetails[0].uvIndex)
                
            }
            
        }
        
        
        

        
        
        // Image as Data and vice versa
        
//        let imageToBeData: UIImage = UIImage(named: "imageForData.png")!
        
//        let imageData: Data = UIImagePNGRepresentation(imageToBeData)!
        
//        print(imageData)
        
        
        
        
        
//        tempLabel.text = ""
        
        self.zipTextField.delegate = self
        
        self.goButton.layer.cornerRadius = 6
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.zipTextField.resignFirstResponder()
        self.getWeatherAndImage(zipCode: zipTextField.text!)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.zipTextField.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

