//
//  ViewController.swift
//  urna-distribuida-app
//
//  Created by Laura Abitante on 07/12/17.
//  Copyright © 2017 Laura Abitante. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var txtIpAddress: UITextField!
    
    var urna: Urna!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblStatus.text = "Urna desconectada"
    }
    
    @IBAction func conectar() {
        urna = Urna((txtIpAddress.text ?? "localhost") as CFString)
        urna.delegate = self
        txtIpAddress.resignFirstResponder()
    }
    
    @IBAction func sendMessageButtonPressed() {
        urna.enviarMensagem("CONECTAR")
        lblStatus.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let votacaoVC = segue.destination as? TituloViewController {
            votacaoVC.urna = urna
        }
    }
}

extension ViewController: UrnaDelegate {
    func urnaConectada() {
        lblStatus.text = ""
    }
    
    func mensagemRecebida(mensagem: String) {
        if mensagem.contains("|") {
            urna.zona = String(mensagem.split(separator: "|").first!)
            urna.sessao = String(mensagem.split(separator: "|").last!)
            performSegue(withIdentifier: "titulo", sender: self)
        } else {
            lblStatus.text = mensagem
        }
    }
}

