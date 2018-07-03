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
    
    var isPush: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        creatControl()
        startScanning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        addTimer()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .`default`
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
        let tabbarH: CGFloat = 84 + kSafeAreaBottomH
        let marginX: CGFloat = (kScreenW - scanW) * 0.5
        let maskH: CGFloat = kScreenH - tabbarH - kNavBarHeight
        let marginY: CGFloat = (maskH - scanW) * 0.5
        
        let topBarView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kNavBarHeight))
        topBarView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(topBarView)
        
        let backBtn = UIButton(frame: CGRect(x: CGFloat(kLeftMargin), y: kStatusbarH, width: 50, height: 44))
        backBtn.setImage(UIImage(named: "back_white"), for: .normal)
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
        borderView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        borderView.layer.borderWidth = 0.3
        scanView.addSubview(borderView)
        
        let lightTextLabel = UILabel()
        lightTextLabel.text = "Tap to turn light on".localized
        lightTextLabel.font = UIFont.systemFont(ofSize: 14)
        lightTextLabel.textColor = UIColor.white
        lightTextLabel.sizeToFit()
        lightTextLabel.center = CGPoint(x: scanW * 0.5, y: scanW - (16 + lightTextLabel.height * 0.5))
        scanView.addSubview(lightTextLabel)
        let lightBtn = UIButton()
        lightBtn.setImage(UIImage(named: "light_off"), for: .normal)
        lightBtn.setImage(UIImage(named: "light_on"), for: .selected)
        lightBtn.sizeToFit()
        lightBtn.addTarget(self, action: #selector(self.lightBtnOnClick(btn:)), for: .touchUpInside)
        lightBtn.center = CGPoint(x: scanW * 0.5, y: lightTextLabel.frame.minY - 20)
        scanView.addSubview(lightBtn)
        
        
        let frameView = UIImageView(image: UIImage(named: "sao_frame"))
        frameView.size = CGSize(width: scanW + 10, height: scanW + 10)
        frameView.center = scanView.center
        maskView?.addSubview(frameView)
        
        let descLabel = UILabel()
        descLabel.text = "ScanDescription".localized
        descLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        descLabel.font = UIFont.systemFont(ofSize: 14.0)
        descLabel.sizeToFit()
        descLabel.y = scanView.frame.maxY + 24
        descLabel.centerX = kScreenW * 0.5
        maskView?.addSubview(descLabel)
        
        let tabBarView = UIView(frame: CGRect(x: 0, y: kScreenH - tabbarH, width: kScreenW, height: tabbarH))
        tabBarView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(tabBarView)
        
    }
    
    fileprivate func drawLineForImageView(_ imageView: UIImageView) {
        let size = imageView.bounds.size
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let startColorComponents = kGlobalColor.cgColor.components
        let endColorComponents = kGlobalColor.cgColor.components
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
        if isPush {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
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
            if resultStr.hasPrefix("http") {
                guard let url = URL(string: resultStr) else {
                    return
                }
                if UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                    if isPush {
                        navigationController?.popViewController(animated: true)
                    } else {
                        dismiss(animated: true, completion: nil)
                    }
                }
            } else if resultStr.hasPrefix(TNScanPrefix) {
                let validStr = resultStr.replacingOccurrences(of: TNScanPrefix, with: "")
                if let scanningCompletionBlock = scanningCompletionBlock {
                    if isPush {
                        if validStr.verifyRecieverAddressAndAmount() || validStr.verifyRecieverAddress() {
                            scanningCompletionBlock(validStr)
                            navigationController?.popViewController(animated: true)
                        } else {
                            goToAddContact(validStr: validStr)
                        }
                    } else {
                        dismiss(animated: true) {
                            scanningCompletionBlock(validStr)
                        }
                    }
                } else {
                    if isPush {
                        if validStr.verifyRecieverAddressAndAmount() {
                            goToSendControllerWithAmount(validStr: validStr)
                        } else if validStr.verifyRecieverAddress() {
                            goToSendController(validStr: validStr)
                        } else if validStr.verifyDeviceCode() {
                             goToAddContact(validStr: validStr)
                        }
                    }
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

extension TNScanViewController {
    
    func goToSendController(validStr: String) {
        let credentials  = TNConfigFileManager.sharedInstance.readWalletCredentials()
        let walletModel = TNWalletModel.deserialize(from: credentials.first)
        let vc = TNSendViewController(wallet: walletModel!)
        vc.recAddress = validStr
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func goToSendControllerWithAmount(validStr: String) {
        let credentials  = TNConfigFileManager.sharedInstance.readWalletCredentials()
        let walletModel = TNWalletModel.deserialize(from: credentials.first)
        let vc = TNSendViewController(wallet: walletModel!)
        let strArr = validStr.components(separatedBy: "?amount=")
        vc.transferAmount = strArr.last
        vc.recAddress = strArr.first
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func goToAddContact(validStr: String) {
        let vc = TNAddContactsController()
        vc.pairingCode = validStr
        navigationController?.pushViewController(vc, animated: true)
    }
}
