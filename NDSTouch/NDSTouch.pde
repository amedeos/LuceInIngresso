/* Author: Amedeo Salvati
 * e-mail: amedeo.salvati@gmail.com
 * 
 * Simple program for get X and Y value from Nintendo
 * DS TouchScreen using Sparkfun connector
 *
 */

#define X1 15 //analog 1
#define Y2 16 //analog 2
#define X2 17 //analog 3
#define Y1 18 //analog 4

#define DEBUG 1
#define DEBOUNCINGDELAY 20
#define DELAY 100

#if DEBUG>0
  #undef DELAY
  #define DELAY 3000
#endif

//var used to switch between on +5v and off 0v
#define TOUCHMARK 400

//watermark var
#define AXMIN 0
#define AXMAX 540
#define AYMIN 270
#define AYMAX 350
#define DXMIN AXMIN
#define DXMAX AXMAX
#define DYMIN 200
#define DYMAX 270
#define BXMIN 540
#define BXMAX 640
#define BYMIN 410
#define BYMAX 520
#define EXMIN BXMIN
#define EXMAX BXMAX
#define EYMIN 370
#define EYMAX 410
#define CXMIN 640
#define CXMAX 1023
#define CYMIN 500
#define CYMAX 600
#define FXMIN CXMIN
#define FXMAX CXMAX
#define FYMIN 460
#define FYMAX 500

//check if touched (on|off)
int getTouch();
int getX();
int getY();
char getArea(int *x, int *y);

int x, y = 0;
int iTouch = 0;

int iTmp = 0;

unsigned long time = 0;

void setup(){
  Serial.begin(9600);
}

void loop(){
  
  time = millis();
  if ( time != 0 ) {
    time = time / 1000;
  }
  
  x = getX();
  #if DEBUG > 0
    Serial.print( time );
    Serial.print( " Read: x = " );
    Serial.print( x );
    Serial.println( "" );
  #endif
  
  
  y = getY();
  #if DEBUG > 0
    Serial.print( time );
    Serial.print( " Read: y = " );
    Serial.print( y );
    Serial.println( "" );
  #endif
  
  
  iTouch = getTouch();
  #if DEBUG > 0
    Serial.print( time );
    Serial.print( " iTouch: " );
    Serial.print( iTouch );
    Serial.println( "" );
  #endif
  
  char cArea = '0';
  
  if ( iTouch ){
    cArea = getArea( &x, &y );
    #if DEBUG > 0
      Serial.print( time );
      Serial.print( " cArea: " );
      Serial.print( cArea );
      Serial.println( "" );
    #endif
    if ( cArea == 'Z' ){
      //immettere un buzzer
      #if DEBUG > 0
        Serial.print( "Mancata individuazione dell'area!" );
        Serial.println( "" );
      #endif
    }
  }
  
  delay( DELAY );
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
  delay( DEBOUNCINGDELAY );
  
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
  delay( DEBOUNCINGDELAY );
  
  iTmp = analogRead( X1 - 14 );
  #if DEBUG > 1
    Serial.print( "getY: Read value: " );
    Serial.print( iTmp );
    Serial.println( "" );
  #endif
  
  return iTmp;
}

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
  delay( DEBOUNCINGDELAY );
  
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

char getArea(int *x, int *y){
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
  
  if ( *x >= AXMIN && *x <= AXMAX ){
    //area A|D
    if ( *y >= AYMIN && *y <= AYMAX ){
      area = 'A';
    } else if ( *y >= DYMIN && *y <= DYMAX ){
      area = 'D';
    } else {
      //on this case (error mapping) set to A
      //area = 'Z';
      area = 'A';
    }
  } //end area A|D
  else if ( *x >= BXMIN && *x <= BXMAX ){
    //area B|E
    if ( *y >= BYMIN && *y <= BYMAX ){
      area = 'B';
    } else if ( *y >= EYMIN && *y <= EYMAX ){
      area = 'E';
    } else {
      //on this case (error mapping) set to B
      //area = 'W';
      area = 'B';
    }
  } //end area B|E
  else if ( *x >= CXMIN && *x <= CXMAX ){
    //area C|F
    if ( *y >= CYMIN && *y <= CYMAX ){
      area = 'C';
    } else if ( *y >= FYMIN && *y <= FYMAX ){
      area = 'F';
    } else {
      //on this case (error mapping) set to C
      //area = 'J';
      area = 'C';
    }
  } //end area C|F
  else {
    //on this case (error mapping) set to A
    //area = 'K';
    area = 'A';
  }
  
  #if DEBUG > 1
    Serial.print( "getArea: return area '" );
    Serial.print( area );
    Serial.print( "'" );
    Serial.println( "" );
  #endif
  
  return area;
}
