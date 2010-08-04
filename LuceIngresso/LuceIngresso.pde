/* 
 * Autore: Amedeo Salvati
 * e-mail: amedeo.salvati@gmail.com
 *
 * Data: 27/12/2009
 * Update: 04/08/2010
 *
 * Semplice programma utilizzato per accendere la luce dell'ingresso
 * all'apertura della porta e con luminosita' ridotta
 *
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
//#define BUTTON 12
#define BUZZ 9
#define SENSORIR 5 //sensore IR sulla porta
#define DELAY 100 //delay immesso alla fine del ciclo loop
#define DEBOUNCING 30 //delay immesso per il de-bouncing del bottone
#define SECRESET 6 //ogni quanti secondi memorizzare la luminosita'
#define SECBUTTON 2000 //ogni quanti millisecondi premendo il bottone si cambiera' colore

//variabile che definisce la luminosita' minima
#define MINLUM 50

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
void randomColor();
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

/* ============== Nintendo DS Touch Screen var/func ============== */
#define X1 15 //analog 1
#define Y2 16 //analog 2
#define X2 17 //analog 3
#define Y1 18 //analog 4
//var used to switch between on +5v and off 0v
#define TOUCHMARK 400

//watermark var
//A
#define AXMIN 0
#define AXMAX 480
#define AXAV 417
#define AYMIN 260
#define AYMAX 360
#define AYAV 300
//D
#define DXMIN 470
#define DXMAX 550
#define DXAV 521
#define DYMIN 200
#define DYMAX 270
#define DYAV 245
//B
#define BXMIN 470
#define BXMAX 600
#define BXAV 534
#define BYMIN 410
#define BYMAX 520
#define BYAV 464
//E
#define EXMIN 540
#define EXMAX 650
#define EXAV 606
#define EYMIN 370
#define EYMAX 415
#define EYAV 394
//C
#define CXMIN 650
#define CXMAX 800
#define CXAV 723
#define CYMIN 500
#define CYMAX 600
#define CYAV 573
//F
#define FXMIN 710
#define FXMAX 1023
#define FXAV 766
#define FYMIN 450
#define FYMAX 500
#define FYAV 479

int getTouch(); //check if touched (on|off)
int getX();
int getY();
char getArea(int *x, int *y);
char adjustArea(int *x, int *y);

char area = '0';
int x, y = 0;
int iTmp = 0;
/* ============== Nintendo DS Touch Screen var/func ============== */

//versione dell'applicativo
char cVersion[ ] = "0.0.7";

//funzioni utilizzate per segnalare acusticamente un cambiamento
void buzzer();
void buzzer( int *num, int *nDelay );
void notifyChangeColor( int *color1, int *color2 );

//funzione utilizzata per variare il colore
void changeColor( int *red, int *green, int *blue );

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

int iRed = 0;
int iGreen = 0;
int iBlue = 0;

void setup() {
  Serial.begin(9600);  // open the serial port
  pinMode( BUZZ, OUTPUT );
  pinMode( GLED, OUTPUT );
  pinMode( RLED, OUTPUT );
  pinMode( BLED, OUTPUT );
  
  Serial.print( "Application Version: " );
  Serial.println( cVersion );
  Serial.print( "Source File: " );
  Serial.println( __FILE__ );
  Serial.print( "Build date: " );
  Serial.print( __DATE__ );
  Serial.print( " " );
  Serial.println( __TIME__ );
  
  randomSeed( analogRead( 1 ) );  //inizializzo il seme dei num casuali con la lettura da un pin non utilizzato
}

