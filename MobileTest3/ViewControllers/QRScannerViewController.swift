//
//  QRScannerViewController.swift
//  QRCodeReader
//
//  Created by KM, Abhilash a on 08/03/19.
//  Copyright © 2019 KM, Abhilash. All rights reserved.
//

import UIKit

class QRScannerViewController: UIViewController {
    var delegate : BarkodEkleProtocol?
    @IBOutlet weak var scannerView: QRScannerView! {
        didSet {
            scannerView.delegate = self
        }
    }
    @IBOutlet weak var scanButton: UIButton! {
        didSet {
            scanButton.setTitle("STOP", for: .normal)
        }
    }
    var qrData: QRData? = nil {
        didSet {
            if qrData != nil {
                delegate?.BarkodEkle(barkodx:qrData!.codeString!)
                self.dismiss(animated: true, completion: nil)
               //  self.performSegue(withIdentifier: "HomeDon", sender: self) //HomeDon
                //presentAlert(withTitle: "Error", message: qrData!.codeString!)
                //self.performSegue(withIdentifier: "detailSeuge", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if scannerView.isRunning {
            scannerView.startScanning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !scannerView.isRunning {
            scannerView.stopScanning()
        }
    }

    @IBAction func scanButtonAction(_ sender: UIButton) {
        scannerView.isRunning ? scannerView.stopScanning() : scannerView.startScanning()
        let buttonTitle = scannerView.isRunning ? "STOP" : "SCAN"
        sender.setTitle(buttonTitle, for: .normal)
    }
}


extension QRScannerViewController: QRScannerViewDelegate {
    func qrScanningDidStop() {
        let buttonTitle = scannerView.isRunning ? "STOP" : "SCAN"
        scanButton.setTitle(buttonTitle, for: .normal)
    }
    
    func qrScanningDidFail() {
        presentAlert(withTitle: "Error", message: "Scanning Failed. Please try again")
    }
    
    func qrScanningSucceededWithCode(_ str: String?) {
        self.qrData = QRData(codeString: str)
    }
    
    
    
}


extension QRScannerViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? HomeViewController { //segue.identifier == "detailSeuge", 
            viewController.qrData = self.qrData
        }
    }
}

