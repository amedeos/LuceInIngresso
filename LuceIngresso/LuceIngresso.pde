/* 
 * Autore: Amedeo Salvati
 * e-mail: amedeo.salvati@gmail.com
 *
 * Data: 27/12/2009
 *
 * Semplice programma utilizzato per accendere la luce dell'ingresso
 * all'apertura della porta e con luminosita' ridotta
 *
 * Versione: 0.0.5
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

//al momento stdio.h non e' utilizzato e il compilatore non lo include
#include <stdio.h>

//se impostata ad 1 logga sulla seriale alcune informazioni
#define DEBUG 1

#define SENSORLUM 0 //fotoresistore
#define BUTTON 12
#define BUZZ 9
#define SENSORIR 5 //sensore IR sulla porta
#define DELAY 100 //delay immesso alla fine del ciclo loop
#define DEBOUNCING 30 //delay immesso per il de-bouncing del bottone
#define SECRESET 6 //ogni quanti secondi memorizzare la luminosita'
#define SECBUTTON 2000 //ogni quanti millisecondi premendo il bottone si cambiera' colore

//variabile che definisce la luminosita' minima
#define MINLUM 70

//variabile che definisce la distanza massima e minima
#define MAXDISTANCE 450  //da tarare
#define MINDISTANCE 400  //da tarare

#if DEBUG>0
  #undef MAXDISTANCE
  #undef MINDISTANCE
  #define MAXDISTANCE 200
  #define MINDISTANCE 0
#endif

//quanti minuti lasciare accesi i led 
#define MINHIGH 1

#define RLED 6
#define GLED 5
#define BLED 3

#define IBLACK 0
#define IWHITE 1
#define IRED 2
#define IGREEN 3
#define IBLUE 4
#define IYELLOW 5
#define IMAGENTA 6
#define ICYAN 7
#define IGRAY 8
#define ITEAL 9
#define IORANGE 10
#define IOLIVE 11
#define IPURPLE 12

#if DEBUG>0
  #undef DELAY
  #define DELAY 300
#endif

//funzioni utilizzate per i colori
void toWhite();
void toBlack();
void toRed();
void toGreen();
void toBlue();
void toYellow();
void toMagenta();
void toCyan();
void toGray();
void toTeal();
void toOrange();
void toOlive();
void toPurple();

//funzioni utilizzate per segnalare acusticamente un cambiamento
void buzzer();
void buzzer( int *num, int *nDelay );

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

//variabile utilizzata per sapere quale colore precedentemente era acceso
int iColor = 0;
int iColor1 =0;


void setup() {
  Serial.begin(9600);  // open the serial port
  pinMode( BUZZ, OUTPUT );
  pinMode( GLED, OUTPUT );
  pinMode( RLED, OUTPUT );
  pinMode( BLED, OUTPUT );
  
  randomSeed( analogRead( 1 ) );  //inizializzo il seme dei num casuali con la lettura da un pin non utilizzato
}

void loop() {
  iVal = analogRead(SENSORLUM);

  time = millis();

  //conversione in secondi
  time = time / 1000;

  iBut = digitalRead( BUTTON );
  
  #if DEBUG>0
    Serial.print( "Tempo: " );
    Serial.print( time );
    Serial.print( " Bottone: " );
    Serial.print( iBut );
  #endif

  if( ( iBut == HIGH ) && ( iBut1 == LOW ) ) {
    state = 1 - state;

    lButStartTime = millis();

    //piccolo delay immesso per il de-bouncing
    delay(DEBOUNCING);

    if( state ==1 ){
      toWhite();
      if( iColor1 != iColor ){
        buzzer();
        iColor1 = iColor;
      }
    }
  }

  #if DEBUG>0
    Serial.print( " Stato: " );
    Serial.println( state );
  #endif

  if( ( iBut == HIGH ) && ( iBut1 == HIGH ) ) {

    if( state == 1){
      if( millis() - lButStartTime > SECBUTTON*11 ) {
        #if DEBUG>0
          Serial.print( "Bottone premuto piu' di " );
          Serial.print( SECBUTTON*11 );
          Serial.println( "ms" );
        #endif
        //immettere qui il codice per richiamare un colore
        toPurple();
        if( iColor1 != iColor ){
          buzzer();
          iColor1 = iColor;
        }
      }
      else if( millis() - lButStartTime > SECBUTTON*10 ) {
        #if DEBUG>0
          Serial.print( "Bottone premuto piu' di " );
          Serial.print( SECBUTTON*10 );
          Serial.println( "ms" );
        #endif
        //immettere qui il codice per richiamare un colore
        toOlive();
        if( iColor1 != iColor ){
          buzzer();
          iColor1 = iColor;
        }
      }
      else if( millis() - lButStartTime > SECBUTTON*9 ) {
        #if DEBUG>0
          Serial.print( "Bottone premuto piu' di " );
          Serial.print( SECBUTTON*9 );
          Serial.println( "ms" );
        #endif
        //immettere qui il codice per richiamare un colore
        toOrange();
        if( iColor1 != iColor ){
          buzzer();
          iColor1 = iColor;
        }
      }
      else if( millis() - lButStartTime > SECBUTTON*8 ) {
        #if DEBUG>0
          Serial.print( "Bottone premuto piu' di " );
          Serial.print( SECBUTTON*8 );
          Serial.println( "ms" );
        #endif
        //immettere qui il codice per richiamare un colore
        toTeal();
        if( iColor1 != iColor ){
          buzzer();
          iColor1 = iColor;
        }
      }
      else if( millis() - lButStartTime > SECBUTTON*7 ) {
        #if DEBUG>0
          Serial.print( "Bottone premuto piu' di " );
          Serial.print( SECBUTTON*7 );
          Serial.println( "ms" );
        #endif
        //immettere qui il codice per richiamare un colore
        toGray();
        if( iColor1 != iColor ){
          buzzer();
          iColor1 = iColor;
        }
      }
      else if( millis() - lButStartTime > SECBUTTON*6 ) {
        #if DEBUG>0
          Serial.print( "Bottone premuto piu' di " );
          Serial.print( SECBUTTON*6 );
          Serial.println( "ms" );
        #endif
        //immettere qui il codice per richiamare un colore
        toCyan();
        if( iColor1 != iColor ){
          buzzer();
          iColor1 = iColor;
        }
      }
      else if( millis() - lButStartTime > SECBUTTON*5 ) {
        #if DEBUG>0
          Serial.print( "Bottone premuto piu' di " );
          Serial.print( SECBUTTON*5 );
          Serial.println( "ms" );
        #endif
        //immettere qui il codice per richiamare un colore
        toMagenta();
        if( iColor1 != iColor ){
          buzzer();
          iColor1 = iColor;
        }
      }
      else if( millis() - lButStartTime > SECBUTTON*4 ) {
        #if DEBUG>0
          Serial.print( "Bottone premuto piu' di " );
          Serial.print( SECBUTTON*4 );
          Serial.println( "ms" );
        #endif
        //immettere qui il codice per richiamare un colore
        toYellow();
        if( iColor1 != iColor ){
          buzzer();
          iColor1 = iColor;
        }
      } 
      else if( millis() - lButStartTime > SECBUTTON*3 ) {
        #if DEBUG>0
          Serial.print( "Bottone premuto piu' di " );
          Serial.print( SECBUTTON*3 );
          Serial.println( "ms" );
        #endif
        //immettere qui il codice per richiamare un colore
        toBlue();
        if( iColor1 != iColor ){
          buzzer();
          iColor1 = iColor;
        }
      } 
      else if( millis() - lButStartTime > SECBUTTON*2 ) {
        #if DEBUG>0
          Serial.print( "Bottone premuto piu' di " );
          Serial.print( SECBUTTON*2 );
          Serial.println( "ms" );
        #endif
        //immettere qui il codice per richiamare un colore
        toGreen();
        if( iColor1 != iColor ){
          buzzer();
          iColor1 = iColor;
        }
      } 
      else if( millis() - lButStartTime > SECBUTTON ) {
        #if DEBUG>0
          Serial.print( "Bottone premuto piu' di " );
          Serial.print( SECBUTTON );
          Serial.println( "ms" );
        #endif
        //immettere qui il codice per richiamare un colore
        toRed();
        if( iColor1 != iColor ){
          buzzer();
          iColor1 = iColor;
        }
      }
    } //end if state == 1
  } //end if ( iBut == HIGH ) && ( iBut1 == HIGH )

  iBut1 = iBut;

  //adesso bisogna verificare se accendere automatimante i led
  //se viene aperta la porta e la luminosita' e' bassa
  if( state == 0 ) {
    toBlack();
    if( iColor1 != iColor ){
      buzzer();
      iColor1 = iColor;
    }

    iDistance = analogRead(SENSORIR);

    #if DEBUG>1
      Serial.print( "Distanza rilevata: " );
      Serial.println( iDistance );
    #endif

    if( (iDistance > MAXDISTANCE) || ( iDistance < MINDISTANCE ) ) {
      //porta aperta 
      lDoorStartTime = millis();
      bHigh = true;

      //se uno dei valori di iVal e' minore di MINLUM allora accendo i led
      if( ( iVal < MINLUM ) || ( iVal1 < MINLUM ) || ( iVal2 < MINLUM ) ){
        //selezioniamo un colore a caso
        i = random( 12 );
        switch (i) {
        case 0:
          toWhite();
          Serial.println( "Bianco!" );
          break;
        case 1:
          toRed();
          Serial.println( "Rosso!" );
          break;
        case 2:
          toGreen();
          Serial.println( "Verde!" );
          break;
        case 3:
          toBlue();
          Serial.println( "Blu!" );
          break;
        case 4:
          toYellow();
          Serial.println( "Giallo!" );
          break;
        case 5:
          toMagenta();
          Serial.println( "Magenta!" );
          break;
        case 6:
          toCyan();
          Serial.println( "Ciano!" );
          break;
        case 7:
          toGray();
          Serial.println( "Grigio!" );
          break;
        case 8:
          toTeal();
          Serial.println( "Teal!" );
          break;
        case 9:
          toOrange();
          Serial.println( "Arancione!" );
          break;
        case 10:
          toOlive();
          Serial.println( "Oliva!" );
          break;
        case 11:
          toPurple();
          Serial.println( "Porpora!" );
          break;
        }
        
        if( iColor1 != iColor ){
          buzzer();
          iColor1 = iColor;
        }
        
        int iButTmp = 0;
        //entro nel loop finche' non sono passati tanti minuti quanti sono MINHIGH
        do
        {
          if( ( (millis() - lDoorStartTime) / 1000 ) > ( MINHIGH * 60 ) ) {
            bHigh = false;
            
            #if DEBUG>0
              Serial.println( "Passato il tempo massimo... spengo tutto" );
            #endif
          }
          
          iButTmp = digitalRead( BUTTON );
          if( iButTmp == HIGH ) {
            bHigh = false;
            
            #if DEBUG>0
              Serial.println( "E' stato premuto il bottore... spengo tutto" );
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
      Serial.print( "Eseguo il reset del contatore... iVal1': " );
      Serial.print( iVal1 );
      Serial.print( " Al secondo: " );
      Serial.print( iLastRead );
      Serial.print( " iVal2: " );
      Serial.println( iVal2 );
      Serial.print( "Nuovo valore di luminosita': " );
      Serial.print( iVal );
      Serial.print( " Al secondo: " );
      Serial.println( time );
    #endif

    iLastRead = time;
    iVal2 = iVal1;
    iVal1 = iVal;
  }

  //immetto un delay ad ogni loop
  //valutare se renderlo granulare a seconda di quello che si sta facendo,
  //ad esempio se state == 1 allora DELAY = DELAY / X
  delay(DELAY);

}//end loop

void toWhite(){
  //accende tutti i led -> bianco
  analogWrite(RLED, 255);
  analogWrite(GLED, 255);
  analogWrite(BLED, 255);
  
  iColor = IWHITE;
  
  #if DEBUG>1
    Serial.print( "Accendo tutti i led -> bianco!" );
    Serial.println( "" );
  #endif
}

void toBlack(){
  //spegne tutti i led -> nero
  analogWrite(RLED, 0);
  analogWrite(GLED, 0);
  analogWrite(BLED, 0);
  
  iColor = IBLACK;
  
  #if DEBUG>1
    Serial.print( "Spengo tutti i led -> nero" );
    Serial.println( "" );
  #endif
}

void toRed(){
  //colora di rosso il tutto
  analogWrite(RLED, 255);
  analogWrite(GLED, 0);
  analogWrite(BLED, 0);
  
  iColor = IRED;
  
  #if DEBUG>1
    Serial.print( "Coloro di rosso!" );
    Serial.println( "" );
  #endif
}

void toGreen(){
  //colora di verde il tutto
  analogWrite(RLED, 0);
  analogWrite(GLED, 255);
  analogWrite(BLED, 0);
  
  iColor = IGREEN;
  
  #if DEBUG>1
    Serial.print( "Coloro di verde!" );
    Serial.println( "" );
  #endif
}

void toBlue(){
  //colora di blu il tutto
  analogWrite(RLED, 0);
  analogWrite(GLED, 0);
  analogWrite(BLED, 255);
  
  iColor = IBLUE;
  
  #if DEBUG>1
    Serial.print( "Coloro di blu!" );
    Serial.println( "" );
  #endif
}

void toYellow(){
  //colora di giallo il tutto
  analogWrite(RLED, 255);
  analogWrite(GLED, 255);
  analogWrite(BLED, 0);
  
  iColor = IYELLOW;
  
  #if DEBUG>1
    Serial.print( "Coloro di giallo!" );
    Serial.println( "" );
  #endif
}

void toMagenta(){
  //colora di magenta il tutto
  analogWrite(RLED, 255);
  analogWrite(GLED, 0);
  analogWrite(BLED, 255);
  
  iColor = IMAGENTA;
  
  #if DEBUG>1
    Serial.print( "Coloro di magenta!" );
    Serial.println( "" );
  #endif
}

void toCyan(){
  //colora di ciano il tutto
  analogWrite(RLED, 0);
  analogWrite(GLED, 255);
  analogWrite(BLED, 255);
  
  iColor = ICYAN;
  
  #if DEBUG>1
    Serial.print( "Coloro di ciano!" );
    Serial.println( "" );
  #endif
}

void toGray(){
  //colora di grigio il tutto
  analogWrite(RLED, 128);
  analogWrite(GLED, 128);
  analogWrite(BLED, 128);
  
  iColor = IGRAY;
  
  #if DEBUG>1
    Serial.print( "Coloro di grigio!" );
    Serial.println( "" );
  #endif
}

void toTeal(){
  //colora di foglia di te' il tutto
  analogWrite(RLED, 0);
  analogWrite(GLED, 128);
  analogWrite(BLED, 128);
  
  iColor = ITEAL;
  
  #if DEBUG>1
    Serial.print( "Coloro di foglia di te'(teal)!" );
    Serial.println( "" );
  #endif
}

void toOrange(){
  //colora di arancione il tutto
  analogWrite(RLED, 255);
  analogWrite(GLED, 127);
  analogWrite(BLED, 0);
  
  iColor = IORANGE;
  
  #if DEBUG>1
    Serial.print( "Coloro di arancione!" );
    Serial.println( "" );
  #endif
}

void toOlive(){
  //colora di marrone oliva il tutto
  analogWrite(RLED, 128);
  analogWrite(GLED, 128);
  analogWrite(BLED, 0);
  
  iColor = IOLIVE;
  
  #if DEBUG>1
    Serial.print( "Coloro di marrone oliva!" );
    Serial.println( "" );
  #endif
}

void toPurple(){
  //colora di porpora il tutto
  analogWrite(RLED, 128);
  analogWrite(GLED, 0);
  analogWrite(BLED, 128);
  
  iColor = IPURPLE;
  
  #if DEBUG>1
    Serial.print( "Coloro di porpora!" );
    Serial.println( "" );
  #endif
}

void buzzer() {
  //di default ciclo di 3 con delay di 10
  #if DEBUG>0
    Serial.println( "Segnalazione del cambio di stato tramite buzzer (default)" );
  #endif 
  i = 10;
  buzzer( &i, &i );
}

void buzzer( int *num, int *nDelay ){
  #if DEBUG>0
    Serial.print( "Segnalazione del cambio di stato tramite buzzer... num cicli: " );
    Serial.print( *num );
    Serial.print( ", delay: " );
    Serial.println( *nDelay );
  #endif 
  for( int i = 0; i < *num; i++){
    digitalWrite(BUZZ, HIGH);
    delay( *nDelay );
    digitalWrite(BUZZ, LOW);
    delay( *nDelay );
  }
}
