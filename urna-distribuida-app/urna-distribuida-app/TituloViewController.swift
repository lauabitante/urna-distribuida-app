//
//  TituloViewController.swift
//  urna-distribuida-app
//
//  Created by Laura Abitante on 07/12/17.
//  Copyright © 2017 Laura Abitante. All rights reserved.
//

import UIKit

class TituloViewController: UIViewController {
    
    var urna: Urna!
    var titulo = ""
    
    @IBOutlet weak var txtTituloEleitor: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urna.delegate = self
    }
    
    @IBAction func btnEntrarTouched() {
        if let titulo = txtTituloEleitor.text {
            self.titulo = titulo
            urna.enviarMensagem("VALIDAR|\(titulo)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let votarVC = segue.destination as? VotarViewController {
            votarVC.urna = urna
            votarVC.titulo = titulo
            votarVC.ipAddress = urna.endereco
        }
    }
}

extension TituloViewController: UrnaDelegate {
    func urnaConectada() { }
    
    func mensagemRecebida(mensagem: String) {
        if mensagem.contains("OK") {
            performSegue(withIdentifier: "votar", sender: self)
        } else {
            let alert = UIAlertController(title: "Ops!", message: "Título não encontrado", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .destructive)
            alert.addAction(action)
            present(alert, animated: true)
            
        }
    }
}

