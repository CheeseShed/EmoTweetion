class TweetObject {

  String myTweetText = "";
  int myEmotionCategoryIndex, myStrengthIndex;
  int [] emotionColours;
  float theta ;
  float xPos, yPos, homeX, homeY;
  float mySpeed = 1.2;
  int limitIntenseRadius = 100;
  int limitBasicRadius = 225;
  int limitOuterRadius = 300;
  boolean alive, mouseOver,touched, kill, amITheUserObject;
  int birthTime;
  float oneEigthAngleRadians=TWO_PI/8;
  float anglePath, myAlpha, fadeRate, timerAlpha;
  float dx, dy = 0;
  //int edgeWidth, edgeHeight;
  PApplet myParent;
  int maxIncreasedBlobSize, currentBlobSize, blobSize, blowUpTxtSize;
  float changingFill, changingAlpha, startAlpha;
  String name = "";
  // PlutchikWheel userObject;

  TweetObject(PApplet pa, String tweetText, int emotionCategoryIndex, int strengthIndex, float x, float y, String screenName) {

    myTweetText = tweetText;
    myEmotionCategoryIndex = emotionCategoryIndex;
    myStrengthIndex = strengthIndex;
    myParent = pa;
    xPos = homeX = x;
    yPos = homeY = y;
    name = screenName;
    amITheUserObject = false;
    init();
  }

  TweetObject(PApplet pa, float x, float y) { //constructor for creating User-inputted tweet

    myParent = pa;
    myEmotionCategoryIndex = -1;
    myStrengthIndex = -1;
    name = "ME";
    xPos = homeX = x;
    yPos = homeY = y;
    amITheUserObject = true;
    //PFont font=loadFont("CharcoalCY-24.vlw");
    //textFont(font,24);
    init();
  }

  void init() {

    emotionColours = new int[] {
      #ffff00,#3bff18,#337700,#007cf7,#0014c5,#9400b5,#cc2222,#ff5a18
    };
    alive = true;
    kill = false;
    birthTime = millis();
    mouseOver = false;
    timerAlpha = 0;

    anglePath = random((oneEigthAngleRadians*myEmotionCategoryIndex),(oneEigthAngleRadians+(oneEigthAngleRadians*myEmotionCategoryIndex)));

    if(myStrengthIndex==0) {
      blobSize = currentBlobSize = 30;
      mySpeed *= 4.5;
      myAlpha = 220;
      fadeRate = 4.0;
    }
    else if(myStrengthIndex==1) { 
      blobSize = currentBlobSize = 20;
      mySpeed *= 3.0;
      myAlpha = 190;
      fadeRate = 1.5;
    }
    else if(myStrengthIndex==2) {
      blobSize = currentBlobSize = 10;
      mySpeed *= 1.2;
      myAlpha = 150;
      fadeRate = 0.4;
    }
    else { //blob is user-generated

      blobSize = currentBlobSize = 70;
      mySpeed *= 0.7;
      myAlpha = startAlpha = 230;
      fadeRate = 0;
      //userObject = new PlutchikWheel(xPos, yPos, currentUserBlobWidth, 8);
    }

    if(!amIYou()) {
      dx = cos(anglePath);
      dy = sin(anglePath);
      maxIncreasedBlobSize = 50;
      theta = 0;
    }
    else {

      dx = 5*cos(theta);
      dy = 5*sin(theta);

      //some sort of circular motion around an x,y position if it's the user object
    }
  }

  void updateTweet() {

    if(!mouseOver) { //if mouse isn't over blob

      drawTweet();
      amIAlive(); //...check if tweet object is less than 10 secs old
      updatePos(); //update it's position
      //userObject.drawFlower();
    } 
    else { //if mouseOver is on me

        if(!amIYou()) { //if not the user tweet object

        breathingBlob(); //create a "breathing" animation
        displayName();
      } 
      else {
     
    //println("my emotion category index (update) = " + myEmotionCategoryIndex);
        drawTweet();
      }
    }

    if(amIYou()) {
    
      theta += PI/32;
    }
  }

  void drawTweet() {

    if(!amIYou()) { //normal blobs
      if(touched) {
        stroke(255);
        strokeWeight(2);
      }
      else {
        noStroke();
      }

      if(currentBlobSize >= blobSize) {
        currentBlobSize --;
      }

      fill(emotionColours[myEmotionCategoryIndex], myAlpha); //out of bounds
      ellipse(xPos, yPos, currentBlobSize, currentBlobSize);
    }
    else { //references user tweet object blob
    //println(mouseOver);
         
   // println("my emotion category index (draw)= " + myEmotionCategoryIndex);
      if(!kill) {
        //println("not kill*****");
        if(myEmotionCategoryIndex == -1) {
          fill(255,135,180, myAlpha);
        }
        else {
          fill(emotionColours[myEmotionCategoryIndex], myAlpha);
        }

        stroke(50);
        strokeWeight(0.5);
        ellipse(xPos, yPos, currentBlobSize, currentBlobSize);

        if(mouseOver) {
          changingFill = 50;
        }
        else {
          fill(changingFill, 150); //changingAlpha
        }
        noStroke();
        ellipse(xPos, yPos,currentBlobSize-20, currentBlobSize-20);
        fill(255);
        textAlign(CENTER);
        textSize(20);
        text(name,xPos,yPos-currentBlobSize/2);
        //println("*****name in text in draw is " + name);
        //popMatrix();
      }
      else { //animation for blowing up tweet when dead

        blowUp();
      }
    }
  }

  void displayName() {

    textAlign(LEFT);
    textSize(18);
    pushMatrix();
    translate(xPos, yPos);
    rotate(anglePath);
    fill(emotionColours[myEmotionCategoryIndex]);
    text(name, currentBlobSize/2 + 2, 12);
    translate(-currentBlobSize/2 +2, -currentBlobSize/2 +2);
    popMatrix();
    
  }

  void updatePos() {

    if(!amIYou()) {

      xPos += mySpeed*dx;
      yPos += mySpeed*dy;  //move blob
    }
    else {

      changingFill = 128 + 127*cos(theta);
      if(myEmotionCategoryIndex != -1){
        checkPositionIsInCategory();
      }
    }

    myAlpha -= fadeRate;

    if(!alive || myAlpha < 0) {
      myAlpha = 0;
    }
  }
  
  void checkPositionIsInCategory(){
  
      float distX = xPos - wheelCentreX;
      float distY = yPos - wheelCentreY;
      float a = atan2(distY, distX);
      if(a < 0) {
        a += TWO_PI;
      }
      float eachAngle = (TWO_PI/numEmotions);

      for(int i = 0; i<numEmotions; i++) {
        //println("a = " + a);
        if(a >= eachAngle*i && a < eachAngle*(i+1)) {
          if(myEmotionCategoryIndex != i){
            println("current index position is " + i);
            float correctAngle = eachAngle*myEmotionCategoryIndex + (eachAngle/2);
            xPos = homeX + 150*cos(correctAngle);
            yPos = homeY + 150*sin(correctAngle);
          }

        }
      }
  
  }

  void amIAlive() {

    if(myAlpha <= 0) { // if the age of the blob now, minus the 'time' it was when created is more than the 'life of the blob'
      alive = false; // it becomes "dead";
    }
    else {
      alive = true;
    }
  }

  boolean amIStillAlive() {
    return alive;
  }

  void breathingBlob() {

    float step = (maxIncreasedBlobSize - blobSize) /20;

    stroke(255);
    strokeWeight(2);
    fill(emotionColours[myEmotionCategoryIndex], myAlpha);
    ellipse(xPos, yPos, currentBlobSize, currentBlobSize);

    if(currentBlobSize <= maxIncreasedBlobSize) {
      currentBlobSize += step;
    }
  }

  void blowUp() {

    if(myEmotionCategoryIndex == -1) {
      fill(255,135,180, myAlpha);
    }
    else {
      fill(emotionColours[myEmotionCategoryIndex], myAlpha);
    }
    ellipse(xPos, yPos, currentBlobSize, currentBlobSize);
    fill(50, 150); //changingAlpha

    noStroke();
    ellipse(xPos, yPos,currentBlobSize-20, currentBlobSize-20);

    fill(0, myAlpha);
    textAlign(CENTER);
    blowUpTxtSize += 15;
    textSize(blowUpTxtSize);
    text("GOODBYE!",xPos,yPos);

    currentBlobSize += 50;
    currentBlobSize += 50;
    myAlpha -= 15;

    if(myAlpha <= 0 || currentBlobSize > myParent.width) {
      alive = false;
      kill = false;
    }
  }

  void mouseOver() {

    float disX = xPos - myParent.mouseX;
    float disY = yPos - myParent.mouseY;

    if (sqrt(sq(disX) + sq(disY)) < currentBlobSize/2) { //check where blob is in relation to the mouse position, if they are in the same place
      mouseOver = true; //set mouseOver boolean as true
      touched = true; //blobs have been interacted with
    }
    else {
      mouseOver = false; //if blob is not in the same position as the mouse, then set mouseOver to false
    }
  }

  boolean getMouseOver() {

    return mouseOver;
  }

  String getMyTweetText() {

    return myTweetText;
  }

  void setMyEmotionCategory(int index) {

    myEmotionCategoryIndex = index;
  }

  void setMyEmotionStrength(int index) {

    myStrengthIndex = index;
  }

  void setTweetText(String tweetText) {

    myTweetText = tweetText;
    //println("set tweet text to " + myTweetText);
  }

  boolean amIYou() {

    if(amITheUserObject) {

      return true;
    }
    else {

      return false;
    }
  }

  void killMe() {

    kill = true;
  }

  void setFadeRate(float fade) {

    fadeRate = fade;
  }

  void setDragPos() {

    xPos = mouseX;
    yPos = mouseY;
  }

  void setName(String myName) {
    name = myName;
   // println("******received name = " + name);
  }

  void setXYPos(float x, float y) {
    xPos = x;
    yPos = y;
  }

  float getXPos() {
    return xPos;
  }

  float getYPos() {
    return yPos;
  }

  void spawn() {
//println("*user object spawned*********");
    xPos = homeX;
    yPos = homeY;
    blowUpTxtSize = 22;
    mouseOver = false;
    currentBlobSize = blobSize;
    myAlpha = startAlpha;
    alive = true;
    kill = false;

    //println("my emotion category index = " + myEmotionCategoryIndex);
    
  }


  void errorCheckMe() {

    //    println("timer is = " + timerOn);
    //    println("mouse over me is = " + mouseOver);
    // println("I am alive = " + alive);
    //    println("stopTimeEllapsed is = " + stopTimeEllapsed);
    //    println("time now = "+ millis());
    //    println("my birth time is = " + birthTime);
    //println("my alpha = " + myAlpha);
    println(currentBlobSize);
  }
}
