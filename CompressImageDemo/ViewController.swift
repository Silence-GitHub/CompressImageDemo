//
//  ViewController.swift
//  CompressImageDemo
//
//  Created by Kaibo Lu on 2017/2/19.
//  Copyright © 2017年 Kaibo Lu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageSizeTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    private var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select image", style: .plain, target: self, action: #selector(selectImage))
    }
    
    @objc private func selectImage() {
        view.endEditing(true)
        
        let sourceType: UIImagePickerControllerSourceType = .photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let picker: UIImagePickerController = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = sourceType
            present(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func compressButtonClicked(_ sender: UIButton) {
        view.endEditing(true)
        
        guard let image = image,
            let text = imageSizeTextField.text,
            let textIntValue = Int(text) else { return }
        
        let imageByte: Int = textIntValue * 1024
        switch sender.tag {
        case 1000:
            imageView.image = ViewController.compressImageQuality(image, toByte: imageByte)
        case 1001:
            imageView.image = ViewController.compressImageSize(image, toByte: imageByte)
        default:
            imageView.image = ViewController.compressImage(image, toByte: imageByte)
        }
    }
    
    static func compressImageQuality(_ image: UIImage, toByte maxLength: Int) -> UIImage {
        var compression: CGFloat = 1
        guard var data = UIImageJPEGRepresentation(image, compression),
            data.count > maxLength else { return image }
        print("Before compressing quality, image size =", data.count / 1024, "KB")
        
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0..<6 {
            compression = (max + min) / 2
            data = UIImageJPEGRepresentation(image, compression)!
            print("Compression =", compression)
            print("In compressing quality loop, image size =", data.count / 1024, "KB")
            if CGFloat(data.count) < CGFloat(maxLength) * 0.9 {
                min = compression
            } else if data.count > maxLength {
                max = compression
            } else {
                break
            }
        }
        print("After compressing quality, image size =", data.count / 1024, "KB")
        return UIImage(data: data)!
    }
    
    static func compressImageSize(_ image: UIImage, toByte maxLength: Int) -> UIImage {
        guard var data = UIImageJPEGRepresentation(image, 1) else { return image }
        print("Before compressing size, image size =", data.count / 1024, "KB")
        
        var resultImage: UIImage = image
        var lastDataLength: Int = 0
        while data.count > maxLength, data.count != lastDataLength {
            lastDataLength = data.count
            let ratio: CGFloat = CGFloat(maxLength) / CGFloat(data.count)
            print("Ratio =", ratio)
            let size: CGSize = CGSize(width: Int(resultImage.size.width * sqrt(ratio)),
                                      height: Int(resultImage.size.height * sqrt(ratio)))
            UIGraphicsBeginImageContext(size)
            resultImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            resultImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            data = UIImageJPEGRepresentation(resultImage, 1)!
            print("In compressing size loop, image size =", data.count / 1024, "KB")
        }
        print("After compressing size loop, image size =", data.count / 1024, "KB")
        return resultImage
    }
    
    static func compressImage(_ image: UIImage, toByte maxLength: Int) -> UIImage {
        var compression: CGFloat = 1
        guard var data = UIImageJPEGRepresentation(image, compression),
            data.count > maxLength else { return image }
        print("Before compressing quality, image size =", data.count / 1024, "KB")
        
        // Compress by size
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0..<6 {
            compression = (max + min) / 2
            data = UIImageJPEGRepresentation(image, compression)!
            print("Compression =", compression)
            print("In compressing quality loop, image size =", data.count / 1024, "KB")
            if CGFloat(data.count) < CGFloat(maxLength) * 0.9 {
                min = compression
            } else if data.count > maxLength {
                max = compression
            } else {
                break
            }
        }
        print("After compressing quality, image size =", data.count / 1024, "KB")
        var resultImage: UIImage = UIImage(data: data)!
        if data.count < maxLength { return resultImage }
        
        // Compress by size
        var lastDataLength: Int = 0
        while data.count > maxLength, data.count != lastDataLength {
            lastDataLength = data.count
            let ratio: CGFloat = CGFloat(maxLength) / CGFloat(data.count)
            print("Ratio =", ratio)
            let size: CGSize = CGSize(width: Int(resultImage.size.width * sqrt(ratio)),
                                      height: Int(resultImage.size.height * sqrt(ratio)))
            UIGraphicsBeginImageContext(size)
            resultImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            resultImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            data = UIImageJPEGRepresentation(resultImage, compression)!
            print("In compressing size loop, image size =", data.count / 1024, "KB")
        }
        print("After compressing size loop, image size =", data.count / 1024, "KB")
        return resultImage
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.image = image
    }

}

