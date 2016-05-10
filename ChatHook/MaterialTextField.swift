//
//  MaterialTextField.swift
//  ChatHook
//
//  Created by Kevin Farm on 5/10/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import Foundation
import UIKit

class MaterialTextField: UITextField {
    
    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.borderColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.1).CGColor
        layer.borderWidth = 1.0
        textColor = UIColor.whiteColor()
        font = UIFont(name: "FONT_ANENIR_LIGHT", size: 14.0)
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    }
}
