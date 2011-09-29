#include <MsTimer2.h>

//The number of Planes
#define PLANES 4

#define PLANESIZE PLANES*PLANES

//Pins for the shift register(s)
int latchPin = 12;
int clockPin = 8;
int dataPin = 11;

int state = 0;

//The pin addresses of the plane pins
int PlanePin[] = {2,3,4,5};

// Array to hold the current display, multi array of planes * 2 ints, 1 Low and 1 High 
//Each plane has 2 bits, lo and high, which are bitmasks for 8 leds each
int buffer[PLANES][2];

/** 
 *  Set up the pins and buffer to initial values
 */ 
void setup() {

  int pin; // loop counter
  int plane;

  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, OUTPUT);
  
  // set up plane pins as outputs (active LOW)
  for (plane=0; plane < PLANES; plane++) {
    pinMode( PlanePin[plane], OUTPUT );
    digitalWrite( PlanePin[plane], LOW );
  }
  
  randomSeed(analogRead(0));
  clearBuffer();
  
  //Set drawbuffer to run on an interrupt
  MsTimer2::set(2, drawBuffer); 
  MsTimer2::start();
}

/**
 * Draw the buffer to the cube
 * This is run on the interrupt in the background, refreshes the screen one plane at a time
 */
void drawBuffer()
{
  //Store the current plane
  static int plane = 0;
  
  //Turn the previous plane off
  digitalWrite(PlanePin[plane], HIGH);  
  
  //Clear the shift registers
  digitalWrite(latchPin, LOW);  
  shiftOut(dataPin, clockPin, LSBFIRST, 0);
  shiftOut(dataPin, clockPin, LSBFIRST, 0);
  //set latchPin to high to lock and send data
  digitalWrite(latchPin, HIGH);  
  
  
  //change to the next plane
  plane += 1;
  if (plane >= PLANES) {
    plane = 0;
  }
  
  //Set shiftout the data to light up the correct LEDs for this pane
  digitalWrite(PlanePin[plane], LOW);    
  digitalWrite(latchPin, LOW);  
  shiftOut(dataPin, clockPin, LSBFIRST, buffer[plane][0]);
  shiftOut(dataPin, clockPin, LSBFIRST, buffer[plane][1]);
  //set latchPin to high to lock and send data
  digitalWrite(latchPin, HIGH);  
}

/** 
 *  Main Loop
 * Display different patterns for a set time each
 * TODO: make this change pattern based on a button
 */ 
void loop()
{  
  
  state ++;
  if (state >= 0 && state < 200) {
    planeShift();
  }
  if (state >= 200 && state < 230) { 
    yRain(100);
  }
  if (state >= 230 && state < 280) { 
    spin(100);
  }
  if (state >= 280 && state < 500) { 
    randomDots(20);
  }
  if (state >= 500 && state < 510) { 
    cubeFill(500);
  }
  if (state >= 510) { 
    state = 0;
  }
  
}


/** 
 * Move between top and bottom planes randomly
 */
void planeShift()
{
  
  //Array to contain the position of 16 lit LEDs
  static int points[16][3] = {
    {1,4,1}, {2,4,1}, {3,4,1}, {4,4,1},
    {1,4,2}, {2,4,2}, {3,4,2}, {4,4,2},
    {1,4,3}, {2,4,3}, {3,4,3}, {4,4,3},
    {1,4,4}, {2,4,4}, {3,4,4}, {4,4,4}
  };
  int i;
  for (i=0; i<16; i++) {
    drawPoint(points[i][0], points[i][1], points[i][2]);
  }
 
  
  int j;
  int speed = random(10, 60);
  int point = random(0,15);
  
  if (points[point][1] == 4) {
    for (j = 4; j >= 1; j--) {
      points[point][1] = j;
      for (i=0; i<16; i++) {
        drawPoint(points[i][0], points[i][1], points[i][2]);
      }
      delay(speed);
      clearBuffer();
    }
  } else {
    for (j = 1; j <= 4; j++) {
      points[point][1] = j;
      for (i=0; i<16; i++) {
        drawPoint(points[i][0], points[i][1], points[i][2]);
      }
      delay(speed);
      clearBuffer();
    }
  }
  
}



