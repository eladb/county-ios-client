//
//  CountyClient.swift
//  County
//
//  Created by Elad Ben-Israel on 12/6/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import UIKit

class CountyClient: NSObject, SRWebSocketDelegate {
    weak var delegate: CountyClientDelegate?
    private var webSocket: SRWebSocket?
    private let group: String
    private let baseURL: NSURL
    private var incrementQueue = [(String,UInt)]();

    init(baseURL: NSURL, group: String) {
        self.baseURL = baseURL
        self.group = group
        super.init()
    }
    
    var isConnected: Bool {
        get { return self.webSocket != nil }
    }
    
    func connect() {
        if self.webSocket != nil { return; } // already connected
        self.webSocket = SRWebSocket(URL: NSURL(string: "/subscribe?group=\(self.group)", relativeToURL: self.baseURL))
        self.webSocket?.delegate = self
        self.webSocket?.open()
    }

    func incrementKey(key: String, byValue increment: UInt) {
        if !isConnected {
            self.incrementQueue.append((key, increment))
            self.connect()
            return
        }
        
        let data = NSJSONSerialization.dataWithJSONObject([ "increment": [ key: increment ] ], options: NSJSONWritingOptions(0), error: nil)
        self.webSocket?.send(data)
    }
   
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        while !self.incrementQueue.isEmpty {
            let increment = self.incrementQueue.removeAtIndex(0)
            self.incrementKey(increment.0, byValue: increment.1)
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        println("didClose")
        self.webSocket = nil
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        if let msg = message as? String {
            if let data = msg.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                if let updates = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as? [String:UInt] {
                    println("received updates: \(updates)")
                    self.delegate?.countyClient(self, didUpdateCounters: updates)
                }
            }
        }
    }
}

protocol CountyClientDelegate: NSObjectProtocol {
    func countyClient(client: CountyClient, didUpdateCounters: [ String : UInt ])
}