//
//  WeatherModel.swift
//  URLSessionPractice
//
//  Created by Adam Moore on 7/16/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class WeatherModel {
    
    
    
    // MARK: - Context and Save
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveData() {
        
        do {
            
            try context.save()
            
        } catch {
            
            print("Error saving data: \(error)")
            
        }
        
    }
    
    
    
    // MARK: - Variables
    
    var weatherDetails = [WeatherDetails]()
    
    
    
    // MARK: - API Call
    
    let api = API()
    
    
    
    // MARK: - Save Weather
    
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
    
    
    
    // MARK: - Load Weather
    
    func loadWeatherData() {
        
        let request: NSFetchRequest<WeatherDetails> = WeatherDetails.fetchRequest()
        
        do {
            
            weatherDetails = try context.fetch(request)
            
        } catch {
            
            print("Could not load Weather Data: \(error)")
            
        }
        
    }
    
    init() {
        
        loadWeatherData()
        
    }
    
}
