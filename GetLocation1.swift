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
    var otherUsersLocations: [UserLocation] = []
    var userOnline: Bool = false
    
    var userLatInt: Int!
    var userLngInt: Int!
    
    let currentUserRef = DataService.ds.REF_USER_CURRENT
    var blockedUsers: [String] = []
    var timer: NSTimer!
    
    //MARK: - Objects

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
    
    lazy var logoutButton: UIButton = {
        let logButton = UIButton()
            logButton.translatesAutoresizingMaskIntoConstraints = false
            logButton.setTitle("Logout", forState: .Normal)
            logButton.titleLabel?.textColor = UIColor.whiteColor()
            logButton.titleLabel?.font = UIFont(name: "Avenir Medium", size: 14.0)
            logButton.addTarget(self, action: #selector(handleLogout), forControlEvents: .TouchUpInside)
        return logButton
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
 
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(topView)
        view.addSubview(mapView)
        
        locationManager = CLLocationManager()
        self.mapView.delegate = self
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        checkAuthorizationStatus()
        
        setupUI()
        mapView.addAnnotations(otherUsersLocations)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK: - Setup Methods
    
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
        topView.addSubview(logoutButton)
        
        onlineLabel.rightAnchor.constraintEqualToAnchor(topView.rightAnchor, constant: -8).active = true
        onlineLabel.centerYAnchor.constraintEqualToAnchor(topView.centerYAnchor).active = true
        
        logoutButton.leftAnchor.constraintEqualToAnchor(topView.leftAnchor, constant: 8).active = true
        logoutButton.centerYAnchor.constraintEqualToAnchor(topView.centerYAnchor).active = true
        logoutButton.widthAnchor.constraintEqualToConstant(60).active = true
        logoutButton.heightAnchor.constraintEqualToConstant(30).active = true
        
        mapView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        mapView.topAnchor.constraintEqualToAnchor(topView.bottomAnchor).active = true
        mapView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        mapView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
    }
    
    func userIsOnline(){
        userOnline = true
        onlineLabel.text = "Online"
        topView.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        
        if let currentUserLocation = CurrentUser._location{
            userLatInt = Int(currentUserLocation.coordinate.latitude)
            userLngInt = Int(currentUserLocation.coordinate.longitude)
            let usersOnlineRef = DataService.ds.REF_BASE.child("users_online").child("\(userLatInt)").child("\(userLngInt)").child(CurrentUser._postKey)
            let userLocal = ["userLatitude":currentUserLocation.coordinate.latitude, "userLongitude": currentUserLocation.coordinate.longitude]
            usersOnlineRef.setValue(userLocal)
            observeOtherUsersLocations()
        }
        centerMapOnLocation(CurrentUser._location!)
        self.mapView.showsUserLocation = true
        addRadiusCircle(CurrentUser._location!)
    }

    //MARK: - Observe Methods
    
    func fetchCurrentUser(userLocation: CLLocation){
        currentUserRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    CurrentUser._postKey = snapshot.key
                    CurrentUser._userName = dictionary["UserName"] as! String
                    CurrentUser._location = userLocation
                    CurrentUser._email = dictionary["email"] as! String
                    CurrentUser._profileImageUrl = dictionary["ProfileImage"] as? String
                    
                    let blockedUsersRef = self.currentUserRef.child("blocked_users")
                    blockedUsersRef.observeEventType(.Value, withBlock: { (snapshot) in
                            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                                for snap in snapshots{
                                    let blockedUserID = snap.key
                                    self.blockedUsers.append(blockedUserID)
                                    
                                    self.handleLoadingBlockedUsers()
                                }
                            }
                        },
                        
                        withCancelBlock: nil)
                    
                    self.userIsOnline()
                }
            }, withCancelBlock: nil)
    }
    
    func observeOtherUsersLocations(){
        let otherUsersLocationsRef = DataService.ds.REF_USERSONLINE.child("\(userLatInt)").child("\(userLngInt)")
            otherUsersLocationsRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let otherUserId = snapshot.key
                    let otherUserLat = dictionary["userLatitude"] as! Double
                    let otherUserLong = dictionary["userLongitude"] as! Double
                    
                        let otherUsersRef = DataService.ds.REF_USERS.child(otherUserId)
                            otherUsersRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                                    if let userDict = snapshot.value as? [String: AnyObject]{
                                        let otherUserName = userDict["UserName"] as! String
                                        let otherUserImageUrl = userDict["ProfileImage"] as! String
                                        
                                        let otherUserLocation = UserLocation(latitude: otherUserLat, longitude: otherUserLong, name: otherUserName, imageName: otherUserImageUrl)
                                        self.otherUsersLocations.append(otherUserLocation)
                                        
                                        self.timer?.invalidate()
                                        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.handleAnnotations), userInfo: nil, repeats: false)
                                    }
                                }, withCancelBlock: nil)
                }
            }, withCancelBlock: nil)
    }
    
    //MARK: - Handlers
    
    func handleAnnotations(){
        self.mapView.addAnnotations(self.otherUsersLocations)
    }
    
    func handleLoadingBlockedUsers(){
        print("Inside handleLoadingBlockedUsers")
        CurrentUser._blockedUsersArray = blockedUsers
        print("Current User blocked array count is: \(CurrentUser._blockedUsersArray?.count)")
    }
    
    func handleLogout(){
        do{
            let usersOnlineRef = DataService.ds.REF_BASE.child("users_online").child("\(userLatInt)").child("\(userLngInt)").child(CurrentUser._postKey)
            usersOnlineRef.removeValue()
            
            try FIRAuth.auth()?.signOut()
            
        }catch let logoutError{
            print(logoutError)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
//    func startTimerForLocationUpdate(){
//        if timer != nil{
//            timer.invalidate()
//        }
//        timer = NSTimer.scheduledTimerWithTimeInterval(900.0, target: self, selector: #selector(CurrentLocationViewcontrollerViewController.startLocationManager), userInfo: nil, repeats: true)
//    }
    
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
            if CurrentUser._location == nil {
                print("I don't even have a user")
            }
            if userLocation != nil{
                fetchCurrentUser(userLocation!)
            }else{
                print("I got NO location")
            }
           centerMapOnLocation(userLocation!)
           
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse{
            locationManager?.requestLocation()
        }
    }
    
    func showLocationServicesDeniedAlert(){
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}//end extension

//MARK: - Map View Delegate Functions

extension GetLocation1: MKMapViewDelegate{
    func centerMapOnLocation(location:CLLocation){
        let radiusFactor = userOnline ? 2 : 8
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * Double(radiusFactor), regionRadius * Double(radiusFactor))
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation){
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("otherLocation") as? MKPinAnnotationView
        if annotationView == nil{
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "otherLocation")
        }else{
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    /*
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if let loc = userLocation.location{
            print("MAP VIEW LOCATION is: \(userLocation.coordinate.latitude) and \(userLocation.coordinate.longitude)")
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
    */
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