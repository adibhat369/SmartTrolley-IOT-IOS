//
//  FencedAnnotation.swift
//  TrolleyBot
//
//  Created by Kavitha Gowribidanur Krishnappa on 30/10/18.
//  Copyright © 2018 Monash. All rights reserved.
//

import UIKit
import MapKit

class TrolleyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: UIImage?
    
    init(newTitle: String, newSubtitle: String, lat: Double, lon: Double, newImage: UIImage)
    {
        title = newTitle
        subtitle = newSubtitle
        coordinate = CLLocationCoordinate2D()
        coordinate.latitude = lat
        coordinate.longitude = lon
        image = newImage
    }
    
    

}
