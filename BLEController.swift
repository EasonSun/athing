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
let lightingCtlServiceCBUUID = CBUUID(string: "find me")
let lightingCtlCharCBUUID = CBUUID(string: "find me")
let lightingReadyCharCBUUID = CBUUID(string: "find me")

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
            // TODO multi service?
            self.centralManager.scanForPeripherals(withServices: [lightingCtlServiceCBUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        self.lightingCtlPeripheral = peripheral
        self.lightingCtlPeripheral.delegate = self
        self.centralManager.stopScan()
        self.centralManager.connect(self.lightingCtlPeripheral)
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
}
