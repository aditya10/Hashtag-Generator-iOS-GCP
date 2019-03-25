//
//  ViewController.swift
//  Hashtagger
//
//  Created by Aditya Chinchure on 2019-03-24.
//  Copyright © 2019 Aditya Chinchure. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var hashtagBox: UITextView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self
    }

    @IBAction func uploadBtnPressed(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    @IBAction func copyBtnPressed(_ sender: Any) {
        UIPasteboard.general.string = hashtagBox.text
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            imageView.image = image
            let db = Firestore.firestore()
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imageName = "Image-ID-"+randomString(length: 8)+".jpeg"
            let imageRef = storageRef.child(imageName)
            print("created ref")
            imageRef.putFile(from: imageURL, metadata: nil) { metadata, error in
                if let error = error {
                    print("upload error")
                    print(error)
                } else {
                    print("upload success!")
                    db.collection("images").document(imageName)
                        .addSnapshotListener { documentSnapshot, error in
                            if let error = error {
                                print("error occurred\(error)")
                            } else {
                                if (documentSnapshot?.exists)! {
                                    self.createHashtags(data: documentSnapshot?.data())
                                    print(documentSnapshot?.data())
                                } else {
                                    print("waiting for Vision API data...")
                                    self.hashtagBox.text = "Waiting for Vision..."
                                }
                            }
                    }
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }

    func createHashtags(data: [String: Any]?) {
        guard let data = data else {
            self.hashtagBox.text = "No hashtags found"
            return
        }
        
        let labels = data["labels"] as? NSArray ?? []
        
        var hashtagArr:[String] = []
        
        for i in labels {
            let entity = i as! NSDictionary
            let entityName = entity["description"] as! String
            hashtagArr.append(entityName)
        }
        createHashtagsFromArray(hashtagArr: hashtagArr)
    }
    
    func createHashtagsFromArray(hashtagArr:[String]) {
        if (hashtagArr.count == 0){
            print("array empty")
            self.hashtagBox.text = "No hashtags found"
            return
        }
        var hashtagStr = ""
        
        for tag in hashtagArr {
            let formattedTag = "#"+tag.replacingOccurrences(of: " ", with: "")+" "
            hashtagStr.append(formattedTag)
        }
        self.hashtagBox.text = hashtagStr
    }

}

