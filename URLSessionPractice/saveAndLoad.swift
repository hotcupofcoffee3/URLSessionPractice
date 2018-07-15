//
//  saveAndLoad.swift
//  URLSessionPractice
//
//  Created by Adam Moore on 7/14/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SaveAndLoad {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var weatherDetails = [WeatherDetails]()
    
    var unsplashImages = [UnsplashImages]()
    
    func saveData() {
        
        do {
            
            try context.save()
            
        } catch {
            
            print("Error saving data: \(error)")
            
        }
        
    }
    
    func addUnsplashImages(clouds: Data, rain: Data, snow: Data, storm: Data, sunny: Data) {
        
        let unsplash = UnsplashImages(context: context)
        
        unsplash.clouds = clouds
        unsplash.rain = rain
        unsplash.snow = snow
        unsplash.storm = storm
        unsplash.sunny = sunny
        
        saveData()
        
    }
    
    init() {
        
        loadWeatherData()
        
    }
    
    func loadWeatherData() {
        
        let request: NSFetchRequest<WeatherDetails> = WeatherDetails.fetchRequest()
        
        do {
            
            weatherDetails = try context.fetch(request)
            
        } catch {
            
            print("Could not load Weather Data: \(error)")
            
        }
        
    }
    
    func saveCity(city: String) {
        
        if !weatherDetails.isEmpty {
            
            weatherDetails[0].city = city
            
            saveData()
            
        }
        
    }
    
    func saveIconNumber(iconNumber: String) {
        
        if !weatherDetails.isEmpty {
            
            weatherDetails[0].iconNumber = iconNumber
            
            saveData()
            
        }
        
    }
    
    func saveTemperature(temperature: Double) {
        
        if !weatherDetails.isEmpty {
            
            weatherDetails[0].temperature = temperature
            
            saveData()
            
        }
        
    }
    
    func saveUVIndex(uvIndex: Double) {
        
        if !weatherDetails.isEmpty {
            
            weatherDetails[0].uvIndex = uvIndex
            
            saveData()
            
        }
        
    }
    
    func loadUnsplashImage() {
        
        let request: NSFetchRequest<UnsplashImages> = UnsplashImages.fetchRequest()
        
        do {
            
            unsplashImages = try context.fetch(request)
            
        } catch {
            
            print("Could not load Unsplash images: \(error)")
            
        }
        
    }
    
    func getMonth() -> Int {
        
        let date = Date()
        
        let calendar = Calendar.current
        
        let month = calendar.component(.month, from: date)
        
        print(month)
        
        return month
        
    }
    
}





