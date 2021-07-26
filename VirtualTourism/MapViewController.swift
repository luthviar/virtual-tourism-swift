//
//  MapViewController.swift
//  VirtualTourism
//
//  Created by Luthfi Abdurrahim on 26/07/21.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    // MARK: UI VC
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupFetchedResultsController()
        loadMapAnnotations()
        
        // Add LongTapGesture
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        mapView.delegate = self
        mapView.addGestureRecognizer(longPressRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupFetchedResultsController()
        loadMapAnnotations()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func setupView() {
        view.backgroundColor = UIColor.black
        navigationController?.navigationBar.barStyle = .black
        
        let mapRadius = CLLocationDistance(exactly: MKMapRect.world.size.height)!
        mapView.addOverlay(MKCircle(center: mapView.centerCoordinate, radius: mapRadius))
    }
    
    // MARK: Setup code for update PINS
    
    private func loadMapAnnotations() {
        if let pins = fetchedResultsController.fetchedObjects {
            mapView.addAnnotations(pins)
        }
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: Functionalities
    // TODO: add pin by holding on a location on map
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state != .began {
            return
        }
        
        let touchPoint = sender.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        addPin(longitude: newCoordinates.longitude, latitude: newCoordinates.latitude)
    }
    
    // MARK: -Model Functions
    
    /// Adds a new pin to the end of the `pins` array
    func addPin(longitude: Double, latitude: Double) {
        let pin = Pin(context: dataController.viewContext)
        pin.longitude = longitude
        pin.latitude = latitude
        pin.creationDate = Date()
        try? dataController.viewContext.save()
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
    }
    
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
