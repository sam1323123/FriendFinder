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
import FontAwesome_swift


class MapViewController: UIViewController {
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!

    @IBOutlet weak var userViewLabel: UILabel!
    
    @IBOutlet weak var preferredNameField: UITextField!
    
    @IBOutlet weak var userNameField: UITextField!
   
    @IBOutlet weak var userButton: UIButton!
   
    @IBOutlet var userView: UIView!
    
    @IBOutlet weak var mapView: GMSMapView!

    @IBOutlet weak var searchBox: UITextField! {
        
        didSet {
            searchBox.layer.borderColor = UIColor.darkGray.cgColor
            searchBox.attributedPlaceholder = NSAttributedString(string: "Enter Location",
                                                                 attributes: [NSForegroundColorAttributeName: UIColor.darkGray])
            searchBox.delegate = self
        }
    }
    var visualEffect: UIVisualEffect?
    
    let directionAPI = (UIApplication.shared.delegate as! AppDelegate).directionsAPI
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
    
    lazy var userName: String? = { [weak self] in
        var dict: NSDictionary?
        self!.ref.child("users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            dict = value
        })
        if (dict != nil) {
            return dict!["username"] as? String
        }
        else {
            return nil
        }
    } ()
    
    lazy var preferredName: String? = { [weak self] in
        var dict: NSDictionary?
        self!.ref.child("names").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            dict = value
        })
        if (dict != nil) {
            return dict!["name"] as? String
        }
        else {
            return nil
        }
    } ()
    
    var displayName: String?
    
    var apiKey: String!
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    fileprivate let errorDict : [GMSPlacesErrorCode:(String, String)] = Errors.placeErrors
    
    fileprivate var activeInfoWindowView: InfoWindowView? = nil
    
    fileprivate let interactor = SwipeInteractor()

    
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
        displayName = Auth.auth().currentUser?.providerData.first?.displayName
        marker.map = mapView
        visualEffect = visualEffectView.effect
        visualEffectView.effect = nil
        visualEffectView.alpha = 0.8
        
        if (userName == nil) {
            animateUserInputScreen()
        }
    }
    
    private func animateUserInputScreen() {
        view.addSubview(userView)
        let displayText = (displayName == nil) ? "" : ", " + displayName!.components(separatedBy: " ")[0]
        userViewLabel.text = "Welcome\(displayText)! Please enter your preferred name and username."
        userButton.addTarget(self, action: #selector(animateOutUserInputScreen), for: .touchUpInside)
        userView.center = view.center
        userView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        userView.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {
            [weak self] in
            self!.visualEffectView.effect = self!.visualEffect
            self!.userView.alpha = 1
            self!.userView.transform = CGAffineTransform.identity
        })
    }
    
    func animateOutUserInputScreen() {
        preferredName = preferredNameField.text?.trimmingCharacters(in: [" "])
        userName = userNameField.text?.trimmingCharacters(in: [" "])
        if (userName!.characters.count == 0 || preferredName!.characters.count == 0) {
            return
        }
        print(preferredName)
        print(userName)
        UIView.animate(withDuration: 0.8, animations: {
            [weak self] in
            self!.userView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self!.userView.alpha = 0
            self!.visualEffectView.effect = nil
            }, completion: {
                [weak self]
                (success: Bool) in
                self!.userView.removeFromSuperview()
        })
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // initializes marker with given params for a place
    func initMarkerForPOI(with new_marker: GMSMarker, for place: GMSPlace) {
        currentMarkerPlace = place
        new_marker.position = place.coordinate
        new_marker.opacity = 1
        new_marker.map = mapView
        new_marker.snippet = place.formattedAddress
        new_marker.title = place.name
        new_marker.infoWindowAnchor.y = 1
        mapView.selectedMarker = new_marker
        print("initMarkerFinished with locatin: \(marker.position)")
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
        vc.address = "\(place.formattedAddress ?? "NA")"
        
        vc.placeImage = currentInfoWindow!.icon.image
        
        vc.web = place.website
        vc.webColor = (place.website == nil) ? .red : view.tintColor
        
        
        if let phone = place.phoneNumber {
            // remove special characters first
            let charsToRemove: Set<Character> = Set("()- ".characters)
            vc.phone = String(( phone.characters.filter { !charsToRemove.contains($0) }))
            vc.phoneColor = view.tintColor
        }
        
        else {
            vc.phone = nil
            vc.phoneColor = .red
        }
        
        vc.rating = "\n\n\(place.rating) \(getStars(from: place.rating))\n"

        
        vc.status = (place.openNowStatus == GMSPlacesOpenNowStatus.yes) ? "Open Now!\n" : "Closed!\n"
        vc.statusColor = (place.openNowStatus == GMSPlacesOpenNowStatus.yes) ? .green : .red
        
        var price: String
        var color: UIColor = Utils.gold
        
        switch(place.priceLevel) {
        case(GMSPlacesPriceLevel.free):
            price = "Free!"
            break
        case(GMSPlacesPriceLevel.cheap):
            price = String.fontAwesomeIcon(name: .dollar)
            break
        case(GMSPlacesPriceLevel.medium):
            price = String(repeating: String.fontAwesomeIcon(name: .dollar), count: 2)
            break
        case(GMSPlacesPriceLevel.high):
            price = String(repeating: String.fontAwesomeIcon(name: .dollar), count: 3)
            break
        case(GMSPlacesPriceLevel.expensive):
            price = String(repeating: String.fontAwesomeIcon(name: .dollar), count: 4)
            break
        default:
            price = "NA"
            color = .red
        }
        
        vc.price = "\(price)\n"
        vc.priceColor = color
        
        //set spinner
        vc.spinner = spinner
        return
    }
    
    private func getStars(from rating: Float) -> String {
        let total = Float(5.0)
        let roundedToHalf = round(rating * 2.0)/2.0
        let needsHalf = ((roundedToHalf - round(rating)) != 0)
        let numEmptyStars = Int(total - round(roundedToHalf))
        if (needsHalf) {
            return String(repeating: String.fontAwesomeIcon(name: .star), count: Int(roundedToHalf - Float(0.5))) + String.fontAwesomeIcon(name: .starHalfO) + String(repeating: String.fontAwesomeIcon(name: .starO), count: numEmptyStars)
        }
        else {
            return String(repeating: String.fontAwesomeIcon(name: .star), count: Int(roundedToHalf)) + String(repeating: String.fontAwesomeIcon(name: .starO), count: numEmptyStars)
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destVC = segue.destination as? LocationDetailViewController {
            fillLocationDetailVC(vc: destVC)
            //for animated transition
            destVC.interactor = interactor
            destVC.transitioningDelegate = self
        }
        
        
    }
    
    
}



extension MapViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let dismissed = dismissed as? LocationDetailViewController {
            if !dismissed.backPressed {
                //only perform custom if pan gesture version
                return DragDismissAnimator()
            }
        }
        return nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if animator.isMember(of: DragDismissAnimator.self) {
            print("IS DRAG DISMISS")
        }
        if animator.isKind(of: DragDismissAnimator.self) {
            print("ALSO DRAG DISMISS")
        }
        return interactor
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
        //print("Place attributions: \(String(describing: place.attributions))")
        mapView.camera = GMSCameraPosition(target: place.coordinate, zoom: mapView.camera.zoom, bearing: 0, viewingAngle: 0)
        self.currentMarkerPlace = place
        dismiss(animated: true, completion: {
            self.initMarkerForPOI(with: self.marker, for: self.currentMarkerPlace!)
        })
        
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
        print("infoWindow called, \(marker.position)")
        return infoWindow
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        handleTapOnInfoWindow()
        
    }
    
    
}



