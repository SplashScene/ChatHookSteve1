//
//  MaterialImageView.swift
//  ChatHook
//
//  Created by Kevin Farm on 5/10/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit

class MaterialImageView: UIImageView {
        override func awakeFromNib() {
            layer.cornerRadius = frame.size.width / 2
            self.clipsToBounds = true
        }
}
