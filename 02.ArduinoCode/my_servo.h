#ifndef __MY_SERVO_H__
#define __MY_SERVO_H__

#include <Servo.h>
#include <Arduino.h>

class my_servo{
  private:
    PinName pwm_pin;
    PinName ctr_pin;
    Servo servo;
    int gap_ms;
  public:
    my_servo(PinName pwm_pin,PinName ctr_pin);
    ~my_servo();

    void init();
    void move_degree(int start,int end,int gap_ms,int sept = 1);
    void set_gapms(int gap_time);
    void spin_degree(int start,int end);
    void s_open();
    void s_off();
};

#endif