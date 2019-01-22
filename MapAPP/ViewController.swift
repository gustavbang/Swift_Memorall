import UIKit
import MapKit
import CoreLocation

import FirebaseStorage
import FirebaseDatabase

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var buttonPressed: UIButton!
    
    // This will be used to identify our locations for pins etc
    var coordinate2D: CLLocationCoordinate2D?
    
    // Defines how zoomed in we are on the map
    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    
    let locationManager = CLLocationManager()
    
    //Firebase
    var dbRef: DatabaseReference?
    var storage: Storage?
    
    // Array for our annotations
    var annotations = [MyAnno]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mapView.delegate = self
        
        //Firebase
        dbRef = Database.database().reference().child("pins")
        storage = Storage.storage()
        
        // Initial load and observation of new values (pins)
        loadPins()
        
        // Asks if you allow GPS usage
        locationManager.requestWhenInUseAuthorization()
        
        // How accurated the GPS is.
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                
        // These two observe if keyboard is shown/hidden
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        navigationItem.title = "Map"

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            setRegion(location: location.coordinate)
        }
    }
    
    func setRegion(location: CLLocationCoordinate2D) {
        let reg = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(reg, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
//            locationManager.startUpdatingLocation()
//            locationManager.startUpdatingHeading()
        default:
            mapView.showsUserLocation = false
            return
        }
    }
    
    // In case something goes wrong with locationmanager
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = MKAnnotationView()
        
        // Shouldnt be necessary, only if you use different annotations (fx custom and default)
        guard let annotation = annotation as? MyAnno
            else {
                return nil
        }
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier) {
            annotationView = dequedView
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
        }
        
        //we force unwrap because we KNOW the image will always be there (it is stored locally).
        var pinImage = UIImage()
        switch annotation.type {
        case "Bar":
            pinImage = UIImage(named: "bar")!
        case "Restaurant":
            pinImage = UIImage(named: "restaurant")!
        case "Attraction":
            pinImage = UIImage(named: "attraction")!
        case "Hotel":
            pinImage = UIImage(named: "hotel")!
        default:
            pinImage = UIImage(named: "default")!
        }
        
        let pinImageSize = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContext(pinImageSize)
        pinImage.draw(in: CGRect(x: 0, y: 0, width: pinImageSize.width, height: pinImageSize.height))
        let resizedPin = UIGraphicsGetImageFromCurrentImageContext()
        annotationView.image = resizedPin
        
        //Shows one line of our subtitle in pin
        let description = UILabel()
        description.numberOfLines = 1
        description.text = annotation.subtitle
        annotationView.detailCalloutAccessoryView = description
        annotationView.rightCalloutAccessoryView = UIButton(type: .infoLight)
        
        // Shows custom picture in pin through a couple of steps
        let imageUrl:URL = URL(string: annotation.imageUrl!)!
        
        // Start background thread so that image loading does not make app unresponsive
        DispatchQueue.global(qos: .userInitiated).async {
            
            // Getting our annotations image as NSData
            let imageData: NSData = NSData(contentsOf: imageUrl)!
            
            // When background task downloaded the data, pin needs to be updated on main_queue
            DispatchQueue.main.async {
                
                // Initializing our image with the data from imageData
                let image = UIImage(data: imageData as Data)
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: annotationView.frame.height * 2, height: annotationView.frame.height * 2))
                
                imageView.image = image
                imageView.contentMode = .scaleToFill
                
                annotationView.leftCalloutAccessoryView = imageView
            }
        }
        
        // Makes us able to show extra info, such as image or text
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "annoDetail") as! AnnoDetailViewController
        
        vc.annotation = view.annotation as? MyAnno
        self.present(vc, animated: true, completion: nil)
    }
    
    // Pin creations first step - pressing the screen where u want pin
    @IBAction func longPressed(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .ended { // So you dont make more pins per click
            print("Pin creation initialized")
            let location = recognizer.location(in: mapView) // CGPoint type, needs to be converted to coordinate
            coordinate2D = mapView.convert(location, toCoordinateFrom: mapView) // Converting
            
            // Launch popSegue to type info about pin and save
            self.performSegue(withIdentifier: "popSegue", sender: self)
        }
    }
    
    // Reset map to where you are
    @IBAction func currentLocationBtn(_ sender: Any) {
        print("currentLocationBtn pressed")
        if locationManager.location?.coordinate != nil {
            self.setRegion(location: (locationManager.location?.coordinate)!)
        }
    }
    
    
    // Search button
    @IBAction func goButtonPressed(_ sender: Any) {
        let geoCoder = CLGeocoder() // Magic apple device thingy
        if let adr = textField.text {
            geoCoder.geocodeAddressString(adr) { (placemarks, error) in
                guard let places = placemarks, let location = places.first?.location else {
                    
                    // Popup message to show user
                    let alert = UIAlertController(title: "Incorrect address or format", message: "Remember to use correct format, for example 'Lillebjergvej 24, Hundested", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                    
                    return
                } // We will get here if adr (and location) is of correct format
                DispatchQueue.main.async {
                    self.setRegion(location: location.coordinate)
                }
            }
        }
    }
    
    func addAnnotation(name: String, subtitle: String, text: String,
                       picture: UIImage, type: String) {
        if let coordinate = coordinate2D {
            let latitude = String(coordinate.latitude)
            let longitude = String(coordinate.longitude)
            
            // uploadPinImage is called to storage image and returns an imageURL on completion
            // imageURL is the reference to the pins image and are saved in our database
            uploadPinImage(image: picture) { (imageUrl) in
                let newPinRef = self.dbRef?.childByAutoId()
                newPinRef?.setValue(["title": name, "subtitle": subtitle, "latitude": latitude, "longitude": longitude, "imageUrl": imageUrl, "type": type, "descriptionText": text])
            }
        }
    }
    
    // Uploads pin image and completion makes us able to return imageurl for use in
    // addannotation to save it in database
    func uploadPinImage(image: UIImage, completion: @escaping (String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            return
        }
        
        // Unique id for picture name
        let imageName = NSUUID.init()
        let storageRef = Storage.storage().reference().child("pinImages").child("\(imageName)")
        
        // To get metadata
        let meta = StorageMetadata()
        meta.contentType = "image/png"
        
        // Create our upload task with putData
        let uploadTask = storageRef.putData(imageData, metadata: meta) { (data, error) in
            if error != nil {
                print(error!)
                return
            }
            
            // Example of downloadUrl result:
            // https://firebasestorage.googleapis.com/v0/b/memorall.appspot.com/o/pinImages%2F494BFF52-AE02-412F-888C-75AE61EA2415?alt=media&token=9ed8b82b-7dff-402d-bd28-87edd77b7660
            storageRef.downloadURL(completion: { (url, error) in
                if (error == nil) {
                    if let downloadUrl = url {
                        let imageUrl = downloadUrl.absoluteString
                        completion(imageUrl) // "returns" imageUrl as string
                    }
                } else {
                    print("Failure", error!)
                }
            })
            print(data ?? "NO METADATA")
            print(error ?? "NO ERROR")
        }
    }
    
    // Queries the database for all pin on load and if any changes happen
    func loadPins() {
        dbRef?.queryOrdered(byChild: "title").observe(.value, with: { (snapshot) in
            // Empties our annotations array, so it is not dublicated
            self.mapView.removeAnnotations(self.annotations)
            self.annotations = [MyAnno]()
            
            // Each child is a MyAnno object, or will be soon ;-)
            for child in snapshot.children {

                if let data = child as? DataSnapshot {

                    let dict = data.value as! [String: String] // Ex. dict["title"] has title as value
                    
                    let id = data.key
                    let title = dict["title"] ?? ""
                    let subtitle = dict["subtitle"] ?? ""
                    
                    // Putting together our coordinate with longitude and latitude
                    var coordinate: CLLocationCoordinate2D
                    if let lat = dict["latitude"], let doubleLat = Double(lat), let long = dict["longitude"], let doubleLong = Double(long) {
                        coordinate = CLLocationCoordinate2D(latitude: doubleLat, longitude: doubleLong)
                    } else {
                        coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
                    }
                    
                    let imageUrl = dict["imageUrl"] ?? ""
                    let type = dict["type"] ?? ""
                    let descriptionText = dict["descriptionText"] ?? ""
                    
                    let pin = MyAnno(id: id, title: title, subtitle: subtitle, imageUrl: imageUrl, coordinate: coordinate, type: type, descriptionText: descriptionText)
                    
                    // If imageUrl is not "", then we have a custom picture
                    if (pin.imageUrl != "") {
                        let storageRef = Storage.storage().reference(forURL: pin.imageUrl!)
                        storageRef.getData(maxSize: 8 * 1024 * 1024, completion: { (data, error) in
                            if let pic = UIImage(data: data!) {
                                pin.image = pic
                            }
                        })
                    }
                    
                    // Default image, stored locally in assets
                    if pin.image == nil {
                        pin.image = UIImage(named: "download")
                    }
                    
                    // Adding pin to both array and map
                    self.annotations.append(pin)
                    self.mapView.addAnnotation(pin)
                }
            }
        })
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check if correct segue
        if let id = segue.identifier {
            if id == "popSegue" { // Securing correct segue
                let destination = segue.destination as! PopupViewController
                destination.parentView = self
                destination.preferredContentSize = CGSize(width: 300, height: 300)
                
                let popPresentationCTRL = destination.popoverPresentationController
                popPresentationCTRL?.delegate = self
                
                // Centralizing our popover instead of it anchoring in top left corner
                popPresentationCTRL?.sourceView = self.view
                popPresentationCTRL?.sourceRect = CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0)
            }
            if id == "showAnnoList" {
                let destination = segue.destination as! AnnoTableViewController
                destination.annotations = annotations
            }
        }
    }
    
    // Closing keyboard in searchfield if touch outside of it
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
    }
    
    // Customized so that keyboard showing moves view frame up
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    // Customized so that keyboard hiding moves view frame down
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
