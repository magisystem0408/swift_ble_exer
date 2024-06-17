//
//  ContentView.swift
//  core-ble
//
//  Created by 松戸誠人 on 2024/06/16.
//

import SwiftUI
import CoreBluetooth


class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    private var centeralManager: CBCentralManager!
    private var peripheralToConnect: CBPeripheral?
    var onDeviceDiscoverd: ((CBPeripheral) -> Void)?
    
    override init(){
        super.init()
        centeralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn{
            centeralManager.scanForPeripherals(withServices: nil)
        }else{
            print("Bluetooth is not avaliable.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        onDeviceDiscoverd?(peripheral)
    }
    
    //NOTE: device発見した時
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: (any Error)?) {
    }
}

struct ContentView: View {
    @State private var devices:[CBPeripheral] = []
    private var bluetoothManager = BluetoothManager()
    var body: some View {
        List(devices, id: \.identifier){
            device in Text(device.name ?? "Unknown device")
            Text(device.identifier.uuidString)
            
        }.navigationTitle("BLE Device")
            .onAppear{
                bluetoothManager.onDeviceDiscoverd = {device in
                    self.devices.append(device)
                }
            }
    }
}

#Preview {
    ContentView()
}
