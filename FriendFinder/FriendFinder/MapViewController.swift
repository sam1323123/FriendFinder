//
//  MapViewController.swift
//  FriendFinder
//
//  Created by Samuel Lee on 7/2/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import PXGoogleDirections

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!

    @IBOutlet weak var searchBox: UITextField! {
        
        didSet {
            searchBox.layer.borderColor = UIColor.darkGray.cgColor
            searchBox.attributedPlaceholder = NSAttributedString(string: "Enter Location",
                                                                 attributes: [NSForegroundColorAttributeName: UIColor.darkGray])
            searchBox.delegate = self
        }
    }
    
    let locationManager = CLLocationManager()
    let placesClient = GMSPlacesClient.shared()
    
    let marker = GMSMarker()
    
    var apiKey: String!
    
    //the last point of interest clicked
    fileprivate var poiPlace: GMSPlace?
    
    override func loadView() {
        super.loadView()
    }
    
    override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return UIInterfaceOrientationMask.portrait
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.accessibilityElementsHidden = false
        mapView.delegate = self
        print(mapView.mapType)
        var dict: NSDictionary?
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            dict = NSDictionary(contentsOfFile: path)
            if dict != nil, let key = dict!["GoogleMapsAPIKey"] as? String {
                apiKey = key
            }
        }
        print(apiKey!)
        let directionsAPI = PXGoogleDirections(apiKey: apiKey!,
                                               from: PXLocation.coordinateLocation(CLLocationCoordinate2DMake(37.331690, -122.030762)),
                                               to: PXLocation.specificLocation("Googleplex", "Mountain View", "United States"))
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // initializes marker with given params
    func initMarker(with marker: GMSMarker, place: GMSPlace) {
        
            marker.position = place.coordinate
            marker.snippet = place.formattedAddress
            marker.title = place.name
            marker.opacity = 0;
            marker.infoWindowAnchor.y = 1 // self?.mapView.center ?? (self?.view.center)!
            marker.map = self.mapView
            self.mapView.selectedMarker = marker
            self.mapView.camera = GMSCameraPosition(target: place.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
    }
    
    
    func moveMarkerToPOI(with marker: GMSMarker, to place: GMSPlace?) {
        if(place == nil) {
            return
        }
        
        self.mapView.selectedMarker = marker
        marker.position = place!.coordinate
        marker.opacity = 1
        marker.map = self.mapView
        marker.snippet = place!.formattedAddress
        marker.title = place!.name
        marker.infoWindowAnchor.y = 1
        self.mapView.camera = GMSCameraPosition(target: place!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension MapViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Will present autocomplete view")
        let searchView = GMSAutocompleteViewController()
        searchView.delegate = self
        present(searchView, animated: true, completion: nil)
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
        
    }
}


extension MapViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions))")
        initMarker(with: self.marker, place: place)
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}


extension MapViewController: GMSMapViewDelegate {
    
    // wrapper that gets place and passes it to a callback
    fileprivate func GetPlace(from placeID: String, callback: @escaping (GMSPlace) -> Void)
    {
        placesClient.lookUpPlaceID(placeID, callback: { [callback] (place, error) -> Void in
        if (error != nil) {
            Utils.displayAlert(with: self, title: "Unexpected Error", message: "Please try again later.", text: "OK")
            print("lookup place id query error: \(error!.localizedDescription)")
            return
        }

        if (place == nil) {
            Utils.displayAlert(with: self, title: "Place Not Found!", message: "Please try another place.", text: "OK")
            return
        }
            
        // run callback
        callback(place!)

        })
    }
    
    
    fileprivate func getPlace(from placeID: String, callback: @escaping () -> Void)
    {
        placesClient.lookUpPlaceID(placeID, callback: { [callback] (place, error) -> Void in
            if (error != nil) {
                Utils.displayAlert(with: self, title: "Unexpected Error", message: "Please try again later.", text: "OK")
                print("lookup place id query error: \(error!.localizedDescription)")
                return
            }
            
            if (place == nil) {
                Utils.displayAlert(with: self, title: "Place Not Found!", message: "Please try another place.", text: "OK")
                return
            }
            
            // run callback
            self.poiPlace = place
            callback()
            
        })
    }

    
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String,
                 name: String, location: CLLocationCoordinate2D) {
        print("POI IS SELECTED")
        /*
        GetPlace(from: placeID) {[weak self](place) in
            print("You tapped \(name): \(place.name), \(location.latitude)/\(location.longitude)")
           self?.initMarker(with: self!.marker, place: place)
        }
        */
        getPlace(from: placeID){[weak self] in
            self?.moveMarkerToPOI(with: (self?.marker)!, to: self?.poiPlace)
        }
        
        
    }
    
    
}