void loop() {
  iVal = analogRead(SENSORLUM);

  time = millis();

  //conversione in secondi
  time = time / 1000;

  //iBut = digitalRead( BUTTON );
  iBut = getTouch();
  
  #if DEBUG>0
    Serial.print( "Tempo: " );
    Serial.print( time );
    Serial.print( " Bottone: " );
    Serial.print( iBut );
  #endif

  if( ( iBut == HIGH ) && ( iBut1 == LOW ) ) {
    state = 1 - state;
    
    x = getX();
    y = getY();

    lButStartTime = millis();

    //piccolo delay immesso per il de-bouncing
    delay(DEBOUNCING);

    if( state == 1 ){
      area = getArea( &x, &y );
      if( area == 'A' ){
        toRed();
      }
      else if( area == 'B' ){
        toWhite();
      }
      else if( area == 'C' ){
        toBlue();
      }
      else if( area == 'D' ){
        toYellow();
      }
      else if( area == 'E' ){
        toMagenta();
      }
      else{
        toGreen();
      }
      notifyChangeColor( &iColor, &iColor1 );
    }
  }//end if ( iBut == HIGH ) && ( iBut1 == LOW )

  #if DEBUG>0
    Serial.print( " Stato: " );
    Serial.println( state );
  #endif

  if( ( iBut == HIGH ) && ( iBut1 == HIGH ) ) {

    if( state == 1){
      //da immettere il codice di cambio colore
      if( millis() - lButStartTime > SECBUTTON*2 ) {
        #if DEBUG>0
          Serial.print( "Bottone premuto piu' di " );
          Serial.print( SECBUTTON*2 );
          Serial.println( "ms" );
        #endif
        if( area == 'A' ){
          toCyan();
        }
        else if( area == 'B' ){
          toGray();
        }
        else if( area == 'C' ){
          toTeal();
        }
        else if( area == 'D' ){
          toOrange();
        }
        else if( area == 'E' ){
          toOlive();
        }
        else{
          toPurple();
        }
      }
      notifyChangeColor( &iColor, &iColor1 );
    } //end if state == 1
  } //end if ( iBut == HIGH ) && ( iBut1 == HIGH )

  iBut1 = iBut;

  //adesso bisogna verificare se accendere automatimante i led
  //se viene aperta la porta e la luminosita' e' bassa
  if( state == 0 ) {
    toBlack();
    notifyChangeColor( &iColor, &iColor1 );

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
        randomColor();
        
        notifyChangeColor( &iColor, &iColor1 );
        
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
          
          //iButTmp = digitalRead( BUTTON );
          iButTmp = getTouch();
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

void randomColor(){
  //
  i = random( 12 );
  switch (i) {
    case 0:
      toWhite();
      #if DEBUG>1
        Serial.println( "Bianco!" );
      #endif
      break;
    case 1:
      toRed();
      #if DEBUG>1
        Serial.println( "Rosso!" );
      #endif
      break;
    case 2:
      toGreen();
      #if DEBUG>1
        Serial.println( "Verde!" );
      #endif
      break;
    case 3:
      toBlue();
      #if DEBUG>1
        Serial.println( "Blu!" );
      #endif
      break;
    case 4:
      toYellow();
      #if DEBUG>1
        Serial.println( "Giallo!" );
      #endif
      break;
    case 5:
      toMagenta();
      #if DEBUG>1
        Serial.println( "Magenta!" );
      #endif
      break;
    case 6:
      toCyan();
      #if DEBUG>1
        Serial.println( "Ciano!" );
      #endif
      break;
    case 7:
      toGray();
      #if DEBUG>1
        Serial.println( "Grigio!" );
      #endif
      break;
    case 8:
      toTeal();
      #if DEBUG>1
        Serial.println( "Teal!" );
      #endif
      break;
    case 9:
      toOrange();
      #if DEBUG>1
        Serial.println( "Arancione!" );
      #endif
      break;
    case 10:
      toOlive();
      #if DEBUG>1
        Serial.println( "Oliva!" );
      #endif
      break;
    case 11:
      toPurple();
      #if DEBUG>1
        Serial.println( "Porpora!" );
      #endif
      break;
  }//end switch
}//end randomColor

void toWhite(){
  //accende tutti i led -> bianco
  iRed = 255;
  iGreen = 255;
  iBlue = 255; 
  
  changeColor( &iRed, &iGreen, &iBlue );
  
  iColor = IWHITE;
  
  #if DEBUG>1
    Serial.print( "Accendo tutti i led -> bianco!" );
    Serial.println( "" );
  #endif
}//end toWhite

void toBlack(){
  //spegne tutti i led -> nero
  iRed = 0;
  iGreen = 0;
  iBlue = 0;
  
  changeColor( &iRed, &iGreen, &iBlue );
  
  iColor = IBLACK;
  
  #if DEBUG>1
    Serial.print( "Spengo tutti i led -> nero" );
    Serial.println( "" );
  #endif
}//end toBlack

void toRed(){
  //colora di rosso il tutto
  iRed = 255;
  iGreen = 0;
  iBlue = 0;
  
  changeColor( &iRed, &iGreen, &iBlue );
  
  iColor = IRED;
  
  #if DEBUG>1
    Serial.print( "Coloro di rosso!" );
    Serial.println( "" );
  #endif
}//end toRed

void toGreen(){
  //colora di verde il tutto
  iRed = 0;
  iGreen = 255;
  iBlue = 0;
  
  changeColor( &iRed, &iGreen, &iBlue );
  
  iColor = IGREEN;
  
  #if DEBUG>1
    Serial.print( "Coloro di verde!" );
    Serial.println( "" );
  #endif
}//end toGreen

void toBlue(){
  //colora di blu il tutto
  iRed = 0;
  iGreen = 0;
  iBlue = 255;
  
  changeColor( &iRed, &iGreen, &iBlue );

  iColor = IBLUE;
  
  #if DEBUG>1
    Serial.print( "Coloro di blu!" );
    Serial.println( "" );
  #endif
}//end toBlue

void toYellow(){
  //colora di giallo il tutto
  iRed = 255;
  iGreen = 255;
  iBlue = 0;
  
  changeColor( &iRed, &iGreen, &iBlue );
  
  iColor = IYELLOW;
  
  #if DEBUG>1
    Serial.print( "Coloro di giallo!" );
    Serial.println( "" );
  #endif
}//end toYellow

void toMagenta(){
  //colora di magenta il tutto
  iRed = 255;
  iGreen = 0;
  iBlue = 255;
  
  changeColor( &iRed, &iGreen, &iBlue );
  
  iColor = IMAGENTA;
  
  #if DEBUG>1
    Serial.print( "Coloro di magenta!" );
    Serial.println( "" );
  #endif
}//end toMagenta

void toCyan(){
  //colora di ciano il tutto
  iRed = 0;
  iGreen = 255;
  iBlue = 255;
  
  changeColor( &iRed, &iGreen, &iBlue );
  
  iColor = ICYAN;
  
  #if DEBUG>1
    Serial.print( "Coloro di ciano!" );
    Serial.println( "" );
  #endif
}//end toCyan

void toGray(){
  //colora di grigio il tutto
  iRed = 128;
  iGreen = 128;
  iBlue = 128;
  
  changeColor( &iRed, &iGreen, &iBlue );
  
  iColor = IGRAY;
  
  #if DEBUG>1
    Serial.print( "Coloro di grigio!" );
    Serial.println( "" );
  #endif
}//end toGray

void toTeal(){
  //colora di foglia di te' il tutto
  iRed = 0;
  iGreen = 128;
  iBlue = 128;
  
  changeColor( &iRed, &iGreen, &iBlue );
  
  iColor = ITEAL;
  
  #if DEBUG>1
    Serial.print( "Coloro di foglia di te'(teal)!" );
    Serial.println( "" );
  #endif
}//end toTeal

void toOrange(){
  //colora di arancione il tutto
  iRed = 255;
  iGreen = 127;
  iBlue = 0;
  
  changeColor( &iRed, &iGreen, &iBlue );
  
  iColor = IORANGE;
  
  #if DEBUG>1
    Serial.print( "Coloro di arancione!" );
    Serial.println( "" );
  #endif
}//end toOrange

void toOlive(){
  //colora di marrone oliva il tutto
  iRed = 128;
  iGreen = 128;
  iBlue = 0;
  
  changeColor( &iRed, &iGreen, &iBlue );
  
  iColor = IOLIVE;
  
  #if DEBUG>1
    Serial.print( "Coloro di marrone oliva!" );
    Serial.println( "" );
  #endif
}//end toOlive

void toPurple(){
  //colora di porpora il tutto
  iRed = 128;
  iGreen = 0;
  iBlue = 128;
  
  changeColor( &iRed, &iGreen, &iBlue );
  
  iColor = IPURPLE;
  
  #if DEBUG>1
    Serial.print( "Coloro di porpora!" );
    Serial.println( "" );
  #endif
}//end toPurple

void changeColor( int *red, int *green, int *blue ){
  analogWrite(RLED, *red);
  analogWrite(GLED, *green);
  analogWrite(BLED, *blue);
}//end changeColor

void buzzer() {
  //di default ciclo di 10 con delay di 10
  #if DEBUG>1
    Serial.println( "Segnalazione del cambio di stato tramite buzzer (default)" );
  #endif 
  i = 10;
  buzzer( &i, &i );
}//end buzzer

void buzzer( int *num, int *nDelay ){
  #if DEBUG>1
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
}//end buzzer

void notifyChangeColor( int *color1, int *color2 ){
  if( *color1 != *color2 ){
    buzzer();
    *color2 = *color1;
  }
}//notifyChangeColor

int getTouch(){
    /* Check if it's touched
   *
   * Y1 -> +5v
   * Y2 -> GND
   * X1 = X2 = 0v NOTouch = false
   * X1 = X2 = 5v   Touch = true
   */
  pinMode( Y1, OUTPUT );
  pinMode( Y2, OUTPUT );
  pinMode( X1, INPUT );
  pinMode( X2, INPUT );
  
  digitalWrite( Y1, HIGH );
  digitalWrite( Y2, LOW );
  
  //little delay for de-buoncing
  delay( DEBOUNCING );
  
  iTmp = analogRead( X1 - 14 );
  #if DEBUG > 1
    Serial.print( "getTouch: Read value: " );
    Serial.print( iTmp );
    Serial.println( "" );
  #endif
  if( iTmp >= TOUCHMARK){
    return 1;
  }
  
  return 0;
}

int getX(){
   /* Check X value
    * 
    * Y1 -> GND                                | | | |
    * X1 -> +5v                   ----------------------
    * X2 = X                      | °--------------->° |
    * Y2 -> unconnected           |5v              2.5v|
    * 2.5v <= X <= 5v             |                    |
    *                             ----------------------
    */
  pinMode( Y1, OUTPUT );
  pinMode( X1, OUTPUT );
  pinMode( X2, INPUT );
  pinMode( Y2, INPUT );
  
  digitalWrite( Y1, LOW );
  digitalWrite( X1, HIGH );
  
  //little delay for de-bouncing
  delay( DEBOUNCING );
  
  iTmp = analogRead( X2 - 14 );
  #if DEBUG > 1
    Serial.print( "getX: Read value: " );
    Serial.print( iTmp );
    Serial.println( "" );
  #endif
  
  return iTmp;
}

int getY(){
    /* Check Y value
   *                                           | | | |
   * Y1 -> +5v                    ----------------------
   * X2 -> GND                    |2        1.7     0.4|
   * X1 = Y                       |2.6      2.1     0.5|
   * Y2 -> unconnected            |3        2.5    0.85|
   *                              ----------------------
   */
  pinMode( Y1, OUTPUT );
  pinMode( X2, OUTPUT );
  pinMode( X1, INPUT );
  pinMode( Y2, INPUT );
  
  digitalWrite( Y1, HIGH );
  digitalWrite( X2, LOW );
  
  //little delay for de-bouncing
  delay( DEBOUNCING );
  
  iTmp = analogRead( X1 - 14 );
  #if DEBUG > 1
    Serial.print( "getY: Read value: " );
    Serial.print( iTmp );
    Serial.println( "" );
  #endif
  
  return iTmp;
}

char getArea( int *x, int *y ){
  /* Return A, B, C, D, E, F based on:
   *
   * -------------------
   * |  A  |  B  |  C  |
   * |-----|-----|-----|
   * |  D  |  E  |  F  |
   * -------------------
   *
   * Z if there are an error
   */
  //default area = Z
  char area = 'Z';
  
  if ( *x >= AXMIN && *x <= AXMAX && *y >= AYMIN && *y <= AYMAX ){
    area = 'A';
  } //end A
  else if ( *x >= DXMIN && *x <= DXMAX && *y >= DYMIN && *y <= DYMAX ){
    area = 'D';
  } //end D
  else if ( *x >= BXMIN && *x <= BXMAX && *y >= BYMIN && *y <= BYMAX ){
    area = 'B';
  } //end B
  else if ( *x >= EXMIN && *x <= EXMAX && *y >= EYMIN && *y <= EYMAX ){
    area = 'E';
  } //end E
  else if ( *x >= CXMIN && *x <= CXMAX && *y >= CYMIN && *y <= CYMAX ){
    area = 'C';
  } //end C
  else if ( *x >= FXMIN && *x <= FXMAX && *y >= FYMIN && *y <= FYMAX ){
    area = 'F';
  } //end F
  else {
    //error on area decode
    area = 'Z';
  }
  if ( area == 'Z' ){
    area = adjustArea( &*x, &*y );
  }
  
  #if DEBUG > 1
    Serial.print( "getArea: return area '" );
    Serial.print( area );
    Serial.print( "'" );
    Serial.println( "" );
  #endif
  
  return area;
}

char adjustArea( int *x, int *y ){
  char area = 'Z';
  int a, b, c, d, e, f, imin = 0;
  
  a = abs( *x - AXAV );
  a = a + abs( *y - AYAV );
  b = abs( *x - BXAV );
  b = b + abs( *y - BYAV );
  c = abs( *x - CXAV );
  c = c + abs( *y - CYAV );
  d = abs( *x - DXAV );
  d = d + abs( *y - DYAV );
  e = abs( *x - EXAV );
  e = e + abs( *y - EYAV );
  f = abs( *x - FXAV );
  f = f + abs( *y - FYAV );
  
  if ( a <= b ){
    area = 'A';
    imin = a;
  }
  else {
    area = 'B';
    imin = b;
  }
  if ( c <= imin ){
    area = 'C';
    imin = c;
  }
  if ( d <= imin ){
    area = 'D';
    imin = d;
  }
  if ( e <= imin ){
    area = 'E';
    imin = e;
  }
  if ( f <= imin ){
    area = 'F';
    imin = f;
  }
  
  #if DEBUG > 1
    Serial.print( "adjustArea: return area " );
    Serial.print( area );
    Serial.println( "" );
  #endif
  
  return area;
}
