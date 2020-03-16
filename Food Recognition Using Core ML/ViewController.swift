//
//  ViewController.swift
//  Food Recognition Using Core ML
//
//  Created by MAHMOUD on 3/16/20.
//  Copyright © 2020 MAHMOUD. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var confideceLabel: UILabel!
    let imagePicker = UIImagePickerController()

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = userPickedImage
            // convert UIimage to CIimage to be used by model
            guard let ciimage = CIImage(image: userPickedImage) else{
                fatalError("Can not Convert UIimage to CiImage")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    func detect(image:CIImage){
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model)else{
            fatalError("Load CorML Model failed")
        }
        //make request to model
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else{
                fatalError("error with loading results")
            }
            if  let firstResult = results.first{
             
              self.navigationItem.title = firstResult.identifier
                
            self.confideceLabel.text = "accuracy:\((firstResult.confidence)*100 ) %"
               
            }
        }
         // make handler and perform request
        let handler = VNImageRequestHandler(ciImage:image)
        do{
           try handler.perform([request])
        }
        catch{
            print(error)
        }
    }
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        present(imagePicker,animated: true,completion: nil)
    }
    
}