/**
 * Vertical Rain 1 at a time
 */
void yRain(int wait)
{
   int x = random(1, PLANES + 1);
   int z = random(1, PLANES + 1);
   int speed = 1;
   int y = 0;
   
   for (y = PLANES; y > 0; y--) {
     clearPoint(x, y+1, z);
     drawPoint(x, y, z);
     delay(wait);
   }
   clearPoint(x, y, z);
   
}

/**
 * Draw and clear a random dot
 */
void randomDots(int wait)
{
   int x = random(1, PLANES + 1);
   int y = random(1, PLANES + 1);
   int z = random(1, PLANES + 1);
   drawPoint(x,y,z);
   delay(wait);
   clearPoint(x,y,z);
}

/**
 * Draw a cube 4x4 at a certain point
 */ 
void drawCube(int x, int y, int z)
{
  drawPoint(x,y,z);
  drawPoint(x-1,y,z);
  drawPoint(x-1,y-1,z);
  drawPoint(x-1,y,z-1);
  drawPoint(x,y-1,z);
  drawPoint(x,y-1,z-1);
  drawPoint(x,y,z-1);
  drawPoint(x-1,y-1,z-1); 
}

/**
 * Spinning vertical plane
 * TODO: do this with code rather than hardcoded points
 */
void spin(int wait)
{
  drawPoint(1,1,1);
  drawPoint(1,2,1);
  drawPoint(1,3,1);
  drawPoint(1,4,1);
  
  drawPoint(2,1,2);
  drawPoint(2,2,2);
  drawPoint(2,3,2);
  drawPoint(2,4,2);
  
  drawPoint(3,1,3);
  drawPoint(3,2,3);
  drawPoint(3,3,3);
  drawPoint(3,4,3);
  
  drawPoint(4,1,4);
  drawPoint(4,2,4);
  drawPoint(4,3,4);
  drawPoint(4,4,4);
  delay(wait);
  clearBuffer();

  
  drawPoint(1,1,2);
  drawPoint(1,2,2);
  drawPoint(1,3,2);
  drawPoint(1,4,2);
  
  drawPoint(2,1,2);
  drawPoint(2,2,2);
  drawPoint(2,3,2);
  drawPoint(2,4,2);
  
  drawPoint(3,1,3);
  drawPoint(3,2,3);
  drawPoint(3,3,3);
  drawPoint(3,4,3);
  
  drawPoint(4,1,3);
  drawPoint(4,2,3);
  drawPoint(4,3,3);
  drawPoint(4,4,3);
  delay(wait);
  clearBuffer();
  
  drawPoint(1,1,3);
  drawPoint(1,2,3);
  drawPoint(1,3,3);
  drawPoint(1,4,3);
  
  drawPoint(2,1,3);
  drawPoint(2,2,3);
  drawPoint(2,3,3);
  drawPoint(2,4,3);
  
  drawPoint(3,1,2);
  drawPoint(3,2,2);
  drawPoint(3,3,2);
  drawPoint(3,4,2);
  
  drawPoint(4,1,2);
  drawPoint(4,2,2);
  drawPoint(4,3,2);
  drawPoint(4,4,2);
  delay(wait);
  clearBuffer();
  
  drawPoint(1,1,4);
  drawPoint(1,2,4);
  drawPoint(1,3,4);
  drawPoint(1,4,4);
  
  drawPoint(2,1,3);
  drawPoint(2,2,3);
  drawPoint(2,3,3);
  drawPoint(2,4,3);
  
  drawPoint(3,1,2);
  drawPoint(3,2,2);
  drawPoint(3,3,2);
  drawPoint(3,4,2);
  
  drawPoint(4,1,1);
  drawPoint(4,2,1);
  drawPoint(4,3,1);
  drawPoint(4,4,1);
  delay(wait);
  clearBuffer();
  
  drawPoint(2,1,4);
  drawPoint(2,2,4);
  drawPoint(2,3,4);
  drawPoint(2,4,4);
  
  drawPoint(2,1,3);
  drawPoint(2,2,3);
  drawPoint(2,3,3);
  drawPoint(2,4,3);
  
  drawPoint(3,1,2);
  drawPoint(3,2,2);
  drawPoint(3,3,2);
  drawPoint(3,4,2);
  
  drawPoint(3,1,1);
  drawPoint(3,2,1);
  drawPoint(3,3,1);
  drawPoint(3,4,1);
  delay(wait);
  clearBuffer();
  
  drawPoint(3,1,4);
  drawPoint(3,2,4);
  drawPoint(3,3,4);
  drawPoint(3,4,4);
  
  drawPoint(3,1,3);
  drawPoint(3,2,3);
  drawPoint(3,3,3);
  drawPoint(3,4,3);
  
  drawPoint(2,1,2);
  drawPoint(2,2,2);
  drawPoint(2,3,2);
  drawPoint(2,4,2);
  
  drawPoint(2,1,1);
  drawPoint(2,2,1);
  drawPoint(2,3,1);
  drawPoint(2,4,1);
  delay(wait);
  clearBuffer();
}

