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
    var location: CLLocation?
    
    var updatingLocation = false
    var lastLocationError: NSError?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        }
        else{
            onlineButton.setTitle("Go Online", forState: .Normal)
        }
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
