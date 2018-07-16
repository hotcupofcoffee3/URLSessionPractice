//
//  UnsplashModel.swift
//  URLSessionPractice
//
//  Created by Adam Moore on 7/14/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UnsplashModel {
    
    
    
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
    
    var unsplashImages = [UnsplashImages]()
    
//    let arrayOfKeyWords = ["clouds", "rain", "snow", "storm", "sunny"]
    
    let arrayOfKeyWords = ["clouds", "rain"]
    
    
    
    // MARK: - API Call
    
    let api = API()
    
    func getAndSaveImage(keyword: String) {
        
        let query = keyword.replacingOccurrences(of: " ", with: "%20")
        
        let url = URL(string: "https://api.unsplash.com/photos/random?client_id=\(api.unsplashClientID)&page=1&query=\(query)")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
                
                print(error!)
                
            } else {
                
                if let urlContent = data {
                    
                    do {
                        
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
                        let urls = jsonResult["urls"] as? [String: String]
                        
                        if let urls = urls {
                            
                            if let fullURL = urls["full"] {
                                
                                DispatchQueue.main.async {
                                    
                                    self.saveUnsplashImage(keyword: keyword, urlString: fullURL)
                                    
                                }
                                
                                
                            }
                            
                        }
                        
                        
                    } catch {
                        
                        print("JSON Processing Error.")
                        
                    }
                    
                }
                
            }
            
        }
        
        task.resume()
        
    }
    
    
    
    // MARK: - Save Images
    
    func saveUnsplashImage(keyword: String, urlString: String) {
        
        let imageURL = URL(string: urlString)
        
        var imageData = Data()
        
        do {
            
            imageData = try Data(contentsOf: imageURL!)
            
        } catch {
            
            print(error)
            
        }
        
        let unsplash = UnsplashImages(context: context)
        
        unsplash.keyword = keyword
        unsplash.imageData = imageData
        
        saveData()
        
    }
    
    func downloadAndSaveAllImages() {
        
        for keyword in arrayOfKeyWords {
            
            getAndSaveImage(keyword: keyword)
            
        }
        
        DispatchQueue.main.async {
            
            self.loadUnsplashImages()
            
            for image in self.unsplashImages {
                
                print("\(image.keyword!): \(image.imageData!)")
                
            }
        }
        
    }
    
    
    
    // MARK: - Load Images
    
    func loadUnsplashImages() {
        
        let request: NSFetchRequest<UnsplashImages> = UnsplashImages.fetchRequest()
        
        do {
            
            unsplashImages = try context.fetch(request)
            
        } catch {
            
            print("Could not load Unsplash images: \(error)")
            
        }
        
    }
    
    init() {
        
        loadUnsplashImages()
        
    }
    
    
    
    // MARK: - Returns
    
    func returnImageFromSavedData(imageData: Data) -> UIImage {
        
        let imageItself = UIImage(data: imageData)
        
        return imageItself!
        
    }
    
    func returnMonth() -> Int {
        
        let date = Date()
        
        let calendar = Calendar.current
        
        let month = calendar.component(.month, from: date)
        
        return month
        
    }
    
}














