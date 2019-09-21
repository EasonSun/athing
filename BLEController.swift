//
//  BLEController.swift
//  AV Foundation
//
//  Created by Yicheng on 9/8/19.
//  Copyright © 2019 Pranjal Satija. All rights reserved.
//
import AVFoundation
import CoreBluetooth

// TODO multiple service, e.g. one for lighting, one for multi-angle, etc?
// <CBPeripheral: 0x281001860, identifier = 99C1BC44-54E0-5C4B-3AA7-64DCA8B28B63, name = StikLight, state = disconnected>
let lightingCtlServiceCBUUID = CBUUID(string: "4FAFC201-1FB5-459E-8FCC-C5C9C331914B")
let lightingCtlCharCBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F5-EA07361B26A8")
let lightingReadyCharCBUUID = CBUUID(string: "BEB5483E-1FB5-4688-8FCC-EA07361B26A8")

class BLEController: NSObject {
    var centralManager: CBCentralManager!
    var lightingCtlPeripheral: CBPeripheral!
    var lightingCtlChar: CBCharacteristic? = nil
    var lightingReadyChar: CBCharacteristic? = nil
    var isLightingReady: Bool = false
}

extension BLEController {
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        //TODO how to get the discovery ready?
//        self.lightingCtlPeripheral.state == .connected
        // TODO how to reconnect to a char
        // wait until char become not nil
        
    }
    
    func setLightingParam(lightingParam: [UInt8]) {
        
    }
}

// TODO When will poweredOn happen? Will the user get promopt?
extension BLEController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            // So it only scans for the lightingCtl service
            // TODO if l58, app crashs. The service has to be on to be searched in app
//        self.centralManager.scanForPeripherals(withServices: [lightingCtlServiceCBUUID])
            self.centralManager.scanForPeripherals(withServices:nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        if (peripheral.name == "StikLight") {
//            print(peripheral.services?.count)
            guard let services = peripheral.services else { return }
            for service in services {
                print(service)
            }
            self.centralManager.stopScan()
        }
//        self.lightingCtlPeripheral = peripheral
//        self.lightingCtlPeripheral.delegate = self
//        self.centralManager.stopScan()
//        self.centralManager.connect(self.lightingCtlPeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
lightingCtlPeripheral.discoverServices([lightingCtlServiceCBUUID])
    }
}

extension BLEController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            switch characteristic.uuid {
            case lightingCtlCharCBUUID:
                self.lightingCtlChar = characteristic
                // emit completion event
//                lightingCtlPeripheral.writeValue(Data: NSData(1), for: lightingCtlChar, type: CBCharacteristicWriteType)
            case lightingReadyCharCBUUID:
                peripheral.setNotifyValue(true, for: characteristic)
            default:
                continue
            }
        }
    }
    
    // This method is invoked after a @link readValueForCharacteristic: @/link call, or upon receipt of a notification/indication.
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case lightingReadyCharCBUUID:
            isLightingReady = getLightingReady(from: characteristic)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    // decode lighting ready signal
    private func getLightingReady(from characteristic: CBCharacteristic) -> Bool {
        guard let characteristicData = characteristic.value else { return false }
        let byte = characteristicData.first
        
        switch byte {
        case 1: return true
        default:
            return false
        }
    }
    
//    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
//        <#code#>
//    }
}
