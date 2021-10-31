//
//  BrowserViewController.swift
//  myWeb3Wallet
//
//  Created by Ravi Ranjan on 24/10/21.
//

import UIKit
import WebKit
class BrowserViewController: UIViewController {

    @IBOutlet weak var webKitBrowVIew: WKWebView!
    public var url: URL!
    override func viewDidLoad() {
        super.viewDidLoad()

        webKitBrowVIew.load(URLRequest(url: url))
        // Do any additional setup after loading the view.
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
