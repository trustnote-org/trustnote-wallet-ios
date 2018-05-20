//
//  TNScanViewController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/18.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import AVFoundation

class TNScanViewController: UIViewController {
    
    let device = AVCaptureDevice.default(for: .video)
    
    var session = AVCaptureSession()
    
    var line: UIImageView?
    
    var maskView: UIView?
    
    var distance: CGFloat = 0.0
    
    var scanningCompletionBlock: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        creatControl()
        startScanning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addTimer()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopScanning()
    }
}

extension TNScanViewController {
    
    fileprivate func creatControl() {
        let scanW: CGFloat = kScreenW * 0.65
        let tabbarH: CGFloat = 64 + kSafeAreaBottomH
        let cornerW: CGFloat = 26.0
        let marginX: CGFloat = (kScreenW - scanW) * 0.5
        let maskH: CGFloat = kScreenH - tabbarH - kNavBarHeight
        let marginY: CGFloat = (maskH - scanW) * 0.5
        
        let topBarView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kNavBarHeight))
        topBarView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        view.addSubview(topBarView)
        
        let backBtn = UIButton(frame: CGRect(x: 0, y: kStatusbarH, width: 50, height: 44))
        backBtn.setTitle("返回", for: .normal)
        backBtn.setTitleColor(UIColor.white, for: .normal)
        backBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        backBtn.addTarget(self, action: #selector(TNScanViewController.goBack), for: .touchUpInside)
        topBarView.addSubview(backBtn)
        
        maskView = UIView(frame: CGRect(x: 0, y: kNavBarHeight, width: kScreenW, height: maskH))
        maskView?.backgroundColor = UIColor.clear
        view.addSubview(maskView!)
        
        for i in 0..<4 {
            let cover = UIView(frame: CGRect(x: 0, y: (marginY + scanW) * CGFloat(i), width: kScreenW, height: marginY))
            if i == 2 || i == 3 {
                cover.frame = CGRect(x: (marginX + scanW) * CGFloat(i - 2), y: marginY, width: marginX, height: scanW)
            }
            cover.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            maskView?.addSubview(cover)
        }
        
        let scanView = UIView(frame: CGRect(x: marginX, y: marginY, width: scanW, height: scanW))
        maskView?.addSubview(scanView)
        
        line = UIImageView(frame: CGRect(x: 0, y: 0, width: scanW, height: 2.0))
        drawLineForImageView(line!)
        scanView.addSubview(line!)
        
        let borderView = UIView(frame: CGRect(x: 0, y: 0, width: scanW, height: scanW))
        borderView.layer.borderColor = UIColor.white.cgColor
        borderView.layer.borderWidth = 1.0
        scanView.addSubview(borderView)
        
        for i in 0..<4 {
            let imgViewX = (scanW - cornerW) * CGFloat(i % 2)
            let imgViewY = (scanW - cornerW) * CGFloat(i / 2)
            let imgView = UIImageView(frame: CGRect(x: imgViewX, y: imgViewY, width: cornerW, height: cornerW))
            if (i == 0 || i == 1) {
                imgView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2 * Double(i)))
            } else {
                imgView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2 * Double(i - 1)))
            }
            drawImageForImageView(imgView)
            scanView.addSubview(imgView)
        }
        
        let tabBarView = UIView(frame: CGRect(x: 0, y: kScreenH - tabbarH, width: kScreenW, height: tabbarH))
        tabBarView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.addSubview(tabBarView)
        
        let lightBtn = UIButton(frame: CGRect(x: kScreenW - 100, y: 0, width: 100, height: tabbarH - kSafeAreaBottomH))
        lightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        lightBtn.setTitle("开启照明", for: .normal)
        lightBtn.setTitle("关闭照明", for: .selected)
        lightBtn.addTarget(self, action: #selector(TNScanViewController.lightBtnOnClick), for: .touchUpInside)
        tabBarView.addSubview(lightBtn)
    }
    
    fileprivate func drawLineForImageView(_ imageView: UIImageView) {
        let size = imageView.bounds.size
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let startColorComponents = UIColor.green.cgColor.components
        let endColorComponents = UIColor.white.cgColor.components
        let components = [startColorComponents![0], startColorComponents![1], startColorComponents![2], startColorComponents![3], endColorComponents![0], endColorComponents![1]]
        let locations = [CGFloat(0.0), CGFloat(1.0)]
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 2)
        context!.drawRadialGradient(gradient!, startCenter: CGPoint(x: size.width * 0.5, y: size.height * 0.5), startRadius: size.width * 0.25, endCenter: CGPoint(x: size.width * 0.5, y: size.height * 0.5), endRadius: size.width * 0.5, options: CGGradientDrawingOptions.drawsBeforeStartLocation)
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    fileprivate func drawImageForImageView(_ imageView: UIImageView) {
        UIGraphicsBeginImageContext(imageView.bounds.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setLineWidth(6.0)
        context!.setStrokeColor(UIColor.green.cgColor)
        context!.beginPath()
        context!.move(to: CGPoint(x: 0, y: imageView.bounds.size.height))
        context!.addLine(to: CGPoint.zero)
        context!.addLine(to: CGPoint(x: imageView.bounds.size.width, y: 0))
        context!.strokePath()
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}

extension TNScanViewController {
    fileprivate func startScanning() {
        
        do {
            ///  Create input and output stream
            guard let device = device else {
                return
            }
            let input = try AVCaptureDeviceInput(device: device)
            let output = AVCaptureMetadataOutput()
            output.rectOfInterest = CGRect(x: 0.1, y: 0, width: 0.9, height: 1)
            
            /// Setup delegate
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            
            session.canSetSessionPreset(AVCaptureSession.Preset.high)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            /// Set the code format supported by scavenging
            output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr,AVMetadataObject.ObjectType.ean13,AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.code128]
            
            DispatchQueue.main.async(execute: {
                let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                previewLayer.frame = self.view.layer.bounds
                self.view.layer.insertSublayer(previewLayer, at: 0)
                self.session.startRunning()
            })
            
        } catch let error as NSError  {
            print("errorInfo\(error.domain)")
        }
    }
    
    fileprivate func stopScanning() {
        session.stopRunning()
    }
    
    @objc fileprivate func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func lightBtnOnClick(btn: UIButton) {
        guard let device = device else {
            return
        }
        guard device.hasTorch else {
            return
        }
        btn.isSelected = !btn.isSelected
        do {
            try device.lockForConfiguration()
        } catch let error as NSError {
            print("errorInfo\(error.domain)")
        }
        device.torchMode = btn.isSelected ? .on : .off
        device.unlockForConfiguration()
    }
}

