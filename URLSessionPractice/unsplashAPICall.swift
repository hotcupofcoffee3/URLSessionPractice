//
//  unsplashAPICall.swift
//  URLSessionPractice
//
//  Created by Adam Moore on 7/13/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit

class UnsplashAPICall: API {
    
    func getAndSetImage(descriptionQuery: String, image: UIImageView) {
        
        let query = descriptionQuery.replacingOccurrences(of: " ", with: "%20")
        
        let url = URL(string: "https://api.unsplash.com/photos/random?client_id=\(unsplashClientID)&page=1&query=\(query)")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
                print(error!)
            } else {
                
                if let urlContent = data {
                    
                    do {
                        
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
                        //                        print(jsonResult)
                        
                        //                        print(jsonResult["urls"])
                        
                        let urls = jsonResult["urls"] as? [String: String]
                        
                        //                        print(urls)
                        if let urls = urls {
                            
                            if let fullURL = urls["full"] {
                                
                                //                                print(fullURL)
                                
                                DispatchQueue.main.async {
                                    
                                    let imageURL = URL(string: fullURL)
                                    
                                    let imageData = try! Data(contentsOf: imageURL!)
                                    
                                    image.image = UIImage(data: imageData)
                                    
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
    
}
