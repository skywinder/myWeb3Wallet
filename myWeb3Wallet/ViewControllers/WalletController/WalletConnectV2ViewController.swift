import UIKit
import WalletConnect

final class WalletConnectV2ViewController: UIViewController {
//wc:1d0837e2-e57b-4d6a-888d-75c49c327710@1?bridge=https%3A%2F%2Fp.bridge.walletconnect.org&key=cd3f196b8ee1d98c5a30186241d7a1121c067fb38dfde5678e819d526021a056
    
    let client: WalletConnectClient = {
        let metadata = AppMetadata(
            name: "Example Wallet",
            description: "wallet description",
            url: "example.wallet",
            icons: ["https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media"])
        return WalletConnectClient(
            metadata: metadata,
            apiKey: "37027835ec66f2330687285a9868d80a",
            isController: true,
            relayURL: URL(string: "wss://relay.walletconnect.org")!
        )
    }()
    
    var sessionItems: [ActiveSessionItem] = []
    var currentProposal: SessionProposal?
    
    private let responderView: ResponderView = {
        ResponderView()
    }()
    
    override func loadView() {
        view = responderView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Wallet"
        
        responderView.scanButton.addTarget(self, action: #selector(showScanner), for: .touchUpInside)
        responderView.pasteButton.addTarget(self, action: #selector(showTextInput), for: .touchUpInside)
        
        responderView.tableView.dataSource = self
        responderView.tableView.delegate = self
        sessionItems = ActiveSessionItem.mockList()
        
        client.delegate = self
        
    }
    
    @objc
    private func showScanner() {
        let scannerViewController = ScannerViewController()
        scannerViewController.delegate = self
        present(scannerViewController, animated: true)
    }
    
    @objc
    private func showTextInput() {
        let alert = UIAlertController.createInputAlert { [weak self] inputText in
            self?.pairClient(uri: inputText)
        }
        present(alert, animated: true)
    }
    
    private func showSessionProposal(_ info: SessionInfo) {
        let proposalViewController = SessionViewController()
        proposalViewController.delegate = self
        proposalViewController.show(info)
        present(proposalViewController, animated: true)
    }
    
    private func pairClient(uri: String) {
        print("[RESPONDER] Pairing to: \(uri)")
        do {
            try client.pair(uri: uri)
        } catch {
            print("[PROPOSER] Pairing connect error: \(error)")
        }
    }
}

extension WalletConnectV2ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sessionItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell", for: indexPath) as! ActiveSessionCell
        cell.item = sessionItems[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = sessionItems[indexPath.row]
//            let deleteParams = SessionType.DeleteParams(topic: item.topic, reason: SessionType.Reason(code: 0, message: "disconnect"))
            client.disconnect(topic: item.topic, reason: SessionType.Reason(code: 0, message: "disconnect"))
            sessionItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        "Disconnect"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select row \(indexPath)")
        let uri = "wc:1d0837e2-e57b-4d6a-888d-75c49c327710@1?bridge=https%3A%2F%2Fp.bridge.walletconnect.org&key=cd3f196b8ee1d98c5a30186241d7a1121c067fb38dfde5678e819d526021a056"
        do {
            try client.pair(uri: uri)
        } catch (let err) {
            print(err.localizedDescription)
        }
    }
}

extension WalletConnectV2ViewController: ScannerViewControllerDelegate {
    
    func didScan(_ code: String) {
        pairClient(uri: code)
    }
}

extension WalletConnectV2ViewController: SessionViewControllerDelegate {
    
    func didApproveSession() {
        print("[RESPONDER] Approving session...")
        let proposal = currentProposal!
        currentProposal = nil
        client.approve(proposal: proposal, accounts: [])
    }
    
    func didRejectSession() {
        print("did reject session")
        let proposal = currentProposal!
        currentProposal = nil
        client.reject(proposal: proposal, reason: SessionType.Reason(code: 0, message: "reject"))
    }
}

extension WalletConnectV2ViewController: WalletConnectClientDelegate {
    
    func didDelete(sessionTopic: String, reason: SessionType.Reason) {
        
    }
    
    func didReceive(sessionProposal: SessionProposal) {
        print("[RESPONDER] WC: Did receive session proposal")
        let appMetadata = sessionProposal.proposer
        let info = SessionInfo(
            name: appMetadata.name ?? "",
            descriptionText: appMetadata.description ?? "",
            dappURL: appMetadata.url ?? "",
            iconURL: appMetadata.icons?.first ?? "",
            chains: sessionProposal.permissions.blockchains,
            methods: sessionProposal.permissions.methods)
        currentProposal = sessionProposal
        DispatchQueue.main.async { // FIXME: Delegate being called from background thread
            self.showSessionProposal(info)
        }
    }
    
    func didReceive(sessionRequest: SessionRequest) {
        print("[RESPONDER] WC: Did receive session request")
    }
    
    func didSettle(session: Session) {
        print("[RESPONDER] WC: Did settle session")
        let settledSessions = client.getSettledSessions()
        let activeSessions = settledSessions.map { session -> ActiveSessionItem in
            let app = session.peer
            return ActiveSessionItem(
                dappName: app?.name ?? "",
                dappURL: app?.url ?? "",
                iconURL: app?.icons?.first ?? "",
                topic: session.topic)
        }
        DispatchQueue.main.async { // FIXME: Delegate being called from background thread
            self.sessionItems = activeSessions
            self.responderView.tableView.reloadData()
        }
    }
    
    func didSettle(pairing: PairingType.Settled) {
        print("[RESPONDER] WC: Did settle pairing")
    }
    
    func didReject(sessionPendingTopic: String, reason: SessionType.Reason) {
        print("[RESPONDER] WC: Did reject session")
    }
}

extension UIAlertController {
    
    static func createInputAlert(confirmHandler: @escaping (String) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "Paste URI", message: "Enter a WalletConnect URI to connect.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let confirmAction = UIAlertAction(title: "Connect", style: .default) { _ in
            if let input = alert.textFields?.first?.text, !input.isEmpty {
                confirmHandler(input)
            }
        }
        alert.addTextField { textField in
            textField.placeholder = "wc://a14aefb980188fc35ec9..."
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        alert.preferredAction = confirmAction
        return alert
    }
}
