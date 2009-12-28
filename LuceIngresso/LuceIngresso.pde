/* 
 * Autore: Amedeo Salvati
 * e-mail: amedeo.salvati@gmail.com
 *
 * Data: 27/12/2009
 *
 * Semplice programma utilizzato per accendere la luce dell'ingresso
 * all'apertura della porta e con luminosita' ridotta
 *
 * Versione: 0.0.2
 */
 
/* This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * Or see http://www.gnu.org/licenses/gpl.txt
 * Copyright Amedeo Salvati
 *   ,           ,
 *  /             \
 * ((__-^^-,-^^-__))
 * `-_---'  `---_-'
 *  `--|o`   'o|--'
 *      \  `  /
 *       ): :(
 *       :o_o:
 *        "-"
 */

#include <stdio.h>

//se impostata ad 1 logga sulla seriale alcune informazioni
#define DEBUG 1

#define SENSORLUM 0 //fotoresistore
#define BUTTON 12
#define BUZZ 3
#define SENSORIR 5 //sensore IR sulla porta
#define DELAY 100 //delay immesso alla fine del ciclo loop
#define DEBOUNCING 30 //delay immesso per il de-bouncing del bottone
#define SECRESET 6 //ogni quanti secondi memorizzare la luminosita'
#define SECBUTTON 2000 //ogni quanti millisecondi premendo il bottone si cambiera' colore

//variabile che definisce la luminosita' minima
#define MINLUM 70

//variabile che definisce la distanza massima
#define MAXDISTANCE 50

//quanti minuti lasciare accesi i led 
#define MINHIGH 1

#define RLED 11
#define GLED 10
#define YLED 9

#if DEBUG>0
#undef DELAY
#define DELAY 300
#endif

int iVal = 0; // variable to store the value coming from the sensor
int iVal1 = 0; //variabile che memorizza il valore di iVal SECRESET prima
int iVal2 = 0; //variabile che memorizza il valore di iVal SECRESET*2 prima

//variabili utilizzate per sapere se il bottone e' stato premuto
int iBut = 0;
int iBut1 = 0;
int state = 0;

//variabile contatore
int i = 0;

//variabili utilizzate per il sensore IR
int iDistance = 0;
boolean bHigh = false;

unsigned long time;

unsigned long lButStartTime;

unsigned long lDoorStartTime;

unsigned int lum;

unsigned long iLastRead = 0;

void allLedHigh(){
  //accende tutti i led 
  analogWrite(RLED, 255);
  analogWrite(GLED, 255);
  analogWrite(YLED, 255);
}

void allLedLow(){
  analogWrite(RLED, 0);
  analogWrite(GLED, 0);
  analogWrite(YLED, 0);
}

void toRed(){
  //colora di rosso il tutto
  analogWrite(RLED, 255);
  analogWrite(GLED, 0);
  analogWrite(YLED, 0);
}

void toGreen(){
  //colora di verde il tutto
  analogWrite(RLED, 0);
  analogWrite(GLED, 255);
  analogWrite(YLED, 0);
}

void toYellow(){
  //colora di giallo il tutto
  analogWrite(RLED, 0);
  analogWrite(GLED, 0);
  analogWrite(YLED, 255);
}

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

#if DEBUG>0
  sprintf( sVal, "%u", time);
  toSerial( "Tempo: ", false);
  toSerial( sVal, false);
  toSerial( " Bottone: ", false);
  sprintf( sVal, "%i", iBut);
  toSerial( sVal, false);
#endif

  if( ( iBut == HIGH ) && ( iBut1 == LOW ) ) {
    state = 1 - state;

    lButStartTime = millis();

    //piccolo delay immesso per il de-bouncing
    delay(DEBOUNCING);

    if( state ==1 ){
      toYellow();
    }
  }

#if DEBUG>0
  toSerial( " Stato: ", false );
  sprintf( sVal, "%i", state);
  toSerial( sVal, true);
