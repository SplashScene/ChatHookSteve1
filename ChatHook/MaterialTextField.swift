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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        layer.cornerRadius = 2.0
        layer.borderColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 1.0).CGColor
        layer.borderWidth = 1.0
        layer.backgroundColor = TEXTFIELD_BACKGROUND_COLOR.CGColor
        textColor = UIColor.darkGrayColor()
        font = UIFont(name: "FONT_ANENIR_LIGHT", size: 14.0)   
    }

    
//    override func awakeFromNib() {
//        //layer.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1.0).CGColor
//        layer.backgroundColor = UIColor.lightGrayColor().CGColor
//        layer.cornerRadius = 2.0
//        layer.borderColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 1.0).CGColor
//        layer.borderWidth = 15.0
//        textColor = UIColor.whiteColor()
//        font = UIFont(name: "FONT_ANENIR_LIGHT", size: 14.0)
//    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    }
}
