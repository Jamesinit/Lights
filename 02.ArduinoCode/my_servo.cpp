#include "my_servo.h"

my_servo::  my_servo(PinName pwm_pin,PinName ctr_pin){
  this->pwm_pin=pwm_pin;
  this->ctr_pin=ctr_pin;
}

my_servo::~my_servo(){

}
void my_servo::init(){
  this->servo = Servo{};
  this->servo.attach(pwm_pin);
  pinMode(ctr_pin, OUTPUT);
  digitalWrite(ctr_pin, LOW);
}


 

       
void my_servo::move_degree(int start, int end, int gap_ms, int sept) {
   s_open();
   if (start > end) {
      // 递减循环
      for (int i = start; i > end; i -= sept) {
         servo.write(i);
         delay(gap_ms);
      }
   } else {
      // 递增循环
      for (int i = start; i < end; i += sept) {
         servo.write(i);     
         delay(gap_ms);
      }
   }
   s_off();
}
void my_servo::s_open(){
  digitalWrite(ctr_pin, HIGH);
}
void my_servo::s_off(){
    digitalWrite(ctr_pin, LOW);
}

void my_servo::set_gapms(int gap_time){
  this->gap_ms = gap_time;
}
void my_servo::spin_degree(int start,int end){
  move_degree( start,  end, this->gap_ms);
}

