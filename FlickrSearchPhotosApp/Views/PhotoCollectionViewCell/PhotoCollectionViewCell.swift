//
//  PhotoCollectionViewCell.swift
//  FlickrSearchPhotosApp
//
//  Created by Mihai Eros on 05.06.2022.
//

import UIKit

final class PhotoCollectionViewCell: UICollectionViewCell {
    
    /// Identfiier
    static let identifier = "PhotoCollectionViewCell"
    
    /// Views
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)
        indicator.style = .medium
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(photoImageView)
        addPhotoImageViewConstraints()
        
        contentView.addSubview(activityIndicator)
        addActivityIndicatorConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Prepare for reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        DispatchQueue.main.async {
            self.setImageView(.none)
        }
    }
    
    // MARK: - Constraints
    
    private func addPhotoImageViewConstraints() {
        NSLayoutConstraint.activate([
            photoImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            photoImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            photoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            photoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func addActivityIndicatorConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Configure cell
    
    func configure(with image: UIImage?, animated: Bool = true) {
        DispatchQueue.main.async {
            if animated {
                UIView.animate(withDuration: 0.3) {
                    self.setImageView(image)
                }
            } else {
                self.setImageView(image)
            }
        }
    }
    
    private func setImageView(_ image: UIImage?) {
        if let image = image {
            self.photoImageView.image = image
            activityIndicator.stopAnimating()
        } else {
            self.photoImageView.image = nil
            activityIndicator.startAnimating()
        }
    }
}
