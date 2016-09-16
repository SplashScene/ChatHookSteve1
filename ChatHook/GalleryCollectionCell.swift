//
//  GalleryCollectionCell.swift
//  ChatHook
//
//  Created by Kevin Farm on 9/13/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit

class GalleryCollectionCell: UICollectionViewCell {
    
    var profileViewController:ProfileViewController?

    var galleryImageView: UIImageView!
    
    var gallery: GalleryImage? {
        didSet {
            if let gallery = gallery {
                galleryImageView.loadImageUsingCacheWithUrlString(gallery.galleryImageUrl!)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 5.0
        contentView.clipsToBounds = true
        contentView.layer.shadowOpacity = 0.8
        contentView.layer.shadowRadius = 5.0
        contentView.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        contentView.layer.shadowColor = UIColor.blackColor().CGColor
        
        //galleryImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 90, height: 120))
        galleryImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        galleryImageView.contentMode = .ScaleAspectFill

        contentView.addSubview(galleryImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


}
