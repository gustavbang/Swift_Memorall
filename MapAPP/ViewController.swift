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
    
    //array til at gemme DB data
    var annotations = [MyAnno]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Firebase
        dbRef = Database.database().reference().child("pins")
        storage = Storage.storage()
        
        loadPins()

        
        locationManager.delegate = self
        mapView.delegate = self
        
        // Asks if you allow GPS usage
        locationManager.requestWhenInUseAuthorization()
        
        // How accurated the GPS is.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        print("New location: \(location)")
        
        setRegion(location: location.coordinate)
    }
    
    func setRegion(location: CLLocationCoordinate2D) {
        let reg = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(reg, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        default:
            mapView.showsUserLocation = false
            return
        }
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
        
        // Shows custom picture in pin
        let detailImageSize = CGSize(width: 150, height: 150)
        UIGraphicsBeginImageContext(detailImageSize)
        annotation.image!.draw(in: CGRect(x: 0, y: 0, width: detailImageSize.width, height: detailImageSize.height))
        let annotionImageResized = UIGraphicsGetImageFromCurrentImageContext()
        annotationView.leftCalloutAccessoryView = UIImageView(image: annotionImageResized)
        
        // Makes us able to show extra info, such as image or text
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "annoDetail") as! AnnoDetailViewController
        
        vc.annotation = view.annotation as? MyAnno
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func longPressed(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .ended { // So you dont make more pins per click
            print("You pressed loooonng time")
            let location = recognizer.location(in: mapView) // CGPoint type, needs to be converted to coordinate
            coordinate2D = mapView.convert(location, toCoordinateFrom: mapView) // Converting
            // Launch popSegue
            self.performSegue(withIdentifier: "popSegue", sender: self)
        }
    }
    
    @IBAction func goButtonPressed(_ sender: Any) {
        let geoCoder = CLGeocoder() // Magic apple device thingy
        if let adr = textField.text {
            geoCoder.geocodeAddressString(adr) { (placemarks, error) in
                guard let places = placemarks, let location = places.first?.location else {
                    print("Incorrect location - use correct format 'Lillebjergvej 24, Hundested'")
                    return
                } // We will get here if adr (and location) is of correct format
                DispatchQueue.main.async {
                    self.setRegion(location: location.coordinate)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 1. Check if correct segue
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
        }
    }
    
    func addAnnotation(name: String, subtitle: String, text: String,
                       picture: UIImage, type: String) {
        if let coordinate = coordinate2D {
            let annotation = MyAnno(title: name, subtitle: subtitle, coordinate: coordinate)
            annotation.image = picture
            annotation.descriptionText = text
            annotation.type = type
            mapView.addAnnotation(annotation)
            
            let latitude = String(coordinate.latitude)
            let longitude = String(coordinate.longitude)
            
            //her kalder vi storage metode og får et imageURL tilbage
            uploadPinImage(image: picture) { (imageUrl) in
            }
            
            //dette imageURL er en reference, som vi også gerne vil gemme i DB
            let newPinRef = dbRef?.childByAutoId()
            newPinRef?.setValue(["title": name, "subtitle": subtitle, "latitude": latitude, "longitude": longitude, "type": type, "descriptionText": text])
        }
    }
    
    
    
    func uploadPinImage(image: UIImage, completion: @escaping (String) -> Void) {
        print("1")
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            return
        }
        
        //unique id
        let imageName = NSUUID.init()
        let storageRef = Storage.storage().reference().child("pinImages").child("\(imageName)")
        
        //til at få metadata
        let meta = StorageMetadata()
        meta.contentType = "image/png"
        
        //laver en task
        let uploadTask = storageRef.putData(imageData, metadata: meta) { (data, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                if (error == nil) {
                    if let downloadUrl = url {
                        // Make you download string
                        let imageUrl = downloadUrl.absoluteString
                        
                        
                        completion(imageUrl)
                    }
                } else {
                    print("fail")
                }
            })
            print(data ?? "NO METADATA")
            print(error ?? "NO ERROR")
        }
    }
    
    func loadPins() {
        dbRef?.queryOrdered(byChild: "title").observe(.value, with: { (snapshot) in
            //tømmer
            self.annotations = [MyAnno]()
            for child in snapshot.children {
                if let data = child as? DataSnapshot {
                    let dict = data.value as! [String: String]
                    
                    let id = data.key
                    let title = dict["title"] ?? ""
                    let subtitle = dict["subtitle"] ?? ""

                    var coordinate: CLLocationCoordinate2D
                    if let lat = dict["latitude"], let doubleLat = Double(lat), let long = dict["longitude"], let doubleLong = Double(long) {
                        coordinate = CLLocationCoordinate2D(latitude: doubleLat, longitude: doubleLong)
                    } else {
                        coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
                    }
                    let type = dict["type"] ?? ""
                    let descriptionText = dict["descriptionText"] ?? ""
                
                
                    let pin = MyAnno(id: id, title: title, subtitle: subtitle, coordinate: coordinate, type: type, descriptionText: descriptionText)
                    
                    //fylder default image
                    if pin.image == nil {
                        pin.image = UIImage(named: "download")
                    }
                    
                    self.annotations.append(pin)
                    self.mapView.addAnnotation(pin)

                    
                    
                }
            }
        })
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
