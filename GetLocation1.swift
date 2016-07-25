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

class GetLocation1: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var onlineButton: UIButton!
    
    var locationManager:CLLocationManager? = nil
    let regionRadius:CLLocationDistance = 5000
    var userLocation: CLLocation?
    var userOnline: Bool = false
    
    var currentUserName: String?
    var currentProfilePicURL: String?
    
    let currentUser = DataService.ds.REF_USER_CURRENT
    
    var timer: NSTimer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        self.mapView.delegate = self
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        checkAuthorizationStatus()
        self.mapView.showsUserLocation = true
        
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
    
    func updateUI(){
        if userOnline{
            onlineButton.setTitle("Go Offline", forState: .Normal)
            onlineButton.backgroundColor = UIColor.blueColor()
            messageLabel.text = ""
        }else{
            onlineButton.setTitle("Go Online", forState: .Normal)
        }
        
    }
    
    func showLocationServicesDeniedAlert(){
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func goOnline(){
        userOnline = onlineButton.titleLabel!.text == "Go Online" ? true : false
        postToFirebase(userOnline, location: userLocation!)
        updateUI()
    }//end go online
    
    func postToFirebase(online: Bool, location: CLLocation){
        currentUser.child("Online").setValue(online)
        if online{
            currentUser.child("UserLatitude").setValue(location.coordinate.latitude)
            currentUser.child("UserLongitude").setValue(location.coordinate.longitude)
        }else{
            currentUser.child("UserLatitude").removeValue()
            currentUser.child("UserLongitude").removeValue()
        }
        
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
        }
    }
}

//MARK: - Map View Delegate Functions

extension GetLocation1: MKMapViewDelegate{
    func centerMapOnLocation(location:CLLocation){
        let radiusFactor = 2
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * Double(radiusFactor), regionRadius * Double(radiusFactor))
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if let loc = userLocation.location{
            
            centerMapOnLocation(loc)
            addRadiusCircle(loc)
        }
    }
    
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