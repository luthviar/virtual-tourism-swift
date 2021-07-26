//
//  AppClient.swift
//  VirtualTourism
//
//  Created by Luthfi Abdurrahim on 26/07/21.
//

import Foundation
import Alamofire
import Kingfisher

class AppClient {
    struct Constants {
        static let API_KEY = "3d95fc71ac793d524c144129b1bc2a42"
        static let API_SECRET = "aa4ce837fefa10c8"
        static let BASE_URL = "https://api.flickr.com/services/rest"
        static let FLICKR_SEARCH_METHOD = "flickr.photos.search"
        static let ACCURACY = 11
        static let NUM_OF_PHOTOS = 40
    }
    
    static func getListOfPhotosIn(lat: Double, lon: Double, totalPages: Int = 0, completionHandler: @escaping (Connectivity.Status, [String]?, Int) -> Void) {
        let url = "\(Constants.BASE_URL)?api_key=\(Constants.API_KEY)&method=\(Constants.FLICKR_SEARCH_METHOD)&per_page=\(Constants.NUM_OF_PHOTOS)&format=json&nojsoncallback=?&lat=\(lat)&lon=\(lon)&page=\((0...totalPages).randomElement() ?? 1)"
                
        if !Connectivity.isConnectedToInternet {
            completionHandler(.notConnected, nil, 0)
        }
        
        AF.request(url).responseJSON { (response) in
            let jsonResponse = try! JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [String: Any]                        
            let photos = jsonResponse!["photos"] as! [String: Any]
            let totalPages = photos["pages"] as! Int
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
            
            completionHandler(.connected, photosURL, totalPages)
       
        }
    }
    
    static func handleImageDataResponse(cell: PhotoCell, url: URL, completion: @escaping (UIImage?, Error?) -> Void) {        
        cell.imageView.kf.setImage(with: url, placeholder: UIImage(named: "Placeholder"), options: nil, progressBlock: nil) { (img, err, cacheType, url) in
            guard err != nil else {
                completion(nil,err)
                return
            }
            guard let img = img else {
                completion(nil,err)
                return
            }
            completion(img,nil)
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
