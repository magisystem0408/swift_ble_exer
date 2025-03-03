//
//  ContentView.swift
//  core-ble
//
//  Created by 松戸誠人 on 2024/06/16.
//

import SwiftUI
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject {
    @Published var peripherals: [CBPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var data: Data?
    
    private var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BluetoothManager: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //NOTE: state controll.
        if central.state == .poweredOn{
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //NOTE: if you discover peripheral device, this func invoked.
        
        if !peripherals.contains(peripheral){
            peripherals.append(peripheral)
        }
    }
    
    func connect(to peripheral: CBPeripheral){
        centralManager.stopScan()
        centralManager.connect(peripheral,options: nil)
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //NOTE: if you connect peripheral device, this func invoked.
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        guard let services = peripheral.services else {return}
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        guard let characteristics = service.characteristics else { return }
                for characteristic in characteristics {
                    peripheral.readValue(for: characteristic)
            }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        data = characteristic.value
    }
}

struct ContentView: View {
    @ObservedObject var bluetoothManager = BluetoothManager()

    var body: some View {
        NavigationView {
            List(bluetoothManager.peripherals, id: \.identifier) { peripheral in
                Button(action: {
                    bluetoothManager.connect(to: peripheral)
                }) {
                    Text(peripheral.name ?? "Unknown")
                }
            }
            .navigationTitle("Bluetooth Devices")
        }
        .onAppear {
            bluetoothManager.centralManagerDidUpdateState(bluetoothManager.centralManager)
        }
        .alert("Text", isPresented: false)
    }
}


#Preview {
    ContentView()
}
