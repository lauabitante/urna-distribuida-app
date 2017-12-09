//
//  VotarViewController.swift
//  urna-distribuida-app
//
//  Created by Laura Abitante on 07/12/17.
//  Copyright © 2017 Laura Abitante. All rights reserved.
//

import UIKit

class VotarViewController: UIViewController {

    @IBOutlet weak var txtVoto: UITextField!
    var urna: Urna!
    var titulo: String!
    var ipAddress: CFString!
    
    override func viewDidLoad() {
        urna.delegate = self
        super.viewDidLoad()
    }
    
    @IBAction func votarButtonTouched() {
        if let voto = txtVoto.text {
            urna.enviarMensagem("\(titulo!)|\(voto)")
        }
    }
}

extension VotarViewController: UrnaDelegate {
    func urnaConectada() { }
    
    func mensagemRecebida(mensagem: String) {
        
        let sucesso = mensagem.contains("OK")
        let confirmacao = sucesso ? "Voto computado com sucesso!" : "Candidato não existe!"
        
        let alert = UIAlertController(title: "Urna", message: confirmacao, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            if sucesso {
                self.navigationController?.popViewController(animated: true)
            }
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
}
