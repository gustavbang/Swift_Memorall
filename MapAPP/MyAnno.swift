//
//  MyAnno.swift
//  MapAPP
//
//  Created by admin on 21.09.18.
//  Copyright © 2018 admin. All rights reserved.
//

import MapKit
class MyAnno: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: UIImage?
    var type: String?
    var descriptionText: String?
    var identifier = "Pin"
    
    init(title:String, subtitle:String, coordinate:CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
