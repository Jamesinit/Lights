
#include "my_servo.h"




#define PWM1 PA_4
#define PWM2 PA_7
#define Servo1PowerPin PA_5
#define Servo2PowerPin PA_6
HardwareSerial Serial2(PA1, PA0);
my_servo servo_1(PWM1,Servo1PowerPin);
my_servo servo_2(PWM2,Servo2PowerPin);
String readString;
volatile bool newData = false;





void setup() {
  Serial.begin(115200);
  Serial2.begin(9600); // 设置串口2的波特率为9600
  Serial.printf("Hello, Air001. \n");

  servo_1.init();
  servo_1.set_gapms(10);
  servo_2.init();
  servo_2.set_gapms(10);
  digitalWrite(Servo1PowerPin, LOW);
  digitalWrite(Servo2PowerPin, LOW);
  


}

void loop() {
processSerialData();
}



void receive_data_from_ble(){
  while (Serial2.available() > 0){
  char receivedChar = Serial2.read();
    if (receivedChar == ';') {
      newData = true;
      break;
    }
    readString += receivedChar;
  }
}
void command_process(){
  
     int pos1 = readString.indexOf('-');
    int pos2 = readString.indexOf('-', pos1 + 1);
    int angle1 = readString.substring(pos1 + 1, pos2).toInt();
    int angle2 = readString.substring(pos2 + 1).toInt();
    if (readString.startsWith("Servo1")) {
      // servo 1 ctrol
        Serial.printf("Servo1 start:%d - %d",angle1,angle2);
        servo_1.spin_degree(angle1, angle2);
        Serial2.printf("Servo1 OK!");
      } else if (readString.startsWith("Servo2")) {
      // servo 2 ctrol
        Serial.printf("Servo2 start:%d - %d",angle1,angle2);
        servo_2.spin_degree(angle1, angle2);
        Serial2.printf("Servo1 OK!");
      }    
                                                       

}
void processSerialData(){
    receive_data_from_ble();
    if(newData) {
      // 将接收到的命令字符串传递到串口1
      Serial.println(readString);
      
      command_process();
      newData = false;
      readString = "";
    }

}


