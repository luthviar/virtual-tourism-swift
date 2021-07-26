//
//  AppClient.swift
//  VirtualTourism
//
//  Created by Luthfi Abdurrahim on 26/07/21.
//

import Foundation
import Alamofire

class AppClient {
    struct Constants {
        static let API_KEY = "3d95fc71ac793d524c144129b1bc2a42"
        static let API_SECRET = "aa4ce837fefa10c8"
        static let BASE_URL = "https://api.flickr.com/services/rest"
        static let FLICKR_SEARCH_METHOD = "flickr.photos.search"
        static let ACCURACY = 11
        static let NUM_OF_PHOTOS = 40
    }
    
    static func getListOfPhotosIn(lat: Double, lon: Double, completionHandler: @escaping (Connectivity.Status, [String]?) -> Void) {
        let url = "\(Constants.BASE_URL)?api_key=\(Constants.API_KEY)&method=\(Constants.FLICKR_SEARCH_METHOD)&per_page=\(Constants.NUM_OF_PHOTOS)&format=json&nojsoncallback=?&lat=\(lat)&lon=\(lon)&page=\((1...10).randomElement() ?? 1)"
        
        if !Connectivity.isConnectedToInternet {
            completionHandler(.notConnected, nil)
        }
        
        AF.request(url).responseJSON { (response) in
            let jsonResponse = try! JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [String: Any]
            
            let photos = jsonResponse!["photos"] as! [String: Any]
            let photosPerPages = photos["photo"] as! [[String:Any]]
            
            var photosURL: [String] = []
            
            for photo in photosPerPages {
                let farm: Int = photo["farm"] as! Int
                let server = photo["server"]!
                let id = photo["id"]!
                let secret: String = photo["secret"] as! String
                let photoURL = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
                photosURL.append(photoURL)
            }
            
            completionHandler(.connected, photosURL)
       
        }
        
    }
}

class Connectivity {
    static var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    enum Status {
        case notConnected, connected, other
    }
}
