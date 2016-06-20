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

class CurrentLocationViewcontrollerViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var onlineButton: UIButton!
    
    let locationManager = CLLocationManager()
    let regionRadius:CLLocationDistance = 1000
    var location: CLLocation?
    var online:Bool = false
    
    var updatingLocation = false
    var lastLocationError: NSError?
    
    let currentUser = DataService.ds.REF_USER_CURRENT
    
    var timer: NSTimer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
    }
    
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)")
        if error.code == CLError.LocationUnknown.rawValue{
            return
        }
        lastLocationError = error
        configureOnlineButton()
        stopLocationManager()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let newLocation = locations.last!
            print("didUpdateLocations \(newLocation)")
            if newLocation.timestamp.timeIntervalSinceNow < -5{
                return
            }
            if newLocation.horizontalAccuracy < 0{
                return
            }
            if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy{
                lastLocationError = nil
                location = newLocation
                
                if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy{
                    print("*** We're done!")
                    stopLocationManager()
                }
            
            }
    }
    
    func startLocationManager(){
        print("Inside startLocationManager")
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
        }
    }
    
    func stopLocationManager(){
        if updatingLocation{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
        
    }
    
    func showLocationServicesDeniedAlert(){
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func goOnline(){
        let authStatus = CLLocationManager.authorizationStatus()
        
        switch(authStatus){
            case .NotDetermined: locationManager.requestWhenInUseAuthorization(); return
            case .Denied: showLocationServicesDeniedAlert(); return
            case .Restricted: showLocationServicesDeniedAlert(); return
            default:
                if updatingLocation{
                    stopLocationManager()
                    online = false
                    centerMapOnLocation(location!)
                }
                else if location != nil && onlineButton.titleLabel?.text == "Go Online"{
                    online = true
                    centerMapOnLocation(location!)
                    configureOnlineButton()
                    postToFirebase(online, location: location!)
                }
                else if location != nil && onlineButton.titleLabel?.text == "Go Offline"{
                    online = false
                    currentUser.childByAppendingPath("Online").setValue(online)
                    configureOnlineButton()
                    centerMapOnLocation(location!)
                }
        }//end switch
        
        startTimerForLocationUpdate()
    }//end go online
    
    func postToFirebase(online: Bool, location: CLLocation){
        let currentUser = DataService.ds.REF_USER_CURRENT
        currentUser.childByAppendingPath("Online").setValue(online)
        currentUser.childByAppendingPath("UserLatitude").setValue(location.coordinate.latitude)
        currentUser.childByAppendingPath("UserLongitude").setValue(location.coordinate.longitude)
    }
    
    func startTimerForLocationUpdate(){
        if timer != nil{
            timer.invalidate()
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(900.0, target: self, selector: #selector(CurrentLocationViewcontrollerViewController.startLocationManager), userInfo: nil, repeats: true)
    }
    
    //MARK: - Configure Button and Status Message
    
    func configureOnlineButton(){
        if !online{
            onlineButton.setTitle("Go Online", forState: .Normal)
            onlineButton.backgroundColor = PLAYLIFE_COLOR
            messageLabel.text = "Tap Go Online to Start..."
            return
        }
        if updatingLocation{
            onlineButton.setTitle("Stop", forState: .Normal)
        }
        else if location != nil && online{
            onlineButton.setTitle("Go Offline", forState: .Normal)
            onlineButton.backgroundColor = UIColor.blueColor()
            messageLabel.text = "You are now online"
            mapView.showsUserLocation = true
        }
    }
    /*
    func configureStatusMessage(){
        let statusMessage: String
        if let error = lastLocationError{
            if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue{
                statusMessage = "Location Services Disabled"
            }else{
                statusMessage = "Error Getting Location"
            }
        }
        else if !CLLocationManager.locationServicesEnabled(){
            statusMessage = "Location Services Disabled"
        }
        else if updatingLocation{
            statusMessage = "Searching..."
        }
        else{
            statusMessage = "Tap Go Online to Start..."
        }
        messageLabel.text = statusMessage
    }
    */
}//end class

//MARK: - Map View Delegate Functions

extension CurrentLocationViewcontrollerViewController: MKMapViewDelegate{
    func centerMapOnLocation(location:CLLocation){
        let radiusFactor = online ? 2 : 8
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


