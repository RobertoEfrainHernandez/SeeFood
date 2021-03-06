//
//  ViewController.swift
//  SeeFood
//
//  Created by Roberto Hernandez on 2/7/18.
//  Copyright © 2018 Roberto Efrain Hernandez. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary /* For simulator */
        //imagePicker.sourceType = .camera /* Use if not on simulator */
        imagePicker.allowsEditing = false
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        /* Convert UIImage to CIImage */
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
           imageView.image = userPickedImage
        
            guard let ciImage = CIImage(image: userPickedImage) else { fatalError("Could not convert UIImage to CIImage") }
            
            /* Pass the Image into detect func */
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        /* Load our model from Inception v3 */
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {fatalError("Loading CoreML Model Failed")}
        /* Make a request to classify the model */
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {fatalError("Model failed to process image")}
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    
                self.navigationItem.title = "Hotdog!"
                    
                }
            } else {
                self.navigationItem.title = "Not a Hotdog"
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do
        {
        try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
}

