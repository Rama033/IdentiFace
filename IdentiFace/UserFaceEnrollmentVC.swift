//
//  UserFaceEnrollmentVC.swift
//  IdentiFace
//
//  Created by CE-MAC-23 on 2018. 8. 22..
//  Copyright © 2018년 CE-MAC-23. All rights reserved.
//

import UIKit
import AVFoundation

class UserFaceEnrollmentVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    let cameraSession = AVCaptureSession()
    let sync = DataSync()
    
    let rate = 10    // 전송 사진 비율
    
    var userFormVC: UserFormVC!
    var name: String!
    var count = 0
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.cameraSession)
        preview.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        preview.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        return preview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 28))
        title.font = UIFont.boldSystemFont(ofSize: 15)
        title.textAlignment = .center
        title.text = "얼굴 인식이 진행중입니다."
        let subtitle = UILabel(frame: CGRect(x: 0, y: 25, width: self.view.frame.width, height: 12))
        subtitle.font = UIFont.boldSystemFont(ofSize: 12)
        subtitle.textAlignment = .center
        subtitle.text = "잠시만 기다려주세요..."
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        view.addSubview(title)
        view.addSubview(subtitle)
        self.navigationItem.titleView = view
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.completeUpload(_:)), name: NSNotification.Name(rawValue: "completeUpload"), object: nil)
        
        self.cameraSession.sessionPreset = AVCaptureSession.Preset.medium
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) else { return }
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            self.cameraSession.beginConfiguration()
            
            if (self.cameraSession.canAddInput(deviceInput) == true) {
                self.cameraSession.addInput(deviceInput)
            }
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if(self.cameraSession.canAddOutput(dataOutput) == true) {
                self.cameraSession.addOutput(dataOutput)
            }
            
            self.cameraSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.rama033.IdentiFace")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
            self.view.layer.addSublayer(self.previewLayer)
            
            self.cameraSession.startRunning()
            self.sync.checkStart()

        } catch let error as NSError {
            NSLog("%s, %s", error, error.description)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver("completeUpload")
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.count = self.count + 1
        if self.count % self.rate == 0 {
            connection.videoOrientation = AVCaptureVideoOrientation.portrait
            
            let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
            
            let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
            
            var image : UIImage = self.convert(cmage: ciimage)
            if image.size.width > image.size.height {
                image = image.rotate(radians: .pi / 2.0)
            }
            sync.uploadData(image, name: self.name)
        }
    }
    
    func convert(cmage:CIImage) -> UIImage {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }

    @objc func completeUpload(_ sender: Any) {
        self.cameraSession.stopRunning()
        let sync = DataSync()
        sync.getImage(vc: self.userFormVC)

        self.tabBarController?.tabBar.isHidden = false
        self.userFormVC.imageAddingProgress = true
        self.userFormVC.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .save, target: self.userFormVC, action: #selector(self.userFormVC.saveUserData(_:))), animated: false)
        self.userFormVC.navigationItem.setHidesBackButton(true, animated: false)
        self.userFormVC.userName.isUserInteractionEnabled = false
        self.userFormVC.userName.font = UIFont.boldSystemFont(ofSize: 17)
        _ = self.navigationController?.popViewController(animated: true)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
