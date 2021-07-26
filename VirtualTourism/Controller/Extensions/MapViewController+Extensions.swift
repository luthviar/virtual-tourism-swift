//
//  MapViewController+Extensions.swift
//  VirtualTourism
//
//  Created by Luthfi Abdurrahim on 26/07/21.
//

import UIKit
import MapKit
import CoreData

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKCircle.self) {
            let view = MKCircleRenderer(overlay: overlay)
            view.fillColor = UIColor.black.withAlphaComponent(0.2)
            return view
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation! , animated: true)
        let pin: Pin = view.annotation as! Pin
        let photosListVC = storyboard?.instantiateViewController(withIdentifier: "PhotosAlbumViewController") as! PhotosAlbumViewController;
        
        photosListVC.pin = pin
        photosListVC.dataController = dataController
        
        navigationController?.pushViewController(photosListVC, animated: true)
    }
}

extension MapViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let pin = anObject as? Pin else {
            preconditionFailure("THIS IS NOT A PIN!")
        }
        switch type {
        case .insert:
            mapView.addAnnotation(pin)
            break
        default: ()
        }
    }
}
