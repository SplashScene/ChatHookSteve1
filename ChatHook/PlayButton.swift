//
//  PlayButton.swift
//  ChatHook
//
//  Created by Kevin Farm on 9/9/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import Foundation
import UIKit

class PlayButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let image = UIImage(named: "playButton")
        
        translatesAutoresizingMaskIntoConstraints = false
        setImage(image, forState: .Normal)

        
        layer.cornerRadius = 5.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(2.0, 2.0)
        
    }
    
}
