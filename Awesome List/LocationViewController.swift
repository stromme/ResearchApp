//
//  LocationViewController.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/16/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationNameLabel: UILabel!
    var location_name: String = " "
    var point: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        // Get coords
        let myLocation: CLLocationCoordinate2D = userLocation.coordinate
        
        var gc: CLGeocoder = CLGeocoder()
        gc.reverseGeocodeLocation(userLocation.location, completionHandler: {(placemarks, error) in
            if (error != nil) {
                println("reverse geodcode fail: \(error.localizedDescription)")
                var alertView = UIAlertView()
                alertView.title = "Find Location"
                alertView.addButtonWithTitle("Okay")
                alertView.message = "Failed to find location name"
                alertView.show()

                gc.cancelGeocode()
            }
            if(placemarks != nil){
                let pm = placemarks as [CLPlacemark]
                if pm.count > 0 {
                    let placemark = CLPlacemark(placemark: placemarks[0] as CLPlacemark)
                    self.location_name = String(format:"%@ %@, %@ %@ %@, %@",
                        (placemark.subThoroughfare != nil) ? placemark.subThoroughfare : "" ,
                        (placemark.thoroughfare != nil) ? placemark.thoroughfare : "",
                        (placemark.locality != nil) ? placemark.locality : "",
                        (placemark.postalCode != nil) ? placemark.postalCode : "",
                        (placemark.administrativeArea != nil) ? placemark.administrativeArea : "",
                        (placemark.country != nil) ? placemark.country : "")
                    self.locationNameLabel.text = (self.location_name != "") ? self.location_name : "Cannot find location name"
                }
            }
        })
        
        // Zoom Region
        var zoomRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(myLocation, 2500, 2500)
        
        // Show our location
        self.mapView.setRegion(zoomRegion, animated: true)
        
        mapView.removeAnnotations(mapView.annotations)
        // Add an annotation
        var point:MKPointAnnotation = MKPointAnnotation();
        point.coordinate = userLocation.coordinate;
        point.title = "You are here";
        point.subtitle = "Your current location";
        mapView.addAnnotation(point)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickDoneLocation(sender: AnyObject) {
        self.performSegueWithIdentifier("returnToTask", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "returnToTask") {
            var taskVC = segue.destinationViewController as TaskViewController
            taskVC.task_location_name.text = self.location_name
        }
    }
}
