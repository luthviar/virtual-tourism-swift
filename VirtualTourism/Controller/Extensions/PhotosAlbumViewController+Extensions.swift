//
//  PhotosAlbumViewController+Extensions.swift
//  VirtualTourism
//
//  Created by Luthfi Abdurrahim on 26/07/21.
//

import UIKit
import CoreData
import MapKit
import Kingfisher

extension PhotosAlbumViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let theWidth = collectionView.bounds.width/estimatedItemsPerRow
        let theHeight = theWidth

        return CGSize(width: theWidth, height: theHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension PhotosAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (fetchedResultsController.sections?[section].numberOfObjects ?? 0 == 0) {
            collectionView.setEmptyMessage("No photos :(, try to refresh.")
        } else {
            collectionView.deleteEmptyMessage()
        }
        
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let aPhoto = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! PhotoCell
        cell.imageView.contentMode = .scaleAspectFit
                
        // Configure cell
        if let photoData = aPhoto.data {
            cell.imageView.image = UIImage(data: photoData)
        } else if let photoURL = aPhoto.url {
            guard let url = URL(string: photoURL) else {
                print("no! please")
                return cell
            }
            cell.imageView.kf.setImage(with: url, placeholder: UIImage(named: "Placeholder"), options: nil, progressBlock: nil) { (img, err, cacheType, url) in
                if ((err) != nil) {
                    
                } else {
                    aPhoto.data = img?.pngData()
                    try? self.dataController.viewContext.save()
                }
            }
        }
        
        return cell
    }
}

extension PhotosAlbumViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        deletePhoto(photoToDelete)
    }
    
}

extension PhotosAlbumViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            break
        default: ()
        }
    }
}

