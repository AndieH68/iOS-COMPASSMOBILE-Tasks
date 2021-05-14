//
//  SearchViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 25/02/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import AVFoundation
import UIKit

class SearchViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        Session.CodeScanned = nil
        Session.FilterAssetNumber = nil

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice!)
        } catch {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.code39, AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.pdf417, AVMetadataObject.ObjectType.code128, AVMetadataObject.ObjectType.upce, AVMetadataObject.ObjectType.code93, AVMetadataObject.ObjectType.dataMatrix]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            if readableObject.type == AVMetadataObject.ObjectType.dataMatrix {
                
                // parse the matrix to get the serial number
                let GS1DataMatrix = GS1Barcode(raw: readableObject.stringValue!.replacingOccurrences(of: "\n", with: ""))
                Session.MatrixScanned = GS1DataMatrix.raw

                if GS1DataMatrix.LastParseSuccessfull {
                    foundCode(GS1DataMatrix.SerialNumber!)
                } else {
                    if GS1DataMatrix.HasUnrecognisedElement == true {
                        if GS1DataMatrix.SerialNumber != nil
                        {
                            foundCode(GS1DataMatrix.SerialNumber!) }
                        else {
                            // bad code
                            Session.MatrixScanned = nil
                        }
                    }
                }
            } else {
                Session.MatrixScanned = nil
                foundCode(readableObject.stringValue!)
            }
        }

        dismiss(animated: true, completion: nil)
    }

    func foundCode(_ code: String) {
        Session.CodeScanned = code
        Session.FilterAssetNumber = "(%" + code + ")%"
        _ = navigationController?.popViewController(animated: true)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    @IBAction func Cancel(_ sender: UIBarButtonItem) {
        Session.CancelFromScan = true;
        _ = navigationController?.popViewController(animated: true)
    }
}