/**
 * Flash the whole cube on and off
 */
void flashAll(int wait, int times = 1)
{
  int i;
  for (i = 0; i <= times; i++) {
    clearBuffer();
    delay(wait);
    fillBuffer();
    delay(wait);
  }
  clearBuffer();
}

/**
 * Fill the cube with smaller cubes, then flash
 */
void cubeFill(int wait)
{
  drawCube(4,4,4);
  delay(wait);
  drawCube(2,4,2);
  delay(wait);
  drawCube(2,2,4);
  delay(wait);
  drawCube(4,2,2);
  delay(wait);
  drawCube(2,4,4);
  delay(wait);
  drawCube(4,2,4);
  delay(wait);
  drawCube(2,2,2);
  delay(wait);
  drawCube(4,4,2);
  flashAll(50, 10);
  
}



/**
 * clear a 3d point in the buffer
 */
void clearPoint(int x, int y, int z)
{
  x = constrain(x, 1, 4);
  y = constrain(y, 1, 4);
  z = constrain(z, 1, 4);
  byte plane = y - 1;
  byte pin = PLANES*z - (PLANES-x) - 1;
  byte type = 0;
  if (pin < 8) {

    buffer[plane][0] =  buffer[plane][0] ^ (byte)bit(pin);
  } else {
    buffer[plane][1] = buffer[plane][1] ^ (byte)bit(pin-8);
  }
}

/**
 * Draw a 3d point in the buffer by translating an x,y,z point into a value and adding it to the correct plane bit
 */
void drawPoint(byte x, byte y, byte z)
{
  x = constrain(x, 1, 4);
  y = constrain(y, 1, 4);
  z = constrain(z, 1, 4);
  byte plane = y - 1;
  byte pin = PLANES*z - (PLANES-x) - 1;
  byte type = 0;
  if (pin < 8) {

    buffer[plane][0] =  buffer[plane][0] | (byte)bit(pin);
  } else {
    buffer[plane][1] = buffer[plane][1] | (byte)bit(pin-8);
  }
}



/**
 *  Clear a cube by setting all the planes to HIGH and all the columns to LOW
 */
void clear()
{
  int pin;
  for (pin=0; pin < PLANES; pin++) {
    digitalWrite(PlanePin[pin], HIGH);
  }
}

/**
 *  Clear the buffer by setting all values to 0
 */
void clearBuffer()
{
  int pin;
  int plane;
  for (plane=0; plane < PLANES; plane++) {
    buffer[plane][0] = 0;
    buffer[plane][1] = 0;  
  }
}

/**
 *  Clear the buffer by setting all values to 0
 */
void fillBuffer()
{
  int pin;
  int plane;
  for (plane=0; plane < PLANES; plane++) {    
    buffer[plane][0] = 255;
    buffer[plane][1] = 255;    
  }
}


