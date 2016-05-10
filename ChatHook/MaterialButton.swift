//
//  MaterialButton.swift
//  ChatHook
//
//  Created by Kevin Farm on 5/10/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import Foundation
import UIKit

class MaterialButton: UIButton {
    override func awakeFromNib() {
        
        backgroundColor = PLAYLIFE_COLOR
        setTitleColor(UIColor.whiteColor(), forState: .Normal)
        titleLabel?.font = UIFont(name: FONT_AVENIR_MEDIUM, size: 18.0)
        
        
        layer.cornerRadius = 5.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
        
    }
    
    
}