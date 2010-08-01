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

//check if touched (on|off)
int getTouch();
int getX();
int getY();

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
