//
//  PopupViewController.swift
//  MapAPP
//
//  Created by admin on 21.09.18.
//  Copyright © 2018 admin. All rights reserved.
//
import UIKit

class PopupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var shortDescriptionField: UITextField! // Holds subtitle
    @IBOutlet weak var descriptionField: UITextView! // Holds descriptionText
    @IBOutlet weak var textField: UITextField! // Holds name / title
    
    var parentView: ViewController?
    
    var imagePicker = UIImagePickerController()
    
    var photo = UIImage()
    
    var type = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cameraBtn(_ sender: Any) {
        print("Take a nice photo, dude")
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func albumBtn(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        parentView?.addAnnotation(name: textField.text!, subtitle: shortDescriptionField.text!, text: descriptionField.text!, picture: photo, type: type)
        parentView?.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            photo = image
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet var typeButtons: [UIButton]!
    @IBAction func handleSelection(_ sender: Any) {
        typeButtons.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    enum Types: String {
        case bar = "Bar"
        case restaurant = "Restaurant"
        case attraction = "Attraction"
        case hotel = "Hotel"
    }
    @IBAction func typePressed(_ sender: UIButton) {
        guard let title = sender.currentTitle, let types = Types(rawValue: title) else {
            return
        }
        switch types {
        case .bar:
            self.type = "Bar"
            typeButton.setTitle("Bar", for: .normal)
        case .restaurant:
            self.type = "Restaurant"
            typeButton.setTitle("Restaurant", for: .normal)
        case .attraction:
            self.type = "Attraction"
            typeButton.setTitle("Attraction", for: .normal)
        case .hotel:
            self.type = "Hotel"
            typeButton.setTitle("Hotel", for: .normal)
        default:
            print("default")
        }
        handleSelection(self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
