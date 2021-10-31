//
//  ViewController.swift
//  myWeb3Wallet
//
//  Created by Ravi Ranjan on 21/10/21.
//

import UIKit
import WalletConnect

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "wss://relay.walletconnect.com")!
        let appmeta = AppMetadata(name: "", description: "", url: "http://app.pancakefork.finance", icons: ["https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media"])
       
        let client = WalletConnectClient(metadata: appmeta, apiKey: "", isController: true, relayURL: url)
        client.delegate = self
        let uri = "wc:1d0837e2-e57b-4d6a-888d-75c49c327710@1?bridge=https%3A%2F%2Fp.bridge.walletconnect.org&key=cd3f196b8ee1d98c5a30186241d7a1121c067fb38dfde5678e819d526021a056"

        do {
            try client.pair(uri: uri)
        }
        catch (let err){
            print(err.localizedDescription)
        }
        // Do any additional setup after loading the view.
    }


}

extension ViewController : WalletConnectClientDelegate {
    func didReceive(sessionProposal: SessionProposal) {
        
    }
    
    func didReceive(sessionRequest: SessionRequest) {
        
    }
    
    func didSettle(session: Session) {
        
    }
    
    func didSettle(pairing: PairingType.Settled) {
        
    }
    
    func didReject(sessionPendingTopic: String, reason: SessionType.Reason) {
        
    }
    
    func didDelete(sessionTopic: String, reason: SessionType.Reason) {
        
    }
    
    
}
