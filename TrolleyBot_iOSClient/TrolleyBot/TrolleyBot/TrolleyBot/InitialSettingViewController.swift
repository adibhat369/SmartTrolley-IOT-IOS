//
//  InitialSettingViewController.swift
//  TrolleyBot
//
//  Created by Kavitha Gowribidanur Krishnappa on 4/11/18.
//  Copyright © 2018 Monash. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import GoogleSignIn
class InitialSettingViewController: UIViewController {

    @IBOutlet weak var storeName: UITextField!
    
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var radiusLabel: UILabel!
    
   
    @IBAction func setRadius(_ sender: UISlider) {
        if(slider.value != nil)
        {
            //Get slider value
            radius = Float(slider.value)
            radiusLabel.text = String(radius)
        }
       
        //print("Radius is ", radius)
    }
    
    
    @IBOutlet weak var mapView: MKMapView!
    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?
    private var radius: Float = 0.0
    private var lat: Double = 0.0
    private var lon: Double = 0.0
    //For user data, writing back to database
    var databaseRefForSaving = Database.database().reference().child("TrolleyBotStores")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLocationServices()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveInitialData(_ sender: Any) {
        //Save personal details of store to Firebare
        let userRef = databaseRefForSaving.child("\(String(describing: storeName.text))")
        userRef.child("PersonalDetails").setValue(["InitialLatitude": lat, "InitialLongitude": lon, "Radius":radius/100])

    }
    
    @IBAction func getCenterLocation(_ sender: UILongPressGestureRecognizer) {
        //Get Pressed location
        let location = sender.location(in: self.mapView)
        let locCoord = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        lat = locCoord.latitude
        lon = locCoord.longitude
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoord
        annotation.title = "Center of the Store"
        annotation.subtitle = "Location from where the radius is to be considered"
        
        
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.addAnnotation(annotation)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
    //requesting for authorization from the user
    private func configureLocationServices() {
        locationManager.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        
        if  status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        else { if status == .authorizedAlways || status == .authorizedWhenInUse {
            
            beginLocationUpdates(locationManager: locationManager)
            }
            
        }
        
        
    }
    
    //updating user location
    private func beginLocationUpdates(locationManager: CLLocationManager) {
        
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
    }
    
    //Zooming to the user location within 400radius
    private func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
        
        let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        mapView.setRegion(zoomRegion, animated: true)
        
    }
    //adding annotations to the user on map
    func addAnnotation (annotation: MKAnnotation) {
        
        self.mapView.addAnnotation(annotation)
    }
    func focusOn(annotation: MKAnnotation)
    {
        self.mapView.centerCoordinate = annotation.coordinate
        self.mapView.selectAnnotation(annotation, animated: true)
    }
    
    
    
    
    
    
}
extension InitialSettingViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did get latest location")
        
        guard let latestLocation = locations.first else { return }
        
        if currentCoordinate == nil {
            zoomToLatestLocation(with: latestLocation.coordinate)
            
            
            
        }
        //adding geofence to user
        currentCoordinate = latestLocation.coordinate
        
        
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("The status changed")
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            
            beginLocationUpdates(locationManager: manager)
        }
    }
    

    
}
