/*

Copyright (c) 2015 Fernando Reynoso
              2015 Ziye Xing

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

import Foundation
import CoreBluetooth

protocol BLEDelegate {
    func bleDidUpdateState()
    func bleDidConnectToPeripheral()
    func bleDidDisconnectFromPeripheral()
    func bleDidReceiveData(data: NSData?)
}

class BLE: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    let RBL_SERVICE_UUID = "713D0000-503E-4C75-BA94-3148F18D941E"
    let RBL_CHAR_TX_UUID = "713D0002-503E-4C75-BA94-3148F18D941E"
    let RBL_CHAR_RX_UUID = "713D0003-503E-4C75-BA94-3148F18D941E"
    
    var delegate: BLEDelegate?
    
    var centralManager:   CBCentralManager!
    var activePeripheral: CBPeripheral?
    var characteristics = [String : CBCharacteristic]()
    private      var data:             NSMutableData?
    private(set) var peripherals     = [CBPeripheral]()
    private      var RSSICompletionHandler: ((NSNumber?, NSError?) -> ())?
    
    override init() {
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.data = NSMutableData()
    }
    
    @objc private func scanTimeout() {
        
        print("[DEBUG] Scanning stopped")
        centralManager.stopScan()
        
        if !peripherals.isEmpty {
            connectToPeripheral(peripherals[0])
        }
    }
    
    // MARK: Public methods
    func startScanning(timeout: Double) -> Bool {
        
        if self.centralManager.state != .PoweredOn {
            
            print("[ERROR] Couldn´t start scanning")
            return false
        }
        
        print("[DEBUG] Scanning started")
        
        // CBCentralManagerScanOptionAllowDuplicatesKey
        
        NSTimer.scheduledTimerWithTimeInterval(timeout, target: self, selector: Selector("scanTimeout"), userInfo: nil, repeats: false)
        
        let services:[CBUUID] = [CBUUID(string: RBL_SERVICE_UUID)]
        self.centralManager.scanForPeripheralsWithServices(services, options: nil)
        
        return true
    }
    
    func connectToPeripheral(peripheral: CBPeripheral) -> Bool {
        
        if self.centralManager.state != .PoweredOn {
            
            print("[ERROR] Couldn´t connect to peripheral")
            return false
        }
        
        print("[DEBUG] Connecting to peripheral: \(peripheral.identifier.UUIDString)")
        
        self.centralManager.connectPeripheral(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey : NSNumber(bool: true)])
        
        return true
    }
    
    func disconnectFromPeripheral(peripheral: CBPeripheral) -> Bool {
        
        if self.centralManager.state != .PoweredOn {
            
            print("[ERROR] Couldn´t disconnect from peripheral")
            return false
        }

        self.centralManager.cancelPeripheralConnection(peripheral)
        
        return true
    }
    
    func read() {
        
        self.activePeripheral?.readValueForCharacteristic(self.characteristics[RBL_CHAR_TX_UUID]!)
    }
    
    func write(data data: NSData) {
        
        self.activePeripheral?.writeValue(data, forCharacteristic: self.characteristics[RBL_CHAR_RX_UUID]!, type: .WithoutResponse)
    }
    
    func enableNotifications(enable: Bool) {
        
        self.activePeripheral?.setNotifyValue(enable, forCharacteristic: self.characteristics[RBL_CHAR_TX_UUID]!)
    }
    
    func readRSSI(completion: (RSSI: NSNumber?, error: NSError?) -> ()) {
        
        self.RSSICompletionHandler = completion
        self.activePeripheral?.readRSSI()
    }
    
    // MARK: CBCentralManager delegate
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        switch central.state {
        case .Unknown:
            print("[DEBUG] Central manager state: Unknown")
            break
            
        case .Resetting:
            print("[DEBUG] Central manager state: Resseting")
            break
            
        case .Unsupported:
            print("[DEBUG] Central manager state: Unsopported")
            break
            
        case .Unauthorized:
            print("[DEBUG] Central manager state: Unauthorized")
            break
            
        case .PoweredOff:
            print("[DEBUG] Central manager state: Powered off")
            break
            
        case .PoweredOn:
            print("[DEBUG] Central manager state: Powered on")
            break
        }
        
        self.delegate?.bleDidUpdateState()
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        print("[DEBUG] Find peripheral: \(peripheral.identifier.UUIDString) RSSI: \(RSSI)")
        
        for var i = 0; i < self.peripherals.count; i++ {
            
            let p = self.peripherals[i] as CBPeripheral
            
            if(p.identifier.UUIDString == peripheral.identifier.UUIDString) {
                
                self.peripherals[i] = peripheral
                
                return
            }
        }
        
        self.peripherals.append(peripheral)
    }
/*
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        print("[DEBUG] Find peripheral: \(peripheral.identifier.UUIDString) RSSI: \(RSSI)")
        
        for var i = 0; i < self.peripherals.count; i++ {
            
            let p = self.peripherals[i] as CBPeripheral
            
            if(p.identifier.UUIDString == peripheral.identifier.UUIDString) {
                
                self.peripherals[i] = peripheral
                
                return
            }
        }
        
        self.peripherals.append(peripheral)
    }*/
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("[ERROR] Could not connecto to peripheral \(peripheral.identifier.UUIDString) error: \(error!.description)")
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        print("[DEBUG] Connected to peripheral \(peripheral.identifier.UUIDString)")
        
        self.activePeripheral = peripheral
        
        self.activePeripheral?.delegate = self
        self.activePeripheral?.discoverServices([CBUUID(string: RBL_SERVICE_UUID)])
        
        self.delegate?.bleDidConnectToPeripheral()
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        var text = "[DEBUG] Disconnected from peripheral: \(peripheral.identifier.UUIDString)"
        
        if error != nil {
            text += ". Error: \(error!.description)"
        }
        
        print(text)
        
        self.activePeripheral?.delegate = nil
        self.activePeripheral = nil
        self.characteristics.removeAll(keepCapacity: false)
        
        self.delegate?.bleDidDisconnectFromPeripheral()
    }
    
    // MARK: CBPeripheral delegate
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        if error != nil {
            print("[ERROR] Error discovering services. \(error!.description)")
            return
        }
        
        print("[DEBUG] Found services for peripheral: \(peripheral.identifier.UUIDString)")
        
        if let services = peripheral.services {
            for service in services {
                
                let theCharacteristics = [CBUUID(string: RBL_CHAR_RX_UUID), CBUUID(string: RBL_CHAR_TX_UUID)]
                
                peripheral.discoverCharacteristics(theCharacteristics, forService: service)
            }
        }
        

    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        if error != nil {
            print("[ERROR] Error discovering characteristics. \(error!.description)")
            return
        }
        
        print("[DEBUG] Found characteristics for peripheral: \(peripheral.identifier.UUIDString)")
        
        if let peripheralCharacteristics = service.characteristics {
            for characteristic in peripheralCharacteristics {
                
                self.characteristics[characteristic.UUID.UUIDString] = characteristic
            }
        }
        
        enableNotifications(true)
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        struct Buffer {
            static var data = NSMutableData()
        }
        
        if error != nil {
            
            print("[ERROR] Error updating value. \(error!.description)")
            return
        }
        
        if characteristic.UUID.UUIDString == RBL_CHAR_TX_UUID {
            if characteristic.value?.length == 20 {
                Buffer.data.appendData(characteristic.value!)
                
                if Buffer.data.length >= 64 {
                    delegate?.bleDidReceiveData(Buffer.data)
                    Buffer.data = NSMutableData()
                }
            } else if characteristic.value?.length < 20 {
                Buffer.data.appendData(characteristic.value!)
                delegate?.bleDidReceiveData(Buffer.data)
                Buffer.data = NSMutableData()
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?) {
        self.RSSICompletionHandler?(RSSI, error)
        self.RSSICompletionHandler = nil
    }
}
