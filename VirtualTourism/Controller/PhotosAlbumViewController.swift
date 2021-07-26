//
//  PhotosListViewController.swift
//  VirtualTourism
//
//  Created by Luthfi Abdurrahim on 26/07/21.
//

import UIKit
import CoreData
import MapKit
import Kingfisher

class PhotosAlbumViewController: UIViewController {
    
    // MARK: Injected Properties
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    
    // MARK: IBOutlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var getNewPhotosButton: UIButton!
    
    // MARK: Properties
    let estimatedItemsPerRow: CGFloat = 3
    let reuseId = "PhotoCell"
    var totalPages = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setupFetchedResultsController()
        
        setGetNewPhotosButtonEnabled(to: false)
        
        if (fetchedResultsController.sections?[0].numberOfObjects ?? 0 == 0) {
            getPhotos()
        } else {
            setGetNewPhotosButtonEnabled(to: true)
        }
        
        mapView.addAnnotation(pin)
        mapView.showAnnotations([pin], animated: true)
        mapView.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    private func setGetNewPhotosButtonEnabled(to state: Bool) {
        getNewPhotosButton.isEnabled = state
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin!.creationDate!)-photos")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    private func getPhotos() {
        setGetNewPhotosButtonEnabled(to: false)
        AppClient.getListOfPhotosIn(lat: pin.latitude, lon: pin.longitude, totalPages: totalPages) { (error, photosURL, totalPages) in
            // if photos is empty show empty background
            switch error {
            case .notConnected:
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Hmmmm..", message:
                        "There seems to be no internet connection! please, connect to a network then try again.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
                break
            case .connected:
                self.totalPages = totalPages
                for photoURL in photosURL! {                    
                    self.addPhoto(url: photoURL)
                }
                break
            case .other:
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Hmmmm..", message:
                        "Something bad occured. Please, try again.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
                break
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.setGetNewPhotosButtonEnabled(to: true)
            }
        }
    }
    
    func addPhoto(url: String) {
        let photo = Photo(context: dataController.viewContext)
        photo.creationDate = Date()
        photo.url = url
        photo.pin = pin
        try? dataController.viewContext.save()
    }
    
    func deletePhoto(_ photo: Photo) {
        dataController.viewContext.delete(photo)
        do {
            try dataController.viewContext.save()
        } catch {
            print("Error saving, sorry")
        }
        
    }
    
    @IBAction func removeAllPhotos() {
        if let photos = fetchedResultsController.fetchedObjects {
            for photo in photos {
                dataController.viewContext.delete(photo)
                do {
                    try dataController.viewContext.save()
                } catch {
                    print("Error saving, sorry")
                }
            }
        }
        getPhotos()
    }
    
}
