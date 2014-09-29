/**
 * Flower Maker
 * Version 2.0
 * by Ray Elder
 *
 * 17 May 2010
 * 
 * Function to draw multiple flowers without using translate().
 */

class PlutchikWheel {

  Boolean verbose = false;       // set verbose to false to remove points and control points
  int totalPetals;
  float centerX, centerY;
  int petalLength;
  //int fullCircleDiam, fullCircleRadius;
  int maxSize;
  //variables for angles used
  float oneAngle,halfAngle,oneEigthAngleRadians;
  int [] emotionColours = new int[] { 
    #ffff00,#3bff18,#337700,#007cf7,#0014c5,#9400b5,#cc2222,#ff5a18
  };
  int [] emotionAlphas;
  //int [] newEmotionAlphas;
 // int time = 0; 

  PlutchikWheel(float originX, float originY, int radius, int numEmotions) {

    centerX = originX;
    centerY = originY;
    petalLength = radius-150;
    totalPetals = numEmotions;
 
    init();
    
  }

  void init() {

    oneAngle = 360/totalPetals;
    oneEigthAngleRadians=TWO_PI/totalPetals;
    //fullCircleDiam=600;
    //fullCircleRadius=fullCircleDiam/2;
    emotionAlphas = new int[totalPetals];
    //newEmotionAlphas = new int[totalPetals];
    for (int i = 0; i < totalPetals; i++) {
      emotionAlphas[i] = 75;
    }
  }

  void drawFlower() {

    float pX = 0.0;
    float pY = 0.0;
    //int diameter = radius * 2;

    // reset starting angle middle between first category
    float angle = 22.5;

    // draw petals around the center ellipse of the flower
    for (int i = 0; i < totalPetals; i++) {
//println(totalPetals + " + " + i);
      // calculate starting point
      pX = centerX; // + cos(radians(angle)) * radius;
      pY = centerY; // + sin(radians(angle)) * radius;

      // call drawPetal function to calculate control points and set bezierVertices
      drawPetal(pX, pY, angle, i);

      // increment angle based on total number of petals
      angle += (360 / totalPetals);
    }
  }

  void drawPetal(float startX, float startY, float angle, int index) {

    // set offset for control points
    float bezierDiff = petalLength / 2;

    // set angle for start's control points
    float startAngleTop =  angle - 21.5;
    float startAngleBottom = angle + 21.5;

    // set angle for end's control points
    float endAngleTop = angle - (oneAngle*3);
    float endAngleBottom = angle + (oneAngle*3);

    // calculate start's top control point
    float startAngleTopX = startX + cos(radians(startAngleTop))*bezierDiff;
    float startAngleTopY = startY + sin(radians(startAngleTop))*bezierDiff;

    // calculate start's bottom control point
    float startAngleBottomX = startX + cos(radians(startAngleBottom))*bezierDiff;
    float startAngleBottomY = startY + sin(radians(startAngleBottom))*bezierDiff;

    // calculate end point
    float endX = startX + cos(radians(angle))*petalLength;
    float endY = startY + sin(radians(angle))*petalLength;

    // calculate end's top control point
    float endAngleTopX = endX + cos(radians(endAngleTop))*bezierDiff;
    float endAngleTopY = endY + sin(radians(endAngleTop))*bezierDiff;

    // calculate end's bottom control point
    float endAngleBottomX = endX + cos(radians(endAngleBottom))*bezierDiff;
    float endAngleBottomY = endY + sin(radians(endAngleBottom))*bezierDiff;
   
    /*int period = 2000;
    
    time = millis();
    float value = 128+127*cos(TWO_PI/period*time);
    println("********start cos wave******");
    println(value);
    println("*********** end cos wave********************");*/
    
    fill(255, emotionAlphas[index]);
    stroke(emotionColours[index]);
    strokeWeight(3);

    // draw petal shape with points and control points
    beginShape();
    vertex(startX, startY);
    bezierVertex(startAngleTopX, startAngleTopY, endAngleTopX, endAngleTopY, endX, endY);
    bezierVertex(endAngleBottomX, endAngleBottomY, startAngleBottomX, startAngleBottomY, startX, startY);
    endShape();
    stroke(255,0,0);
    //ellipse(startAngleTopX, startAngleTopY, petalLength, petalLength);
  }

  int getEmoColour (int index) {

    return emotionColours[index];
  }

  void setNewEmoAlphas(int [] alphaVal) {
    
   emotionAlphas = alphaVal;
    
  }
}
