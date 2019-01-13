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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cameraBtn(_ sender: Any) {
        print("Take a nice photo, dude")
    }
    
    
    @IBAction func albumBtn(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        parentView?.addAnnotation(name: textField.text!, subtitle: shortDescriptionField.text!, text: descriptionField.text!, picture: photo)
        parentView?.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        photo = image!
        dismiss(animated: true, completion: nil)

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
