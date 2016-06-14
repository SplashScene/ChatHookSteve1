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
    //var testLocation = CLLocation(latitude: 41.924215, longitude: -88.16121)
    
    var updatingLocation = false
    var lastLocationError: NSError?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        configureOnlineButton()
        // Do any additional setup after loading the view.
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
        configureOnlineButton()
    }
    
    func startLocationManager(){
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
    
    func configureOnlineButton(){
        if updatingLocation{
            onlineButton.setTitle("Stop", forState: .Normal)
        } else if location != nil{
            onlineButton.setTitle("Go Offline", forState: .Normal)
            onlineButton.backgroundColor = UIColor.blueColor()
            messageLabel.text = "You are now online"
            mapView.showsUserLocation = true
        }
        else{
            onlineButton.setTitle("Go Online", forState: .Normal)
        }
    }
    
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

    @IBAction func goOnline(){
        
            let authStatus = CLLocationManager.authorizationStatus()
            
            if authStatus == .NotDetermined{
                locationManager.requestWhenInUseAuthorization()
                return
            }
            
            if authStatus == .Denied || authStatus == .Restricted{
                showLocationServicesDeniedAlert()
                return
            }
            
        if updatingLocation{
            stopLocationManager()
        }else{
            location = nil
            lastLocationError = nil
            startLocationManager()
        }
            configureOnlineButton()
            configureStatusMessage()
  
    }//end go online
    
    func configureStatusMessage(){
        let statusMessage: String
        
        if let error = lastLocationError{
            if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue{
                statusMessage = "Location Services Disabled"
            }else{
                statusMessage = "Error Getting Location"
            }
        }else if !CLLocationManager.locationServicesEnabled(){
            statusMessage = "Location Services Disabled"
        }else if updatingLocation{
            statusMessage = "Searching..."
        }else{
            statusMessage = "Tap Go Online to Start..."
        }
        
        messageLabel.text = statusMessage
        
    }
    
}//end class

extension CurrentLocationViewcontrollerViewController: MKMapViewDelegate{
    func centerMapOnLocation(location:CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2, regionRadius * 2)
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
    
}

