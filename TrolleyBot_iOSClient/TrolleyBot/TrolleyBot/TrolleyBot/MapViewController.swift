//
//  MapViewController.swift
//  TrolleyBot
//
//  Created by Kavitha Gowribidanur Krishnappa on 30/10/18.
//  Copyright © 2018 Monash. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import Firebase
import UserNotifications

class MapViewController: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?
    private var ref: DatabaseReference!
    private var refHandle: DatabaseHandle?
    var geoLocation: CLCircularRegion?
    var trolleyList = [String]()
    var appDelegate: AppDelegate?
    
    @IBAction func segmentControlAction(_ sender: Any) {
        print("Selected segment is ", segmentControl.selectedSegmentIndex)
        observeTrolleys()
        
        
    }
    deinit {
        if let refHandle = refHandle {
            ref.removeObserver(withHandle: refHandle)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
       
        
        super.init(coder: aDecoder)!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        ref = Database.database().reference().child("TrolleyBotStores").child("ColesCaulfield")
        Auth.auth()
        
        mapView.delegate = self
        
        // Configure Location Updates
        configureLocationServices()
        //observeTrolleys()
        
        // Do any additional setup after loading the view.
    }
    
  
    
    
    
    // MARK: - Firebase Observation
    private func observeTrolleys()
    {
        print("Observing events")
        // Get all trolleys for this store
        ref.child("trolleys").observe(.childAdded, with: {(snapshot) in
            guard (snapshot.value as? NSDictionary) != nil else {
                return
            }
            
            let trolleyName = snapshot.key
            print("Id is id ",trolleyName )
            self.trolleyList.append(trolleyName )
            let newTrolley:Trolley = Trolley(newname: trolleyName)
            
            //For each trolley, specify another listener
             self.observeSpecificTrolley(name: trolleyName, trolley: newTrolley)

        })
    }
    
    private func observeSpecificTrolley(name: String, trolley:Trolley) {
        
        //Start a new listener
        ref.child("trolleys").child(name).observe(.childAdded, with: {(snapshot) in
            guard let value = snapshot.value as? NSDictionary else {
                return
            }
            
            //Get the values from Firebase and load to Trolley Object
            print("snapval is",snapshot.key)
            var lat: Double!
            var lon: Double!
            var dateTime: String!
            var alarm: Bool!
            for(type, attribute) in value {
                let typeStr = type as! String
                //print(typeStr,"Type")
                let valStr = attribute
                
                if (typeStr == "lat") {
                    lat = (valStr as AnyObject).doubleValue
                    trolley.lat = lat
                    //print(lat," lat is")
                }
                if (typeStr == "long") {
                    lon = (valStr as AnyObject).doubleValue
                    trolley.long = lon
                    //print(lon," long is")
                }
                if (typeStr == "Alarm") {
                    alarm = (valStr as AnyObject).boolValue
                    trolley.alarm = alarm
                    //print(alarm," Alarm is")
                }
                if (typeStr == "time") {
                    dateTime = valStr as? String
                    //print(dateTime," date is")
                }
            }
            self.mapTrolleyToAnnotation(trolley: trolley)
        })
    }
 
    
    private func mapTrolleyToAnnotation(trolley: Trolley) {
        
        // Check status of trolley and map to annotation
        let redTrolleyImage = UIImage(named: "redTrolley")
        let greenTrolleyImage = UIImage(named: "greenTrolley")
        var finalImage:UIImage
        var status: String?
        if trolley.alarm == false {
            finalImage = greenTrolleyImage!
            status = "Within Zone"
        }
        else {
            //self.handleEvent(eventType: "Intrusion", trolley: t
            self.createNotification(message: "Beware", trolley: trolley)
            finalImage = redTrolleyImage!
            status = "Out of Zone!"
        }
        let trolleyAnnotationList = self.mapView.annotations
        var found:Bool = false
        
        if (segmentControl.selectedSegmentIndex == 0)
        {
            print("Inside adding annotations for 0")
        for (_,trolleyAnnotation) in trolleyAnnotationList.enumerated() {
            if trolleyAnnotation.title == trolley.name {
                //remove and readd the annotation
                found = true
                self.mapView.removeAnnotation(trolleyAnnotation)
                let annotation:TrolleyAnnotation = TrolleyAnnotation(newTitle: trolley.name! , newSubtitle: status!, lat: trolley.lat!, lon: trolley.long!, newImage: finalImage)
                self.addAnnotation(annotation: annotation)
            }
        }
        if found == false {
            let annotation:TrolleyAnnotation = TrolleyAnnotation(newTitle: trolley.name!, newSubtitle: status!, lat: trolley.lat!, lon: trolley.long!, newImage: finalImage)
            self.addAnnotation(annotation: annotation)
        }
        }
        else if(segmentControl.selectedSegmentIndex == 1)
        {
            print("Inside adding annotations for 1")
            for (_,fenceAnnotation) in trolleyAnnotationList.enumerated() {
                if fenceAnnotation.title == trolley.name {
                    found = true
                    self.mapView.removeAnnotation(fenceAnnotation)
                    //let annotation:FencedAnnotation = FencedAnnotation(newTitle: trolley.name! , newSubtitle: status!, lat: trolley.lat!, lon: trolley.long!, newImage: finalImage)
                    //self.addAnnotation(annotation: annotation)
                }
            }
            if found == false {
                let annotation:TrolleyAnnotation = TrolleyAnnotation(newTitle: trolley.name!, newSubtitle: status!, lat: trolley.lat!, lon: trolley.long!, newImage: finalImage)
                self.addAnnotation(annotation: annotation)
            }
        }
    }
    
    
    //For notifications when the app is open
    //using https://medium.com/@dkw5877/local-notifications-in-ios-156a03b81ceb
    private func createNotification(message:String, trolley: Trolley) {
        //get the notification center
        let center =  UNUserNotificationCenter.current()
        
        //create the content for the notification
        let content = UNMutableNotificationContent()
        content.title = "TrolleyBot"
        content.subtitle = message
        content.body = "Found a trolley out of zone"
        content.sound = UNNotificationSound.default
        
        //notification trigger can be based on time, calendar or location
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval:60.0, repeats: false)
        
        //create request to display
        let request = UNNotificationRequest(identifier: "ContentIdentifier", content: content, trigger: trigger)
        
        //add request to notification center
        center.add(request) { (error) in
            if error != nil {
                print("error \(String(describing: error))")
            }
        }
    }
    //UserNotificationDelegate methods
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge]) //required to show notification when in foreground
    }
    
   //https://www.youtube.com/watch?v=Tt-cIKKuCGA
    
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
        
        let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
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
extension MapViewController: CLLocationManagerDelegate {
    
    
    
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

extension MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        
        
        if annotation !== mapView.userLocation {
            
            let tAnnotation = annotation as! TrolleyAnnotation
            let image:UIImage = tAnnotation.image!
            
        
        //resisizing the image to be shown as annotation
        let newHeight = 20
        UIGraphicsBeginImageContext(CGSize(width: 20, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0,width: 20, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        print("Setting image for annotation")
        annotationView?.image = newImage
            annotationView?.canShowCallout = true
        }
        else {
            return nil
        }
        
        
        
        return annotationView
    }
    
    
    
    /*func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "AnimalDetail", sender: view)
    }*/
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("The annotation was selected: \(String(describing: view.annotation?.title))")
    }
    
}



