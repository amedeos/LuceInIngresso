#define SENSOR 0  
#define BUTTON 12
#define BUZZ 3
#define DELAY 2000

#define RLED1 11
#define BLED1 10
#define GLED1 9

int val = 0; // variable to store the value coming from the sensor

int i = 0;

unsigned long time;

unsigned int lum;

void buzzer() {
  analogWrite(BUZZ, 0);
  delay(20);
  analogWrite(BUZZ, 255);
}

void setup() {
  Serial.begin(9600);  // open the serial port
}

void loop() {
  val = analogRead(SENSOR);
  
  time = millis();
  
  time = time / 1000;
  
//  analogWrite(GLED1, 255);
  
  delay(DELAY);
  
}

