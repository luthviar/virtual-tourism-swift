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
    
    // MARK: Injected Properties
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
    
    /// add pin by holding on a location on map
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state != .began {
            return
        }
        
        let touchPoint = sender.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        addPin(longitude: newCoordinates.longitude, latitude: newCoordinates.latitude)
    }
    
    // MARK: Model Functions
    
    /// Adds a new pin to the end of the `pins` array
    func addPin(longitude: Double, latitude: Double) {
        let pin = Pin(context: dataController.viewContext)
        pin.longitude = longitude
        pin.latitude = latitude
        pin.creationDate = Date()
        try? dataController.viewContext.save()
    }
}

