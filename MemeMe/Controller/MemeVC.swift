//
//  ViewController.swift
//  MemeMe
//
//  Created by Abdualziz Aljuaid on 12/04/2019.
//  Copyright © 2019 Abdualziz Aljuaid. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mainImage: UIImageView!
    var memedImage: UIImage!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    var meme: Meme!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //shareButton.isEnabled = false
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        setTextField()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    
    func setTextField(){
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth:  0.80
        ]
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .center
        topTextField.autocapitalizationType = .allCharacters
        
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = .center
        bottomTextField.autocapitalizationType = .allCharacters
    }
    
    
    func save(){
        let tempMeme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: mainImage.image!, memedImage: memedImage)
        meme = tempMeme
    }
    
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        navigationController?.isToolbarHidden = true
        navigationController?.isNavigationBarHidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        navigationController?.isToolbarHidden = true
        navigationController?.isNavigationBarHidden = true
      
        return memedImage
    }
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        let memeImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                print(error!)
                return
            }
            self.save()
        }

        self.present(activityViewController, animated: true, completion: nil)
    }
 
    
    
    
    //MARK:- ShiftingViewController
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    @objc func keyboardWillShow(_ notification:Notification) {
        
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    @objc func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}











//MARK:- ImageViewDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            mainImage.image = image
            dismiss(animated: true, completion: nil)
        }
    }
    
    
     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}













//MARK:- TextFieldDelegate
extension ViewController: UITextFieldDelegate{
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == topTextField {
            topTextField.text = ""
        }
        else if textField == bottomTextField {
            bottomTextField.text = ""
        }
    }
}
