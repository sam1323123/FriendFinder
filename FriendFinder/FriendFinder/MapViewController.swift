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
    
    var currentMarkerPlace: GMSPlace?
    
    var currentInfoWindow: InfoWindowView?
    
    var apiKey: String!
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    fileprivate let errorDict : [GMSPlacesErrorCode:(String, String)] = Errors.placeErrors
    
    fileprivate var activeInfoWindowView: InfoWindowView? = nil
    
    override func loadView() {
        super.loadView()
    }
    
    override var shouldAutorotate: Bool {
        get {
            return true
        }
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return UIInterfaceOrientationMask.all
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
        
        let directionsAPI = PXGoogleDirections(apiKey: apiKey!,
                                               from: PXLocation.coordinateLocation(CLLocationCoordinate2DMake(37.331690, -122.030762)),
                                               to: PXLocation.specificLocation("Googleplex", "Mountain View", "United States"))
        self.marker.map = self.mapView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // initializes marker with given params for a place
    func initMarkerForPOI(with new_marker: GMSMarker, for place: GMSPlace) {
        currentMarkerPlace = place
        mapView.selectedMarker = new_marker
        new_marker.position = place.coordinate
        new_marker.opacity = 1
        new_marker.map = mapView
        new_marker.snippet = place.formattedAddress
        new_marker.title = place.name
        new_marker.infoWindowAnchor.y = 1
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


    func loadFirstPhotoForPlace(placeID: String, size: CGSize)  {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) {[weak self] (photos, error) -> Void in
            if let error = error {
                self?.handlePlacesError(error: error)
            } else {
                if let firstPhoto = photos?.results.first {
                   self?.loadImageForMetadata(photoMetadata: firstPhoto, size: size)
                }
                else {
                    self?.currentInfoWindow?.icon.image = #imageLiteral(resourceName: "no_image")
                    self?.spinner.stopAnimating()
                }
            }
        }
    }

    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata, size: CGSize)  {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, constrainedTo: size, scale: 1, callback: {[weak self]
            (photo, error) -> Void in
            self?.handlePlacesError(error: error)
            self?.currentInfoWindow?.icon.image = photo
            self?.currentInfoWindow?.attributionLabel.text = photoMetadata.attributions?.string
            self?.spinner.stopAnimating()
            
        })
    }

    func handlePlacesError(error: Error?) {
        if error != nil, let error = error as? GMSPlacesErrorCode {
            if let tuple = errorDict[error] {
                let title = tuple.0
                let message = tuple.1
                Utils.displayAlert(with: self, title: title, message: message, text: "OK")
            }
            print("lookup place id query error")
            return
        }
    }
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
        self.mapView.camera = GMSCameraPosition(target: place.coordinate, zoom: self.mapView.camera.zoom, bearing: 0, viewingAngle: 0)
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

        self?.handlePlacesError(error: error)
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
    
    
    func handleTapOnInfoWindow() {
        let infoWindow = self.activeInfoWindowView
        return
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
        guard let place = currentMarkerPlace else {
            // don't know place
            return nil
        }
        let infoWindow = infoWindowNib!
        infoWindow.awakeFromNib()
        DispatchQueue.main.async {
            [weak self] in
            self?.loadFirstPhotoForPlace(placeID: place.placeID, size: infoWindow.icon.intrinsicContentSize)
        }
        infoWindow.phoneNumber.text = currentMarkerPlace?.phoneNumber ?? "No Number Available"
        spinner.center = infoWindow.imageView.center
        infoWindow.imageView.addSubview(spinner)
        infoWindow.imageView.bringSubview(toFront: spinner)
        spinner.startAnimating()
        infoWindow.name.text = place.name
        infoWindow.placeDescription.text = place.formattedAddress
        
        //constraint based on font size
        infoWindow.placeDescription.numberOfLines = infoWindow.placeDescription.font.pointSize > 30 ? 1 : 3
        infoWindow.name.numberOfLines = infoWindow.name.font.pointSize < 18 ? 2 : 1
        
        currentInfoWindow = infoWindow
        marker.tracksInfoWindowChanges = true
        return infoWindow
    }
    
    
}



