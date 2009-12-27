/* 
 * Autore: Amedeo Salvati
 * e-mail: amedeo.salvati@gmail.com
 *
 * Semplice programma utilizzato per accendere la luce dell'ingresso
 * all'apertura della porta e con luminosita' ridotta
 *
 */

#include <stdio.h>

#define SENSOR 0  
#define BUTTON 12
#define BUZZ 3
#define DELAY 2000

#define RLED1 11
#define BLED1 10
#define GLED1 9

int val = 0; // variable to store the value coming from the sensor

unsigned long time;

unsigned int lum;

unsigned long iLastRead;

void buzzer() {
  analogWrite(BUZZ, 0);
  delay(20);
  analogWrite(BUZZ, 255);
  delay(20);
}

void toSerial( char sLog[ ], boolean bLineNew = false ) {
  
  Serial.print( sLog );
  
//  bLineNew = false;
  
  if( bLineNew == true ) {
    Serial.println( "" );
  }
}

void setup() {
  Serial.begin(9600);  // open the serial port
}

void loop() {
  val = analogRead(SENSOR);
  
  time = millis();
  
  //effettivi secondi
  time = time / 1000;
  
  char sTime[ 6 ];
  
  sprintf( sTime, "%u", time);
  toSerial( "Tempo: ", false);
  toSerial( sTime, true);

  delay(DELAY);
  
}

