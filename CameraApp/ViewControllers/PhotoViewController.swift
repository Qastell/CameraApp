//
//  PhotoViewController.swift
//  CameraApp
//
//  Created by Кирилл Романенко on 11.11.2020.
//

import UIKit
import AVFoundation

class PhotoViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    let captureSession = AVCaptureSession()
    var previewLayer: CALayer!
    var captureDevice: AVCaptureDevice?
    var takePhoto = false
    @IBOutlet weak var photoButton: UIButton!
    var completion: ((UIImage) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoButton.layer.cornerRadius = photoButton.frame.width/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkAccess()
        prepareCamera()
    }
    
    func checkAccess() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response{
                
                print("access")
                
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Camera", message: "Camera access is absolutely necessary to use this app", preferredStyle: .alert)
                    
                    let showSettings = UIAlertAction(title: "go to settings", style: .default, handler: { action in
                        self.goToSettings()
                    })
                    
                    let goBack = UIAlertAction(title: "go back", style: .cancel) { action in
                        self.goBack()
                    }
                    
                    alert.addAction(showSettings)
                    alert.addAction(goBack)
                    
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func goToSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    func goBack() {
        DispatchQueue.main.async {
            let image = UIImage(named: "alex")
            if let completion = self.completion, let image = image {
                completion(image)
            }
            self.navigationController?.popViewController(animated: true)
            self.stopSession()
        }
    }
    
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let avalaibleDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        captureDevice = avalaibleDevices.first
        beginSession()
    }
    
    func beginSession() {
        do {
            if let captureDevice = captureDevice {
                let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(captureDeviceInput)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.layer.frame
        captureSession.startRunning()
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String) : NSNumber(value: kCVPixelFormatType_32BGRA)]
        
        dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }
        
        captureSession.commitConfiguration()
        
        let queue = DispatchQueue(label: "com.MRQ.captureQueue")
        dataOutput.setSampleBufferDelegate(self, queue: queue)
        
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        takePhoto = true
        
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if takePhoto {
            takePhoto = !takePhoto
            DispatchQueue.main.async {
                if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer), let completion = self.completion {
                    completion(image)
                }
                self.navigationController?.popViewController(animated: true)
                self.stopSession()
            }
            
        }
        
    }
    
    func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetHeight(pixelBuffer)
            
            let imageRect = CGRect(x: 0, y: 0, width: width, height: height)
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
    }
    
    func stopSession() {
        self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
    }
}
