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
    
    func addWeatherData(city: String, iconNumber: String, temperature: Double, uvIndex: Double) {
        
        let weatherData = WeatherDetails(context: context)
        
        weatherData.city = city
        weatherData.iconNumber = iconNumber
        weatherData.temperature = temperature
        weatherData.uvIndex = uvIndex
        
        saveData()
        
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
    
    func loadWeatherData() {
        
        let request: NSFetchRequest<WeatherDetails> = WeatherDetails.fetchRequest()
        
        do {
            
            weatherDetails = try context.fetch(request)
            
        } catch {
            
            print("Could not load Weather Data: \(error)")
            
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
    
}
