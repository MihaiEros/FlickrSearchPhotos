//
//  PhotoCollectionViewCell.swift
//  FlickrSearchPhotosApp
//
//  Created by Mihai Eros on 05.06.2022.
//

import UIKit

final class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PhotoCollectionViewCell"
    
    private let photoImageView: DownloadableImageViewContainer = {
        let imageView = DownloadableImageViewContainer()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(photoImageView)
        addPhotoImageViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.imageView.image = nil
    }
    
    private func addPhotoImageViewConstraints() {
        NSLayoutConstraint.activate([
            photoImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            photoImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            photoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            photoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with photo: Photo?) {
        if let photo = photo {
            photoImageView.downloadImage(url: photo.url)
        } else {
            photoImageView.startAnimating()
        }
    }
    
    func cancelImageDownload() {
        photoImageView.cancelImageDownload()
    }
}
