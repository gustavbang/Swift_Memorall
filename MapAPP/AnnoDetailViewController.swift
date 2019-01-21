//
//  AnnoDetailViewController.swift
//  MapAPP
//
//  Created by admin on 13/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class AnnoDetailViewController: UIViewController {

    var annotation: MyAnno!
    @IBOutlet weak var pinDescription: UITextView!
    @IBOutlet weak var pinTitle: UILabel!
    @IBOutlet weak var pinPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // LOAD CONTENT OF PIN HERE
        pinTitle.text = annotation.title
        pinDescription.text = annotation.descriptionText
        pinPhoto.image = annotation.image

        // Do any additional setup after loading the view.
    }
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
