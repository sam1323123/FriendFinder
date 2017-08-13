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
                    ref.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(
                        ["latitude": currentLocation!.coordinate.latitude,
                         "longitude": currentLocation!.coordinate.longitude,
                         "altitude": currentLocation!.altitude,
                         "floor": floor])
                }
                else {
                    ref.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(
                        ["latitude": Double(currentLocation!.coordinate.latitude),
                         "longitude": Double(currentLocation!.coordinate.longitude),
                         "altitude": Double(currentLocation!.altitude)])
                }
            }
        }
    }
    
    var userName: String?
    
    var preferredName: String?
    
    var displayName: String?
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    fileprivate let errorDict : [GMSPlacesErrorCode:(String, String)] = Errors.placeErrors
    
    fileprivate var activeInfoWindowView: InfoWindowView? = nil
    
    fileprivate let interactor = SwipeInteractor()
    
    fileprivate var nextVC: LocationDetailViewController?
    
    fileprivate var nextVCBackColor: UIColor? {
        didSet {
            if (nextVC != nil) {
                nextVC?.backButtonColor = nextVCBackColor
            }
        }
    }
    
    fileprivate var placeHours: NSMutableAttributedString? {
        didSet {
            if (nextVC != nil) {
                nextVC?.status = placeHours
            }
        }
    }

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
    
    let buttonColor = UIColor(red: 56.0/255.0, green: 114.0/255.0, blue: 108.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.accessibilityElementsHidden = false
        mapView.delegate = self
        mapView.mapType = GMSMapViewType.normal
        marker.map = mapView
        displayName = Auth.auth().currentUser?.providerData.first?.displayName
        visualEffect = visualEffectView.effect
        visualEffectView.effect = nil
        visualEffectView.alpha = 0.8
        initializeUserInfo()
    }
    
    //Call this method to initializ all user profile info like username and preferred name
    private func initializeUserInfo() {
        self.ref.child("users/\(Auth.auth().currentUser!.uid)").observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
            if snapshot.hasChild("username") && snapshot.hasChild("name") {
                let data = snapshot.value as! [String:AnyObject]
                self?.userName = data["username"] as? String
                self?.preferredName = data["name"] as? String
                self?.visualEffectView.removeFromSuperview()
                self?.visualEffectView = nil
                return
            }
            else {
                self?.userButton.addTarget(self, action: #selector(self?.createUsernameButtonAction(sender:)), for: .touchUpInside)
                self?.animateUserInputScreen()
            }
            
            }, withCancel: {(err) in
                print("Network Error with Firebase with type: \(err)")
                Utils.displayAlert(with: self, title: "Error", message: "Cannot connect to server. Please check network settings or try again later.", text: "OK", callback: {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    })
            })
    }
    
    private func animateUserInputScreen() {
        view.addSubview(userView)
        let displayText = (displayName == nil) ? "" : ", " + displayName!.components(separatedBy: " ")[0]
        userViewLabel.text = "Welcome\(displayText)! Please enter your preferred name and username."
        //userButton.addTarget(self, action: #selector(animateOutUserInputScreen), for: .touchUpInside)
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
    
    func animateOutUserInputScreen(completion: (() -> Void)? = nil) {
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
                self!.userView = nil
                self!.visualEffectView.removeFromSuperview()
                self!.visualEffectView = nil
                if let comp_fn = completion {
                    comp_fn()
                }
        })
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
                    self?.nextVCBackColor = .black
                    
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
            self?.nextVCBackColor = .white
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
        vc.webColor = (place.website == nil) ? .red : buttonColor
        
        
        if let phone = place.phoneNumber {
            // remove special characters first
            let charsToRemove: Set<Character> = Set("()- ".characters)
            vc.phone = String(( phone.characters.filter { !charsToRemove.contains($0) }))
            vc.phoneColor = buttonColor
        }
        
        else {
            vc.phone = nil
            vc.phoneColor = .red
        }
        
        vc.rating = "\n\n\(place.rating) \(getStars(from: place.rating))\n"

        
        if (place.openNowStatus == GMSPlacesOpenNowStatus.yes) {print ("OPEEEEEN")}
        else if (place.openNowStatus == GMSPlacesOpenNowStatus.no) { print("CLOSEEED")}
        else if (place.openNowStatus == GMSPlacesOpenNowStatus.unknown) { print("NOOOOOO") }
        
        var price: String?
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
            price = nil
        }
        
        vc.price = (price != nil) ? "\(price!)\n" : nil
        vc.priceColor = color

        
        vc.status = placeHours
        
        //set spinner
        vc.spinner = spinner
        
        vc.backButtonColor = nextVCBackColor
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
            nextVC = destVC
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
    
    
    // delegate Method for making custom InfoWindow
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let infoWindowNib = UINib(nibName: "InfoWindowView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? InfoWindowView
        if(infoWindowNib == nil) {
            print("COULD NOT FIND NIB FILE")
            return nil
        }
        guard let place = currentMarkerPlace else {
            // don't know place
            return nil
        }
        getPlaceHours(for: place)
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
    
    // helper to get place hours from GMS Places API
    private func getPlaceHours(for place: GMSPlace) {
        let apiKey = (UIApplication.shared.delegate as! AppDelegate).GMSkey!
        let placesEndpoint: String = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(place.placeID)&key=\(apiKey)"
        guard let placesURL = URL(string: placesEndpoint) else {
            print("Error: cannot create URL for GMS Places endpoint")
            return
        }
        let placesTask = URLSession.shared.dataTask(with: URLRequest(url: placesURL)) {
            [weak self]
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("Error: Could not send GET on Places endpoint ")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: Did not receive data from on Places endpoint")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let placesResponse = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("Error: Could not convert JSON to dictionary")
                        return
                }
                self!.formatHours(dict: placesResponse, with: place, callback: {
                    [weak self] text in
                    DispatchQueue.main.async {
                        self!.placeHours = text
                    }
                })
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        placesTask.resume()
    }

    
    
    fileprivate func formatHours(dict: [String : Any], with place: GMSPlace, callback: @escaping ((NSMutableAttributedString) -> ())) {
        guard let result = dict["result"] as? [String : Any] else {
            return callback(NSMutableAttributedString(string: ""))
        }
        guard let openingHours = result["opening_hours"] as? [String : Any] else {
            return callback(NSMutableAttributedString(string: ""))
        }
        guard let hours = openingHours["weekday_text"] as? [String] else {
            return callback(NSMutableAttributedString(string: ""))
        }
        let formatter = DateFormatter()
        let localDay = formatter.weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1]
        var text = ""
        var tupMap = [String:(UIColor, Int)]()
        for hour in hours {
            var hourSplit = hour.characters.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true).map({String($0)})
            var dayText = "\(hour)"
            var color: UIColor = .orange
            if (hourSplit[1].trimmingCharacters(in: .whitespaces) == "Closed") {
                color = .red
            }
            if (hourSplit[0] == localDay) {
                if let openNow = openingHours["open_now"] as? Bool  {
                    color = (openNow) ? UIColor(red: 85.0/255.0, green: 210.0/255.0, blue: 88.0/255.0, alpha: 1.0) : .red
                    dayText += (openNow) ? " (Open!)" : " (Closed!)"
                }
            }
            tupMap[hourSplit[0]] = (color, dayText.characters.count)
            text += dayText + "\n"
        }
        let mutableString = NSMutableAttributedString(string: text)
        var start = 0
        for hour in hours {
            var hourSplit = hour.characters.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true).map({String($0)})
            let (color, count) = tupMap[hourSplit[0]]!
            mutableString.addAttribute(NSForegroundColorAttributeName, value: color, range: NSRange(location: start, length: count))
            start += count + 1
        }
        callback(mutableString)
    }


    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        handleTapOnInfoWindow()
    }
    
    
}


