//
//  Urna.swift
//  urna-distribuida-app
//
//  Created by Laura Abitante on 07/12/17.
//  Copyright © 2017 Laura Abitante. All rights reserved.
//

import Foundation

protocol UrnaDelegate: class {
    func urnaConectada()
    func mensagemRecebida(mensagem: String)
}

public class Urna : NSObject, StreamDelegate  {
    
    weak var delegate: UrnaDelegate?
    
    var zona = ""
    var sessao = ""
    
    var endereco: CFString
    var porta: UInt32
    private let bufferSize = 1024
    private var inputStream: InputStream!
    private var outputStream: OutputStream!
    private var conectando: Bool
    
    // MARK: - Init
    init(_ endereco :CFString, porta: UInt32 = 8000) {
        self.endereco = endereco
        self.porta = porta
        conectando = false
        super.init()
        connect()
    }
    
    // MARK: - Conexão
    func connect() {
        conectando = true
        
        while conectando {
            var readStream:  Unmanaged<CFReadStream>?
            var writeStream: Unmanaged<CFWriteStream>?
            
            CFStreamCreatePairWithSocketToHost(nil, self.endereco, self.porta, &readStream, &writeStream)
            
            self.inputStream = readStream!.takeRetainedValue()
            self.outputStream = writeStream!.takeRetainedValue()
            
            self.inputStream.delegate = self
            self.outputStream.delegate = self
            
            self.inputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            self.outputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            
            self.inputStream.open()
            self.outputStream.open()
            
            conectando = false
        }
    }
    
    // MARK: - Envio de mensagens
    func enviarMensagem(_ message: String) {
        let handshake: NSData = "\(message)\n".data(using: String.Encoding.utf8)! as NSData
        let ptr = handshake.bytes.assumingMemoryBound(to: UInt8.self)
        let returnVal = self.outputStream.write(ptr, maxLength: handshake.length)
        print("Enviado: \(returnVal)")
    }
    
    // MARK: - Disconectar
    func disconnect() {
        self.inputStream.close()
        self.outputStream.close()
    }
    
    // MARK: - Delegate do stream
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if aStream === inputStream {
            switch eventCode {
            case Stream.Event.hasBytesAvailable:
                if let mensagem = handleIncommingStream(aStream) {
                    delegate?.mensagemRecebida(mensagem: mensagem)
                } else {
                    print("Não foi possível ler a mensagem.")
                }
            default:
                break
            }
        }
        else if aStream === outputStream {
            switch eventCode {
            case .openCompleted:
                delegate?.urnaConectada()
            default:
                break
            }
        }
    }
    
    // MARK: - Leitura de mensagem
    final func handleIncommingStream(_ stream: Stream) -> String? {
        while (inputStream.hasBytesAvailable) {
            var buffer = [UInt8](repeating: 0, count: bufferSize)
            let bytesRead = inputStream.read(&buffer, maxLength: bufferSize)
            if bytesRead >= 0 {
                if let output = NSString(bytes: &buffer, length: buffer.count, encoding: String.Encoding.utf8.rawValue) {
                    return String(output)
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        return nil
    }
}
