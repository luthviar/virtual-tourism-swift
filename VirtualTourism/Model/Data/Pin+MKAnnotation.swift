//
//  Pin+MKAnnotation.swift
//  VirtualTourism
//
//  Created by Luthfi Abdurrahim on 26/07/21.
//

import Foundation
import MapKit

extension Pin: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longitude)
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
}
