//
//  MaterialImageView.swift
//  ChatHook
//
//  Created by Kevin Farm on 5/10/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit

class MaterialImageView: UIImageView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        layer.cornerRadius = frame.size.width / 2
        self.clipsToBounds = true
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
        layer.shadowColor = UIColor.blackColor().CGColor
        self.contentMode = .ScaleAspectFill 
    }

        override func awakeFromNib() {
            layer.cornerRadius = frame.size.width / 2
            self.clipsToBounds = true
            layer.shadowOpacity = 0.8
            layer.shadowRadius = 5.0
            layer.shadowOffset = CGSizeMake(0.0, 2.0)
            layer.shadowColor = UIColor.blackColor().CGColor
        }
}
