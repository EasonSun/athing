/*
    Based on Neil Kolban example for IDF: https://github.com/nkolban/esp32-snippets/blob/master/cpp_utils/tests/BLE%20Tests/SampleWrite.cpp
    Ported to Arduino ESP32 by Evandro Copercini
*/

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/
// Do I need a different UUID for each box?
// Do I have to follow GATT, whenever possible?
// https://randomnerdtutorials.com/esp32-bluetooth-low-energy-ble-arduino-ide/
// A characteristic value can be up to 20 bytes long => 160 lights. fine.

#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define LightingCtrlCharUUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define LightingReadyCharUUID "beb5483e-1fb5-4688-8fcc-ea07361b26a8"

BLECharacteristic *pLightingCtrlChar;
BLECharacteristic *pLightingReadyChar;
bool lightingReady = false;
uint32_t value = 1;
    
class MyToyCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string value = pCharacteristic->getValue();

      if (value.length() > 0) {
        Serial.println("*********");
        Serial.print("New value: ");
        for (int i = 0; i < value.length(); i++)
          Serial.print(value[i]);

        Serial.println();
        Serial.println("*********");
      }


      digitalWrite(LED_BUILTIN, HIGH);   // turn the LED on (HIGH is the voltage level)
      delay(1000);                       // wait for a second   
      lightingReady = true;      
    }
};


class MyCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string value = pCharacteristic->getValue();

      // TODO send light array on/off matrix as a number; 1 light per byte

      lightingReady = true; // AFTER LIGHTING CTRL IS DONE
    }
};

void setup() {
  Serial.begin(9600);

  Serial.println("1- Download and install an BLE scanner app in your phone");
  Serial.println("2- Scan for BLE devices in the app");
  Serial.println("3- Connect to MyESP32");
  Serial.println("4- Go to CUSTOM CHARACTERISTIC in CUSTOM SERVICE and write something");
  Serial.println("5- See the magic =)");

  // initialize digital pin LED_BUILTIN as an output.
  pinMode(LED_BUILTIN, OUTPUT);

  BLEDevice::init("StikLight");
  BLEServer *pLightingServer = BLEDevice::createServer();

  BLEService *pLightingCtrlService = pLightingServer->createService(SERVICE_UUID);
  
  pLightingCtrlChar = pLightingCtrlService->createCharacteristic(
                                         LightingCtrlCharUUID,
                                         BLECharacteristic::PROPERTY_READ |
                                         BLECharacteristic::PROPERTY_WRITE
                                       );

  pLightingReadyChar = pLightingCtrlService->createCharacteristic(
                                         LightingReadyCharUUID,
                                         BLECharacteristic::PROPERTY_NOTIFY
                                       );
                                       

  pLightingCtrlChar->setCallbacks(new MyToyCallbacks());

//  pCharacteristic->setValue("Hello World");
  pLightingCtrlService->start();

  BLEAdvertising *pAdvertising = pLightingServer->getAdvertising();
  pAdvertising->start();
}

void loop() {
  // put your main code here, to run repeatedly:
//  delay(2000);

  if (lightingReady) {
    pLightingReadyChar -> setValue((uint8_t*)&value, 4); // (value, size) http://www.neilkolban.com/esp32/docs/cpp_utils/html/class_b_l_e_characteristic.html
    pLightingReadyChar -> notify();
    delay(3);
    digitalWrite(LED_BUILTIN, LOW);
    lightingReady = false;
  }
}