//extension for username creation
extension MapViewController {
    
    //performs callback(true) and add to db if username given is valid else callback(false)
    func addUsernameToFirebase(username: String, callback: @escaping (Bool)->Void) {
        let dbRef = self.ref!
        let usernamePath = "usernames/\(username)"
        dbRef.child(usernamePath).observeSingleEvent(of: .value, with: {[weak self] (snap) in
            
            if snap.exists() {
                //username already taken
                callback(false)
                return
            }
            //set username
            dbRef.child(usernamePath).setValue(Auth.auth().currentUser!.uid, withCompletionBlock: {
                (err, _) in
                if let err = err {
                    print("ERROR ON WRITING TO DB \(err.localizedDescription)")
                    callback(false)
                }
                else {
                    print("NO ERROR ON WRITE")
                    dbRef.child("users").child(Auth.auth().currentUser!.uid).child("username").setValue(username)
                    //add username to uid field
                    dbRef.child("users").child(Auth.auth().currentUser!.uid).child("name").setValue(self!.preferredNameField.text ?? "") //add preferred to uid field
                    //!! should we handle the case where the write is not guaranteed and someone else might write first
                    self!.userName = username
                    print("ADDED TO FIREBASE ")
                    callback(true)
                }

            })
        })
        
    }
    
    
    //functon to pass into closure of addUsernameToFirebase
    func addUsernameAttemptHandler(created: Bool) {
        if created {
            //dismiss userview, print welcome message via alert vc
            self.animateOutUserInputScreen(completion: {Utils.displayAlert(with: self, title: "Welcome", message: "You are now registered with FriendFinder", text: "Ok")})
        }
        else {
            userViewLabel.text = "Username already taken. Please try again"
            userViewLabel.textColor = UIColor.red
        }
    }
    
    //target function for username button
    func createUsernameButtonAction(sender: UIButton) {
        guard let username = userNameField.text else {
            return //username empty
        }
        addUsernameToFirebase(username: username, callback: {[weak self] (created) in
            DispatchQueue.main.async { self?.addUsernameAttemptHandler(created: created) }
        })
        
    }
    
}




