//
//  SystemSettingViewController.swift
//  TrolleyBot
//
//  Created by Kavitha Gowribidanur Krishnappa on 3/11/18.
//  Copyright © 2018 Monash. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class SystemSettingViewController: UIViewController {

    
   
    @IBOutlet weak var storeName: UITextField!
    
   
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
   
    @IBOutlet weak var mapView: MKMapView!
    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?
    private var lat: Double = 0.0
    private var lon: Double = 0.0
    private var radius: Float = 0.0
    var setting: InitialSettingViewController?
    //For user data, writing back to database
    var databaseRefForSaving = Database.database().reference().child("TrolleyBotStores")
   
    // Slider to get radius
    @IBAction func findRadius(_ sender: UISlider) {
        print("in slider", sender.value)
        print("slider", radiusSlider.value)
        radius = Float(radiusSlider.value)
        radiusLabel.text = String(radiusSlider.value)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //storeName = setting?.storeName
        print(storeName)
        configureLocationServices()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func updateData(_ sender: Any) {
    
    
        let userRef = databaseRefForSaving.child(storeName.text!)
        userRef.child("PersonalDetails").setValue(["InitialLatitude": lat, "InitialLongitude": lon, "Radius":radius/100 ])
    }

    @IBAction func getCenterLocation(_ sender: UILongPressGestureRecognizer) {
        // Get pressed location
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
extension SystemSettingViewController: CLLocationManagerDelegate {


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


