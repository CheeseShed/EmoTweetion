class TweetObject {

  String myTweetText = "";
  String myEmotionCategory, myEmotionStrength;
  int myCategoryIndex, myStrengthIndex;
  int [] emotionColours;
  float theta;
  float xPos, yPos, homeX, homeY;
  float mySpeed = 1.2;
  int limitIntenseRadius = 100;
  int limitBasicRadius = 225;
  int limitOuterRadius = 300;
  boolean alive, mouseOver, touched, kill, amITheUserObject;
  int birthTime;
  float oneEigthAngleRadians=TWO_PI/8;
  float anglePath, myAlpha, fadeRate, timerAlpha;
  float dx, dy = 0;
  PApplet myParent;
  int maxIncreasedBlobSize, currentBlobSize, blobSize, blowUpTxtSize;
  float changingFill, changingAlpha, startAlpha;
  String name = "";
  int trackedEmoColour = #ffffff;


  TweetObject(PApplet pa, String tweetText, String emotionCategory, int emotionCategoryIndex, String emotionStrength, float x, float y, String screenName) {

    myTweetText = tweetText;
    myEmotionCategory = emotionCategory;
    myCategoryIndex = emotionCategoryIndex;
    myEmotionStrength = emotionStrength;  
    xPos = homeX = x;
    yPos = homeY = y;
    myParent = pa;
    name = screenName;
    amITheUserObject = false;
    init();
  }
  
  TweetObject(PApplet pa, float x, float y, String screenName){ //constructor for track-limited tweets
  
    println("tracked limit reached... "); 
    myParent = pa;
    xPos = homeX = x;
    yPos = homeY = y;
    name = screenName;
    amITheUserObject = false;
    init();
  
  }

  void init() {

    emotionColours = new int[] {
      #ffff00, #3bff18, #337700, #007cf7, #0014c5, #9400b5, #cc2222, #ff5a18
    };
    alive = true;
    kill = false;
    birthTime = millis();
    mouseOver = false;
    timerAlpha = 0;

  if(name.equals("invisible")){
    
    anglePath = random(0, 360);
  
  }else{
    anglePath = random((oneEigthAngleRadians*myCategoryIndex), (oneEigthAngleRadians+(oneEigthAngleRadians*myCategoryIndex)));
  }
    if (myEmotionStrength.equals("intense")) {
      blobSize = currentBlobSize = 30;
      mySpeed *= 4.5;
      myAlpha = 220;
      fadeRate = 4.0;
    } else if (myEmotionStrength.equals("basic")) {     
      blobSize = currentBlobSize = 20;
      mySpeed *= 3.0;
      myAlpha = 190;
      fadeRate = 1.5;
    } else if (myEmotionStrength.equals("low")) {
      blobSize = currentBlobSize = 10;
      mySpeed *= 1.2;
      myAlpha = 150;
      fadeRate = 0.4;
    } else {
      //non-categorised track-limited tweets
      blobSize = currentBlobSize = 5;
      mySpeed *= 6;
      myAlpha = 100;
      fadeRate = 0.2;
    }

    if (!amIYou()) {
      dx = cos(anglePath);
      dy = sin(anglePath);
      maxIncreasedBlobSize = 50;
      theta = 0;
    } else {

      dx = 5*cos(theta);
      dy = 5*sin(theta);

      //some sort of circular motion around an x,y position if it's the user object
    }
  }

  void updateTweet() {

    if (!mouseOver) { //if mouse isn't over blob

      drawTweet();
      amIAlive(); //...check if tweet object is less than 10 secs old
      updatePos(); //update it's position
    } else { //if mouseOver is on me

        if (!amIYou()) { //if not the user tweet object

        breathingBlob(); //create a "breathing" animation
        displayName();
      } else {

        drawTweet();
      }
    }

    if (amIYou()) {

      theta += PI/32;
    }
  }

  void drawTweet() {

    if (!amIYou()) { //normal blobs
      if (touched) {
        stroke(255);
        strokeWeight(2);
      } else {
        noStroke();
      }

      if (currentBlobSize >= blobSize) {
        currentBlobSize --;
      }

  if(name.equals("invisible")){
    fill(trackedEmoColour, myAlpha);
  
  }else {
      fill(emotionColours[myCategoryIndex], myAlpha); //out of bounds
  }
      ellipse(xPos, yPos, currentBlobSize, currentBlobSize);
    } else { //references user tweet object blob
      //println(mouseOver);

      // println("my emotion category index (draw)= " + myEmotionCategoryIndex);
      if (!kill) {
        //println("not kill*****");
        if (myCategoryIndex == -1) {
          fill(255, 135, 180, myAlpha);
        } else {
          fill(emotionColours[myCategoryIndex], myAlpha);
        }

        stroke(50);
        strokeWeight(0.5);
        ellipse(xPos, yPos, currentBlobSize, currentBlobSize);

        if (mouseOver) {
          changingFill = 50;
        } else {
          fill(changingFill, 150); //changingAlpha
        }
        noStroke();
        ellipse(xPos, yPos, currentBlobSize-20, currentBlobSize-20);
        fill(255);
        textAlign(CENTER);
        textSize(20);
        text(name, xPos, yPos-currentBlobSize/2);
        //println("*****name in text in draw is " + name);
        //popMatrix();
      } else { //animation for blowing up tweet when dead

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
    fill(emotionColours[myCategoryIndex]);
    text(name, currentBlobSize/2 + 2, 12);
    translate(-currentBlobSize/2 +2, -currentBlobSize/2 +2);
    popMatrix();
    
  }

  void updatePos() {

    if (!amIYou()) {

      xPos += mySpeed*dx;
      yPos += mySpeed*dy;  //move blob
    } else {

      changingFill = 128 + 127*cos(theta);
      if (myCategoryIndex != -1) {
        checkPositionIsInCategory();
      }
    }

    myAlpha -= fadeRate;

    if (!alive || myAlpha <= 0) {
      myAlpha = 0;
    }
  }

  void checkPositionIsInCategory() {

    float distX = xPos - wheelCentreX;
    float distY = yPos - wheelCentreY;
    float a = atan2(distY, distX);
    if (a < 0) {
      a += TWO_PI;
    }
    float eachAngle = (TWO_PI/numberOfEmotionCategories);

    for (int i = 0; i<numberOfEmotionCategories; i++) {
      //println("a = " + a);
      if (a >= eachAngle*i && a < eachAngle*(i+1)) {
        if (myCategoryIndex != i) {
          //println("current index position is " + i);
          float correctAngle = eachAngle*myCategoryIndex + (eachAngle/2);
          xPos = homeX + 150*cos(correctAngle);
          yPos = homeY + 150*sin(correctAngle);
        }
      }
    }
  }

  void amIAlive() {

    if (myAlpha <= 0) { // if the age of the blob now, minus the 'time' it was when created is more than the 'life of the blob'
      alive = false; // it becomes "dead";
    } else {
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
    fill(emotionColours[myCategoryIndex], myAlpha);
    ellipse(xPos, yPos, currentBlobSize, currentBlobSize);

    if (currentBlobSize <= maxIncreasedBlobSize) {
      currentBlobSize += step;
    }
  }

  void blowUp() {

    if (myCategoryIndex == -1) {
      fill(255, 135, 180, myAlpha);
    } else {
      fill(emotionColours[myCategoryIndex], myAlpha);
    }
    ellipse(xPos, yPos, currentBlobSize, currentBlobSize);
    fill(50, 150); //changingAlpha

    noStroke();
    ellipse(xPos, yPos, currentBlobSize-20, currentBlobSize-20);

    fill(0, myAlpha);
    textAlign(CENTER);
    blowUpTxtSize += 15;
    textSize(blowUpTxtSize);
    text("GOODBYE!", xPos, yPos);

    currentBlobSize += 50;
    currentBlobSize += 50;
    myAlpha -= 15;

    if (myAlpha <= 0 || currentBlobSize > myParent.width) {
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
    } else {
      mouseOver = false; //if blob is not in the same position as the mouse, then set mouseOver to false
    }
  }

  boolean getMouseOver() {

    return mouseOver;
  }

  String getMyTweetText() {

    return myTweetText;
  }

  String getMyStrength() {

    return myEmotionStrength;
  }

  String getMyCategory() {

    return myEmotionCategory;
  }

  void setMyEmotionCategory(int index) {

    myCategoryIndex = index;
  }

  void setMyEmotionStrength(int index) {

    myStrengthIndex = index;
  }

  void setTweetText(String tweetText) {

    myTweetText = tweetText;
    //println("set tweet text to " + myTweetText);
  }

  boolean amIYou() {

    if (amITheUserObject) {

      return true;
    } else {

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
    //println(currentBlobSize);
  }
}

