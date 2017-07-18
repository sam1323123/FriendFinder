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
    
    fileprivate let errorDict : [GMSPlacesErrorCode:(String, String)] = Errors.placeErrors
    
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
        mapView.mapType = GMSMapViewType.normal
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
    
    // initializes marker with given params for a place
    func initMarkerForPOI(with marker: GMSMarker, for place: GMSPlace) {
        
        marker.position = place.coordinate
        marker.opacity = 1
        marker.map = mapView
        marker.snippet = place.formattedAddress
        marker.title = place.name
        marker.infoWindowAnchor.y = 1
        mapView.selectedMarker = marker
        mapView.camera = GMSCameraPosition(target: place.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
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
        initMarkerForPOI(with: marker, for: place)
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
    fileprivate func getPlace(from placeID: String, callback: @escaping (GMSPlace) -> Void)
    {
        placesClient.lookUpPlaceID(placeID, callback: {[weak self, callback] (place, error) -> Void in
        if error != nil, let error = error as? GMSPlacesErrorCode {
            if let tuple = self?.errorDict[error] {
                let title = tuple.0
                let message = tuple.1
                Utils.displayAlert(with: self!, title: title, message: message, text: "OK")
        
            }
            print("lookup place id query error")
            return
        }

        if (place == nil) {
            Utils.displayAlert(with: self!, title: "Place Not Found!", message: "Please try another place.", text: "OK")
            return
        }
            
        // run callback
        callback(place!)

        })
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String,
                 name: String, location: CLLocationCoordinate2D) {
        print("POI IS SELECTED")
        getPlace(from: placeID){[weak self] (place) in
            self?.initMarkerForPOI(with: self!.marker, for: place)
        }
        
        
    }
    
    //Delegate Method for making custom InfoWindow
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        print("Marker Delegate Called, \(marker.title)")
        //return nil
        let infoWindowNib = UINib(nibName: "InfoWindowView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? InfoWindowView
        if(infoWindowNib == nil) {
            print("COULD NOT FIND NIB FILE")
            return nil
        }
        let infoWindow = infoWindowNib!
        infoWindow.awakeFromNib()
        //infoWindow.phoneNumber = UILabel()
        infoWindow.phoneNumber.text = "Phone: 123456789"
        //infoWindow.icon = UIImageView(image: #imageLiteral(resourceName: "google.png"))
        infoWindow.icon.image = #imageLiteral(resourceName: "google.png")
        //infoWindow.name = UILabel()
        infoWindow.name.text = marker.title //?? "No Title"
        //infoWindow.placeDescription = UILabel()
        infoWindow.placeDescription.text = marker.snippet //?? "No Snippet"
        
        return infoWindow
    }
    
    
}




