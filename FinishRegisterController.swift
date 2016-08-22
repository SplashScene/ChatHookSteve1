//
//  FinishRegisterController.swift
//  ChatHook
//
//  Created by Kevin Farm on 8/21/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase

class FinishRegisterController: UIViewController {

    var dbRef: FIRDatabaseReference!
    var introViewController: IntroViewController?
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .System)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        //button.addTarget(self, action: #selector(handleLoginRegister), forControlEvents: .TouchUpInside)
        return button
    }()
    
    
    
    let userNameTextField: MaterialTextField = {
        let ntf = MaterialTextField()
        ntf.placeholder = "User Name"
        ntf.translatesAutoresizingMaskIntoConstraints = false
        return ntf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let fullNameTextField: MaterialTextField = {
        let etf = MaterialTextField()
        etf.placeholder = "Full Name"
        etf.translatesAutoresizingMaskIntoConstraints = false
        return etf
    }()
    
    
    lazy var profileImageView: MaterialImageView = {
        let imageView = MaterialImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        imageView.image = UIImage(named: "genericProfile")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickPhoto)))
        imageView.userInteractionEnabled = true
        return imageView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        
        
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        
    }
    
    func setupProfileImageView(){
        //need x, y, width, height constraints
        profileImageView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        profileImageView.bottomAnchor.constraintEqualToAnchor(inputsContainerView.topAnchor, constant: -12).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(150).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(150).active = true
    }
    
    
    func setupInputsContainerView(){
        //need x, y, width, height constraints
        inputsContainerView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        inputsContainerView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        inputsContainerView.widthAnchor.constraintEqualToAnchor(view.widthAnchor, constant: -24).active = true
        inputsContainerView.heightAnchor.constraintEqualToConstant(80).active = true
        
        inputsContainerView.addSubview(userNameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(fullNameTextField)
        
        
        //need x, y, width, height constraints for name text field
        userNameTextField.leftAnchor.constraintEqualToAnchor(inputsContainerView.leftAnchor).active = true
        userNameTextField.topAnchor.constraintEqualToAnchor(inputsContainerView.topAnchor).active = true
        userNameTextField.widthAnchor.constraintEqualToAnchor(inputsContainerView.widthAnchor).active = true
        userNameTextField.heightAnchor.constraintEqualToAnchor(inputsContainerView.heightAnchor, multiplier: 1/2).active = true
        
        //need x, y, width, height constraints for name separator view
        nameSeparatorView.leftAnchor.constraintEqualToAnchor(inputsContainerView.leftAnchor).active = true
        nameSeparatorView.topAnchor.constraintEqualToAnchor(userNameTextField.bottomAnchor).active = true
        nameSeparatorView.widthAnchor.constraintEqualToAnchor(inputsContainerView.widthAnchor).active = true
        nameSeparatorView.heightAnchor.constraintEqualToConstant(1).active = true
        
        //need x, y, width, height constraints for email text field
        fullNameTextField.leftAnchor.constraintEqualToAnchor(inputsContainerView.leftAnchor).active = true
        fullNameTextField.topAnchor.constraintEqualToAnchor(nameSeparatorView.bottomAnchor).active = true
        fullNameTextField.widthAnchor.constraintEqualToAnchor(inputsContainerView.widthAnchor).active = true
        fullNameTextField.heightAnchor.constraintEqualToAnchor(inputsContainerView.heightAnchor, multiplier: 1/2).active = true
    }
    
    func setupLoginRegisterButton(){
        //need x, y, width, height constraints
        loginRegisterButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        loginRegisterButton.topAnchor.constraintEqualToAnchor(inputsContainerView.bottomAnchor, constant: 12).active = true
        loginRegisterButton.widthAnchor.constraintEqualToAnchor(inputsContainerView.widthAnchor).active = true
        loginRegisterButton.heightAnchor.constraintEqualToConstant(50).active = true
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func handleLoginRegister(){
        
    }
    
}//end view controller

extension FinishRegisterController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func takePhotoWithCamera(){
        let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .Camera
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    func choosePhotoFromLibrary(){
        let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .PhotoLibrary
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    func pickPhoto(){
        if UIImagePickerController.isSourceTypeAvailable(.Camera){
            showPhotoMenu()
        }else{
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {
            _ in
            self.takePhotoWithCamera()
        })
        alertController.addAction(takePhotoAction)
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default, handler: {
            _ in
            self.choosePhotoFromLibrary()
        })
        alertController.addAction(chooseFromLibraryAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            print("Info did not have the required UIImage for the Original Image")
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        profileImageView.image = image

        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
}

}

