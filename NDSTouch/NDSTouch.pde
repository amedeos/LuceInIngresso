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

#define DEBUG 2
#define DEBOUNCINGDELAY 20
#define DELAY 100

#if DEBUG>0
  #undef DELAY
  #define DELAY 3000
#endif

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

char adjustArea(int *x, int *y){
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
