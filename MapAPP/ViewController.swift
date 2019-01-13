import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var buttonPressed: UIButton!
    
    // This will be used to identify our locations for pins etc
    var coordinate2D: CLLocationCoordinate2D?
    
    // Defines how zoomed in we are on the map
    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        
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
                destination.preferredContentSize = CGSize(width: 250, height: 100)
                
                
                let popPresentationCTRL = destination.popoverPresentationController
                popPresentationCTRL?.delegate = self
                
                // Centralizing our popover instead of it anchoring in top left corner
                popPresentationCTRL?.sourceView = self.view
                popPresentationCTRL?.sourceRect = CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0)
               

                
                
            }
        }
    }
    
    func addAnnotation(name:String) {
        if let coordinate = coordinate2D {
            let annotation = MyAnno(title: name, subtitle: "Subtitle", coordinate: coordinate)
            mapView.addAnnotation(annotation)
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
