//
//  MainViewController+PhotoViewModelDelegate.swift
//  FlickrSearchPhotosApp
//
//  Created by Mihai Eros on 05.06.2022.
//

import UIKit

// MARK: - PhotoViewModelDelegate

fileprivate enum Constants {
    static let alertTitle: String = "Error"
    static let actionOK: String = "OK"
}

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
        let alert = UIAlertController(title: Constants.alertTitle, message: reason, preferredStyle: .alert)
        let action = UIAlertAction(title: Constants.actionOK, style: .default)
        alert.addAction(action)
        
        present(alert, animated: true)
    }
}
