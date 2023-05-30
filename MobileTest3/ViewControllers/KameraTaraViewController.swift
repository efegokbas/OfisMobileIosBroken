//
//  KameraTaraViewController.swift
//  TemaMobil
//
//  Created by Mac on 23.10.2019.
//  Copyright © 2019 Tema Yazılım. All rights reserved.
//

import UIKit

class KameraTaraViewController: UIViewController {
    @IBOutlet weak var scannerView: KameraTara! {
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
                self.performSegue(withIdentifier: "detailSeuge", sender: self)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)

           if !scannerView.isRunning {
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension KameraTaraViewController: KameraTaraViewDelegate {
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


extension KameraTaraViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSeuge", let viewController = segue.destination as? DetailViewController {
            viewController.qrData = self.qrData
        }
    }
}