extension TNScanViewController {
    
    fileprivate func addTimer() {
        TNTimerHelper.shared.scheduledDispatchTimer(WithTimerName: kScanCodeTimer, timeInterval: 0.01, queue: .main, repeats: true) {[unowned self] in
            
            self.distance += 1
            if self.distance > kScreenW * 0.65 {
                self.distance = 0.0
            }
            self.line?.y = self.distance
        }
    }
    
    fileprivate func stopTimer() {
        TNTimerHelper.shared.cancleTimer(WithTimerName: kScanCodeTimer)
        distance = 0.0
        line?.y = 0.0
    }
}

extension TNScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            session.stopRunning()
            let object = metadataObjects[0]
            let resultStr: String = (object as AnyObject).stringValue
            if let url = URL(string: resultStr) {
                if UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                    navigationController?.popViewController(animated: false)
                }
            } else {
                if let scanningCompletionBlock = scanningCompletionBlock {
                    scanningCompletionBlock(resultStr)
                    navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

extension TNScanViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let metadataDict: CFDictionary = CMCopyDictionaryOfAttachments(nil, sampleBuffer, kCMAttachmentMode_ShouldPropagate)!
        let metadata = metadataDict as NSDictionary
        let exifMetadata = metadata.object(forKey: kCGImagePropertyExifDictionary) as! NSDictionary
        let brightnessValue = exifMetadata.object(forKey: kCGImagePropertyExifBrightnessValue) as! Float
        if brightnessValue < Float(0.0) {
            
        }
    }
}
