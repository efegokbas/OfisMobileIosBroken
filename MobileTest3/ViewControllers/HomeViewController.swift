//
//  HomeViewController.swift
//  MobileTest3
//
//  Created by Mac on 4.10.2019.
//  Copyright © 2019 Tema Yazılım Ltd Şti. All rights reserved.
//

import UIKit
import WebKit
import CoreLocation
protocol BarkodEkleProtocol {
    func BarkodEkle(barkodx:String)
}

class HomeViewController: UIViewController, WKNavigationDelegate,BarkodEkleProtocol {

    let documentInteractionController = UIDocumentInteractionController()
    var qrData: QRData?
    var webView: WKWebView!
    //@IBOutlet weak var WebView: UIWebView!
    
    @IBOutlet weak var webViewContainer: UIView!
    //@IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
         documentInteractionController.delegate = self
        // 1
        let contentController = WKUserContentController();
        contentController.add(
            self,
            name: "KameraAc"
        )
        contentController.add(
               self,
               name: "Paylas"
           )
        // 2
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        // 3
        webView = WKWebView(frame: webViewContainer.bounds, configuration: config)
        
        //webView.translatesAutoresizingMaskIntoConstraints = false
        webViewContainer.addSubview(webView)
        
       // webView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor, constant: 0).isActive = true
       // webView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor, constant: 0).isActive = true
       // webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor, constant: 0).isActive = true
        //webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor, constant: 0).isActive = true
        
        if let url = URL(string: "https://mobile.ofismobile.com/") {
            webView.load(URLRequest(url: url as URL))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pop = segue.destination as? QRScannerViewController {
            pop.delegate = self
        }
    }
  func KameraAc(dict: NSDictionary) {
           let geocoder = CLGeocoder()
           let s1 = dict["s1"] as? String ?? ""
           let s2 = dict["s2"] as? String ?? ""
           let s3 = dict["s3"] as? String ?? ""
           let s4 = dict["s4"] as? String ?? ""
           
           let addressString = "\(s1), \(s2), \(s3), \(s4)"
           geocoder.geocodeAddressString(addressString, completionHandler: geocodeComplete)
       }

       func Paylas(dict: NSDictionary) {

        webView.evaluateJavaScript("loading(1)", completionHandler: nil)
                let urlx = dict["s1"] as? String ?? ""
                     storeAndShare(withURLString: urlx)
        
                
        }
       func geocodeComplete(placemarks: [CLPlacemark]?, error: Error?) {
           if let placemarks = placemarks, placemarks.count > 0 {
               let lat = placemarks[0].location?.coordinate.latitude ?? 0.0
               let lon = placemarks[0].location?.coordinate.longitude ?? 0.0
               webView.evaluateJavaScript("setAlert('\(lat)', '\(lon)')", completionHandler: nil)
           }
           
       }
    
     func BarkodEkle(barkodx:String){
            let barkod = barkodx
         webView.evaluateJavaScript("abyaz('\(barkod)')", completionHandler: nil)
    }
}
extension HomeViewController:WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "KameraAc", let _ = message.body as? NSDictionary {
            self.performSegue(withIdentifier: "TarayiciEkrani", sender: self) //HomeDon
        }
        if message.name == "Paylas", let dict = message.body as? NSDictionary {
            Paylas(dict: dict)
        }
    }
}
extension HomeViewController {
    /// This function will set all the required properties, and then provide a preview for the document
    func share(url: URL) {
        documentInteractionController.url = url
        documentInteractionController.uti = url.typeIdentifier ?? "public.data, public.content"
        documentInteractionController.name = url.localizedName ?? url.lastPathComponent
        documentInteractionController.presentPreview(animated: true)
    }
    
    /// This function will store your document to some temporary URL and then provide sharing, copying, printing, saving options to the user
    func storeAndShare(withURLString: String) {
        guard let url = URL(string: withURLString) else { return }
        /// START YOUR ACTIVITY INDICATOR HERE
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            let fName = withURLString
            let fArr = fName.components(separatedBy: "/")
            guard let finalFileName = fArr.last else { return  }
            let tmpURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(finalFileName)
            do {
                try data.write(to: tmpURL)
            } catch {
                print(error)
            }
            DispatchQueue.main.async {
                /// STOP YOUR ACTIVITY INDICATOR HERE
                let myWebsite = NSURL(fileURLWithPath:tmpURL.absoluteString)
                let shareAll = [myWebsite]
                let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
             //   self.share(url: tmpURL)
            }
            }.resume()

        webView.evaluateJavaScript("loading(0)", completionHandler: nil)
    }
}
extension HomeViewController: UIDocumentInteractionControllerDelegate {
    /// If presenting atop a navigation stack, provide the navigation controller in order to animate in a manner consistent with the rest of the platform
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let navVC = self.navigationController else {
            return self
        }
        return navVC
    }
}

extension URL {
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
    var localizedName: String? {
        return (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
}
