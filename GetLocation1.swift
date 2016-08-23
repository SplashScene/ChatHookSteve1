//
//  CurrentLocationViewcontrollerViewController.swift
//  ChatHook
//
//  Created by Kevin Farm on 6/10/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import Alamofire

class GetLocation1: UIViewController {
    
    var registerViewController: FinishRegisterController?
    var request: Request?
    var locationManager:CLLocationManager? = nil
    let regionRadius:CLLocationDistance = 5000
    var userLocation: CLLocation?
    var userOnline: Bool = false
    
    var currentUserName: String?
    var currentProfilePicURL: String?
    var currentProfileImage: UIImage?
    
    let currentUser = DataService.ds.REF_USER_CURRENT
    
    var timer: NSTimer!

    
    let mapView: MKMapView = {
        let map = MKMapView()
            map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    let topView: UIView = {
        let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.darkGrayColor()
        return view
    }()
    
    let onlineLabel: UILabel = {
        let msgLabel = UILabel()
            msgLabel.translatesAutoresizingMaskIntoConstraints = false
            msgLabel.font = UIFont(name: "Avenir Medium", size:  18.0)
            msgLabel.backgroundColor = UIColor.clearColor()
            msgLabel.textColor = UIColor.whiteColor()
            msgLabel.text = "Offline"
            msgLabel.sizeToFit()

        return msgLabel
    }()
    
    lazy var onlineSwitch: UISwitch = {
        let onOffSwitch = UISwitch()
            onOffSwitch.translatesAutoresizingMaskIntoConstraints = false
            onOffSwitch.addTarget(self, action: #selector(switchChanged), forControlEvents: .ValueChanged)
        return onOffSwitch
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(topView)
        view.addSubview(mapView)
        
        setupUI()
        fetchCurrentUser()
        
        locationManager = CLLocationManager()
        self.mapView.delegate = self
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        checkAuthorizationStatus()
        
        
        //self.mapView.showsUserLocation = true
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func fetchCurrentUser(){
        currentUser.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                self.currentUserName = dictionary["UserName"] as? String
                self.currentProfilePicURL = dictionary["ProfileImage"] as? String
                self.fetchProfilePic(self.currentProfilePicURL!)
            }
            }, withCancelBlock: nil)
        
        
    }
    
    func fetchProfilePic(profilePic: String){
        request = Alamofire.request(.GET, profilePic).validate(contentType:["image/*"]).response(completionHandler: { request, response, data, err in
            if err == nil {
                let img = UIImage(data: data!)!
                self.currentProfileImage = img
                if self.currentProfileImage != nil{
                    print("The image is set")
                }else{
                    print("The image is NOT set")
                }
                
            }// end if err
        })//end completion handler

    }
    
    func checkAuthorizationStatus(){
        let authStatus = CLLocationManager.authorizationStatus()
        
        switch(authStatus){
        case .NotDetermined: locationManager?.requestWhenInUseAuthorization(); return
        case .Denied: showLocationServicesDeniedAlert(); return
        case .Restricted: showLocationServicesDeniedAlert(); return
        default:
            if authStatus != .AuthorizedWhenInUse{
                locationManager?.requestWhenInUseAuthorization()
            }else{
                locationManager?.requestLocation()
            }
        }//end switch
    }//end checkAuthorizationStatus
    
    func setupUI(){
        //need x, y, width and height constraints
        topView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        topView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        topView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        topView.heightAnchor.constraintEqualToConstant(70).active = true
        
        topView.addSubview(onlineLabel)
        topView.addSubview(onlineSwitch)
        
        onlineLabel.leftAnchor.constraintEqualToAnchor(topView.leftAnchor, constant: 16).active = true
        onlineLabel.centerYAnchor.constraintEqualToAnchor(topView.centerYAnchor).active = true
        
        onlineSwitch.rightAnchor.constraintEqualToAnchor(topView.rightAnchor, constant: -16).active = true
        onlineSwitch.centerYAnchor.constraintEqualToAnchor(topView.centerYAnchor).active = true
  
        mapView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        mapView.topAnchor.constraintEqualToAnchor(topView.bottomAnchor).active = true
        mapView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        mapView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
    }
    
    func switchChanged(){
        if onlineSwitch.on{
            locationManager?.requestLocation()
            userOnline = true
            onlineLabel.text = "Online"
            topView.backgroundColor = UIColor(r: 80, g: 101, b: 161)
            currentUser.child("Online").setValue(true)
            currentUser.child("UserLatitude").setValue(userLocation!.coordinate.latitude)
            currentUser.child("UserLongitude").setValue(userLocation!.coordinate.longitude)
            self.mapView.showsUserLocation = true
            centerMapOnLocation(userLocation!)
            addRadiusCircle(userLocation!)
        }else{
            userOnline = false
            onlineLabel.text = "Offline"
            topView.backgroundColor = UIColor.darkGrayColor()
            currentUser.child("Online").setValue(false)
            currentUser.child("UserLatitude").removeValue()
            currentUser.child("UserLongitude").removeValue()
            self.mapView.showsUserLocation = false
            centerMapOnLocation(userLocation!)
            //addRadiusCircle(userLocation!)
        }
    }
    
    func showLocationServicesDeniedAlert(){
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
       func startTimerForLocationUpdate(){
        if timer != nil{
            timer.invalidate()
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(900.0, target: self, selector: #selector(CurrentLocationViewcontrollerViewController.startLocationManager), userInfo: nil, repeats: true)
    }
    
}//end class


//MARK: - CLLocationManagerDelegate
extension GetLocation1: CLLocationManagerDelegate{
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location did fail with error")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if userLocation == nil{
            
            //userLocation = locations.first
            userLocation = CLLocation(latitude: 41.92413, longitude: -88.161242)
            centerMapOnLocation(userLocation!)
           
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse{
            locationManager?.requestLocation()
        }
    }
}//end extension

//MARK: - Map View Delegate Functions

extension GetLocation1: MKMapViewDelegate{
    func centerMapOnLocation(location:CLLocation){
        let radiusFactor = userOnline ? 2 : 8
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * Double(radiusFactor), regionRadius * Double(radiusFactor))
        mapView.setRegion(coordinateRegion, animated: true)
    }
    /*
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if let loc = userLocation.location{
            print("MAP VIEW LOCATION is: \(userLocation.coordinate.latitude) and \(userLocation.coordinate.longitude)")
            centerMapOnLocation(loc)
            addRadiusCircle(loc)
        }
    }
    */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(mapView.userLocation) {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
                annotationView.image = UIImage(named: "ProfileIcon25")
            return annotationView
        }else{
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
                annotationView.image = UIImage(named: "heart-full")
            return annotationView
        }
    }
    
    //MARK: - Overlay Functions
    func addRadiusCircle(location: CLLocation){
        self.mapView.delegate = self
        let circle = MKCircle(centerCoordinate: location.coordinate, radius: 500 as CLLocationDistance)
        self.mapView.addOverlay(circle)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.redColor()
            circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
            circle.lineWidth = 1
        return circle
        
    }
    
}//end extension