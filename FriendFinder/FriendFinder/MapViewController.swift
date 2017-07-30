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
import FirebaseDatabase
import FirebaseAuth


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
    
    var ref: DatabaseReference!

    var currentLocation: CLLocation? {
        didSet {
            if currentLocation != nil {
                if let floor = currentLocation!.floor?.level {
                    ref.child("locations").child((Auth.auth().currentUser?.uid)!).setValue(
                        ["latitude": currentLocation!.coordinate.latitude,
                         "longitude": currentLocation!.coordinate.longitude,
                         "altitude": currentLocation!.altitude,
                         "floor": floor])
                }
                else {
                    ref.child("locations").child((Auth.auth().currentUser?.uid)!).setValue(
                        ["latitude": Double(currentLocation!.coordinate.latitude),
                         "longitude": Double(currentLocation!.coordinate.longitude),
                         "altitude": Double(currentLocation!.altitude)])
                }
            }
        }
    }
    
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
        ref = Database.database().reference()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.accessibilityElementsHidden = false
        mapView.delegate = self
        mapView.mapType = GMSMapViewType.normal
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
        let userID = Auth.auth().currentUser?.uid
        ref.child("locations").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            print(value)
        })
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
    
    //TODO: Write function to fill vc with the image and place locations
    func fillLocationDetailVC(vc: LocationDetailViewController) {
        if(currentMarkerPlace == nil || currentInfoWindow == nil) {
            print("Should not happen in fillLocationDetailVC")
            return
        }
        
        let place = self.currentMarkerPlace!

        vc.placeName = place.name
        vc.address = place.formattedAddress
        
        vc.placeImage = currentInfoWindow!.icon.image
        
        let website = (place.website ?? URL(string: "NA"))!
        
        let number = (place.phoneNumber ?? "NA")!
        vc.contactDetails = "Phone Number: \(number)\n\n" + "Website: \(website)\n"
        
        let openNow = (place.openNowStatus == GMSPlacesOpenNowStatus.yes) ? "Open Now" : "Closed"
        var price: String
        switch(place.priceLevel) {
        case(GMSPlacesPriceLevel.free):
            price = "Free"
            break
        case(GMSPlacesPriceLevel.cheap):
            price = "Cheap"
            break
        case(GMSPlacesPriceLevel.high):
            price = "High"
            break
        case(GMSPlacesPriceLevel.expensive):
            price = "Very High"
            break
        default:
            price = "NA"
        }

        let details = ("Rating: \(place.rating)\n\n" + "Status: \(openNow)\n\n" +
        "Price Level: \(price)\n\n")
        vc.placeHours = details
        
        //set spinner
        vc.spinner = spinner
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destVC = segue.destination as? LocationDetailViewController {
            fillLocationDetailVC(vc: destVC)
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
        //performSegue(withIdentifier: "Details", sender: nil)
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
        if let location = locations.last  {
            if currentLocation == nil {
                mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                currentLocation = location
            }
            if location.distance(from: currentLocation!) > 10 {
                currentLocation = location
            }
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

        print("TAPPED ON WINDOW")
        performSegue(withIdentifier: "Details", sender: self)

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
    
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        handleTapOnInfoWindow()
        
    }
    
    
}



