/*

  Copyright (c) 2012-2014 RedBearLab

  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

/*
      HelloWorld

      HelloWorld sketch, work with the Chat iOS/Android App.
      It will send "Hello World" string to the App every 1 sec.

*/

//"RBL_nRF8001.h/spi.h/boards.h" is needed in every new project
#include <SPI.h>
#include <EEPROM.h>
#include <boards.h>
#include <RBL_nRF8001.h>
#include <RBL_services.h>

#include <Wire.h>
#include "I2Cdev.h"
#include "MPU6050.h"


MPU6050 accelgyro;

int16_t ax, ay, az;
int16_t gx, gy, gz;

bool collectingData = false;

void setup()
{
  //
  // For BLE Shield and Blend:
  //   Default pins set to 9 and 8 for REQN and RDYN
  //   Set your REQN and RDYN here before ble_begin() if you need
  //
  // For Blend Micro:
  //   Default pins set to 6 and 7 for REQN and RDYN
  //   So, no need to set for Blend Micro.
  //
  //ble_set_pins(3, 2);

  // Set your BLE advertising name here, max. length 10
  ble_set_name("LeftCompanion");

  // Init. and start BLE library.
  ble_begin();

  
  // Enable serial debug
  Serial.begin(38400);

  // initialize device
  Serial.println("Initializing I2C devices...");
  accelgyro.initialize();

  // verify connection
  Serial.println("Testing device connections...");
  Serial.println(accelgyro.testConnection() ? "MPU6050 connection successful" : "MPU6050 connection failed");
  
}

void loop()
{

  if (collectingData) {
    accelgyro.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);

    /*
     * TEST VALUES
      ax = 251;
      ay = -1003;
      az= 9532;
      gx = 8012;
      gy = -315;
      gz = -606;
    */
    

   //Little endian. i.e low byte first 
    unsigned char sensorBuf[16] = {'A', ((byte *) &ax)[0] , ((byte *) &ax)[1] ,((byte *) &ay)[0] ,((byte *) &ay)[1] ,((byte *) &az)[0] , ((byte *) &az)[1] ,  'D', 
                                 'G', ((byte *) &gx)[0] , ((byte *) &gx)[1] , ((byte *) &gy)[0] , ((byte *) &gy)[1] , ((byte *) &gz)[0]  , ((byte *) &gz)[1] , 'D'};
    
    ble_write_bytes(sensorBuf, 16);
   
    
    /*
    Serial.print("a/g:\t");
    Serial.print(ax); Serial.print("\t");
    Serial.print(ay); Serial.print("\t");
    Serial.print(az); Serial.print("\t");
    Serial.print(gx); Serial.print("\t");
    Serial.print(gy); Serial.print("\t");
    Serial.println(gz);
    */

  }
  
 if ( ble_connected() ) {
   if (ble_available()) {
     if (ble_read() == 'Y') {
       collectingData = true;
     } else if (ble_read() == 'N') {
       collectingData = false;
     }
  }
 }
  

  ble_do_events();
  delay(500);
}



