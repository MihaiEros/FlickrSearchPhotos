//
//  MainViewController+PhotoViewModelDelegate.swift
//  FlickrSearchPhotosApp
//
//  Created by Mihai Eros on 05.06.2022.
//

import UIKit

// MARK: - PhotoViewModelDelegate

extension MainViewController: PhotoViewModelDelegate {
    func fetchingDidComplete(with newIndexPaths: [IndexPath]?) {
        guard let newIndexPaths = newIndexPaths else {
            collectionView.reloadData()
            return
        }
        
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPaths)
        collectionView.reloadItems(at: indexPathsToReload)
    }
    
    func fetchingDidFail(with reason: String) {
        presentAlert(with: reason)
    }
    
    fileprivate func presentAlert(with reason: String) {
        let alert = UIAlertController(title: "Error", message: reason, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        
        present(alert, animated: true)
    }
}