#endif

  if( ( iBut == HIGH ) && ( iBut1 == HIGH ) ) {

    if( state == 1){
      if( millis() - lButStartTime > SECBUTTON*4 ) {
#if DEBUG>0
        toSerial( "Bottone premuto piu' di ", false);
        sprintf( sVal, "%i", SECBUTTON*4);
        toSerial( sVal, false);
        toSerial( "ms", true );
#endif
        //immettere qui il codice per richiamare un colore
        allLedHigh();
        for( i = 0; i < SECBUTTON/50; i++) {
          buzzer();
        }
      } 
      else if( millis() - lButStartTime > SECBUTTON*3 ) {
#if DEBUG>0
        toSerial( "Bottone premuto piu' di ", false);
        sprintf( sVal, "%i", SECBUTTON*3);
        toSerial( sVal, false);
        toSerial( "ms", true );
#endif
        //immettere qui il codice per richiamare un colore
        allLedLow();
        for( i = 0; i < SECBUTTON/50; i++) {
          buzzer();
        }
      } 
      else if( millis() - lButStartTime > SECBUTTON*2 ) {
#if DEBUG>0
        toSerial( "Bottone premuto piu' di ", false);
        sprintf( sVal, "%i", SECBUTTON*2);
        toSerial( sVal, false);
        toSerial( "ms", true );
#endif
        //immettere qui il codice per richiamare un colore
        toRed();
        for( i = 0; i < SECBUTTON/50; i++) {
          buzzer();
        }
      } 
      else if( millis() - lButStartTime > SECBUTTON ) {
#if DEBUG>0
        toSerial( "Bottone premuto piu' di ", false);
        sprintf( sVal, "%i", SECBUTTON);
        toSerial( sVal, false);
        toSerial( "ms", true );
#endif
        //immettere qui il codice per richiamare un colore
        toGreen();
        for( i = 0; i < SECBUTTON/50; i++) {
          buzzer();
        }        
      }
    } //end if state == 1
  } //end if ( iBut == HIGH ) && ( iBut1 == HIGH )

  iBut1 = iBut;

  //adesso bisogna verificare se accendere automatimante i led
  //se viene aperta la porta e la luminosita' e' bassa
  if( state == 0 ) {
    allLedLow();

    iDistance = analogRead(SENSORIR);

#if DEBUG>1
    toSerial( "Distanza rilevata: ", false );
    sprintf( sVal, "%i", iDistance);
    toSerial( sVal, true);
#endif

    if( iDistance > MAXDISTANCE ) {
      //porta aperta 
      lDoorStartTime = millis();
      bHigh = true;

      //se uno dei valori di iVal e' minore di MINLUM allora accendo i led
      if( ( iVal < MINLUM ) || ( iVal1 < MINLUM ) || ( iVal2 < MINLUM ) ){
        for( i = 0; i < 10; i++){
          buzzer();
        }

        //selezioniamo un colore a caso
        i = lDoorStartTime % 4;
        switch (i) {
        case 0:
          toYellow();
          break;
        case 1:
          toGreen();
          break;
        case 2:
          toRed();
          break;
        case 3:
          allLedHigh();
          break; 
        }
        
        int iButTmp = 0;
        //entro nel loop finche' non sono passati tanti minuti quanti sono MINHIGH
        do
        {
          if( ( (millis() - lDoorStartTime) / 1000 ) > ( MINHIGH * 60 ) ) {
            bHigh = false;
            
            #if DEBUG>0
              toSerial( "Passato il tempo massimo... spengo tutto", true );
            #endif
          }
          
          iButTmp = digitalRead( BUTTON );
          if( iButTmp == HIGH ) {
            bHigh = false;
            
            #if DEBUG>0
              toSerial( "E' stato premuto il bottore... spengo tutto", true );
            #endif
          }
          delay(100);
        } 
        while ( bHigh );
      }

    }//end if iDistance > MAXDISTANCE

  }//end if state == 0

  // finche' time < DELAY * 2 sec lo resetto
  // altrimenti lo resetto se supera SECRESET
  if( ( time < (DELAY/1000*2) ) || ( (time - iLastRead) > SECRESET ) ) {

#if DEBUG>0
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
#endif

    iLastRead = time;
    iVal2 = iVal1;
    iVal1 = iVal;
  }

  //immetto un delay ad ogni loop
  //valutare se renderlo granulare a seconda di quello che si sta facendo,
  //ad esempio se state == 1 allora DELAY = DELAY / X
  delay(DELAY);

}


