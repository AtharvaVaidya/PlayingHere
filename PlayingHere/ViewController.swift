//
//  ViewController.swift
//  PlayingHere
//
//  Created by Matt Condon on 2/20/16.
//  Copyright © 2016 mattc. All rights reserved.
//

import UIKit
import CoreBluetooth
import SnapKit

let SERVICE_UUID = "CEBF1FFD-3E59-4FB9-B034-80AC7006E7EF"
let CHARACTERISTIC_UUID = "FD435BDA-883B-47EE-9D4A-AD722264B9B8"
let serviceUUID = NSUUID(UUIDString: SERVICE_UUID)!
let characteristicUUID = NSUUID(UUIDString: CHARACTERISTIC_UUID)!

let trackID = "58s6EuEYJdlb0kO7awm3Vp"

class ViewController: UIViewController {

  var session : SPTSession!
  var player : SPTAudioStreamingController!
  var myCentralManager : CBCentralManager!
  var myPeripheralManager : CBPeripheralManager!

  var discoveredPeripherals : [CBPeripheral] = []

  lazy var service : CBMutableService = {
    let service = CBMutableService(type: CBUUID(NSUUID: serviceUUID), primary: true)
    let characteristic = CBMutableCharacteristic(
      type: CBUUID(NSUUID: characteristicUUID),
      properties: .Read,
      value: nil,
      permissions: .Readable
    )
    service.characteristics = [characteristic]
    return service
  }()

  convenience init(session: SPTSession) {
    self.init()
    self.session = session
    self.player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    print("INIT")

    self.player.loginWithSession(self.session) { (error) -> Void in
      if error != nil {
        print(error)
      }

      self.playMusic()
      self.getUser()
    }

    cbScan()
    cbBroadcast()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  deinit {
    myCentralManager.stopScan()
    myPeripheralManager.stopAdvertising()
  }

  func getUser() {
    SPTUser.requestCurrentUserWithAccessToken(session.accessToken) { (error, resp) -> Void in
      let user = resp as! SPTUser

      let l = UILabel()
      l.text = "Hi, \(user.displayName)"
      l.textColor = .blackColor()
      l.font = UIFont.systemFontOfSize(30)
      self.view.addSubview(l)
      l.snp_makeConstraints { make in
        make.center.equalTo(self.view)
      }

      let broadcasting = UILabel()
      broadcasting.text = "Broadcasting \(trackID)"
      broadcasting.textColor = .blackColor()
      self.view.addSubview(broadcasting)
      broadcasting.snp_makeConstraints { make in
        make.centerX.equalTo(l.snp_centerX)
        make.top.equalTo(l.snp_bottom).offset(20)
      }
    }
  }

  func playMusic() {
    let trackURL = NSURL(string: "spotify:track:\(trackID)")
    self.player.playURIs([trackURL!], fromIndex: 0) { (error) -> Void in
      if error != nil {
        print(error)
      }
      print("success!")
    }
  }

  func cbScan() {
    myCentralManager = CBCentralManager(delegate: self, queue: nil)
  }

  func cbBroadcast() {
    myPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
  }

}

extension ViewController : CBCentralManagerDelegate, CBPeripheralDelegate {
  func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
    print(peripheral)
    discoveredPeripherals.append(peripheral)
    central.connectPeripheral(peripheral, options: nil)
  }

  func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
    print("connected...")
    print("discovering services...")
    peripheral.delegate = self
    peripheral.discoverServices([CBUUID(NSUUID: serviceUUID)])
  }

  func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
      print("discovering characteristics...")
      peripheral.discoverCharacteristics([CBUUID(NSUUID: characteristicUUID)], forService: (peripheral.services?.first)!)
  }

  func centralManagerDidUpdateState(central: CBCentralManager) {
    if central.state == .PoweredOn {
      print("Powered on...")
      central.scanForPeripheralsWithServices([CBUUID(NSUUID: serviceUUID)], options: nil)
    }
  }

  func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
    peripheral.readValueForCharacteristic((service.characteristics?.first)!)
  }

  func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    print("reading value for characteristic: ")
    let val = String(data: characteristic.value!, encoding: NSUTF8StringEncoding)
    let alert = UIAlertController(title: "Found Nearby!", message: val!, preferredStyle: .Alert)
    self.presentViewController(alert, animated: true, completion: nil)
  }
}




extension ViewController : CBPeripheralManagerDelegate {
  func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
    if peripheral.state == .PoweredOn {
      peripheral.addService(service)
    }
  }

  func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
    print("added service successfully")
    peripheral.startAdvertising([
      CBAdvertisementDataServiceUUIDsKey: [service.UUID]
    ])
  }

  func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
    print("advertising....")
  }

  func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
    print("received read request")
    if request.characteristic.UUID == service.characteristics!.first!.UUID {
      print("responding...")
      request.value = trackID.dataUsingEncoding(NSUTF8StringEncoding)
      peripheral.respondToRequest(request, withResult: .Success)
    }
  }
}





























