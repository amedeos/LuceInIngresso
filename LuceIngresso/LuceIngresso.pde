/* 
 * Autore: Amedeo Salvati
 * e-mail: amedeo.salvati@gmail.com
 *
 * Data: 27/12/2009
 *
 * Semplice programma utilizzato per accendere la luce dell'ingresso
 * all'apertura della porta e con luminosita' ridotta
 *
 * Versione: 0.0.1
 */

#include <stdio.h>

#define SENSORLUM 0 //fotoresistore
#define BUTTON 12
#define BUZZ 3
#define SENSORIR 5 //sensore IR sulla porta
#define DELAY 200 //delay immesso alla fine del ciclo loop
#define DEBOUNCING 30 //delay immesso per il de-bouncing del bottone
#define SECRESET 6

//variabile che definisce la luminosita' minima
#define MINLUM 70

#define RLED1 11
#define BLED1 10
#define GLED1 9

//se impostata ad 1 logga sulla seriale alcune informazioni
#define DEBUG 1

int iVal = 0; // variable to store the value coming from the sensor
int iVal1 = 0; //variabile che memorizza il valore di iVal SECRESET prima
int iVal2 = 0; //variabile che memorizza il valore di iVal SECRESET*2 prima

//variabili utilizzate per sapere se il bottone e' stato premuto
int iBut = 0;
int iBut1 = 0;
int state = 0;

unsigned long time;

unsigned long lButStartTime;

unsigned int lum;

unsigned long iLastRead = 0;

void buzzer() {
  analogWrite(BUZZ, 0);
  delay(10);
  analogWrite(BUZZ, 255);
  delay(10);
}

void toSerial( char sLog[ ], boolean bLineNew = false ) {
  
  Serial.print( sLog );
  
  if( bLineNew == true ) {
    Serial.println( "" );
  }
}

void setup() {
  Serial.begin(9600);  // open the serial port
}

void loop() {
  iVal = analogRead(SENSORLUM);
  
  time = millis();
  
  //conversione in secondi
  time = time / 1000;
  
  char sVal[ 20 ];
  
  iBut = digitalRead( BUTTON );
  
  if( DEBUG ) {
    sprintf( sVal, "%u", time);
    toSerial( "Tempo: ", false);
    toSerial( sVal, false);
    toSerial( " Bottone: ", false);
    sprintf( sVal, "%i", iBut);
    toSerial( sVal, true);
  }
  
  if( ( iBut == HIGH ) && ( iBut1 == LOW ) ) {
    state = 1 - state;
    
    lButStartTime = millis();
    
    //piccolo delay immesso per il de-bouncing
    delay(DEBOUNCING);
  }
  
  if( ( iBut == HIGH ) && ( iBut1 == HIGH ) ) {
    
    if( state == 1 && (millis() - lButStartTime > 500 ) ) {
      for( int i = 0; i < 10; i++ ){
        buzzer();
      }
    }
  }
  
  iBut1 = iBut;
  
  // finche' time < DELAY * 2 sec lo resetto
  // altrimenti lo resetto se supera SECRESET
  if( ( time < (DELAY/1000*2) ) || ( (time - iLastRead) > SECRESET ) ) {
    
    if( DEBUG ) {
      toSerial( "Eseguo il reset del contatore... iVal1': " , false);
      sprintf( sVal, "%i", iVal1 );
      toSerial( sVal, false);
      toSerial( " Al secondo: ", false);
      sprintf( sVal, "%u", iLastRead );
      toSerial( sVal, false);
      toSerial( " iVal2: ", false );
      sprintf( sVal, "%i", iVal2 );
      toSerial( sVal, true);
      toSerial( "Nuovo valore di luminosita': ", false );
      sprintf( sVal, "%i", iVal );
      toSerial( sVal, false);
      toSerial( " Al secondo: ", false );
      sprintf( sVal, "%u", time );
      toSerial( sVal, true);
    } 
    
    iLastRead = time;
    iVal2 = iVal1;
    iVal1 = iVal;
  }
  
  //immetto un delay
  delay(DELAY);
  
}

