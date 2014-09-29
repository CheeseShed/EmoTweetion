import twitter4j.util.*;
import twitter4j.*;
import twitter4j.management.*;
import twitter4j.api.*;
import twitter4j.conf.*;
import twitter4j.json.*;
import twitter4j.auth.*;
import java.util.*;

String [] searchString = {
  "happy"
};
int wheelCentreX, wheelCentreY, wheelRadius;
int numEmotions = 8;
int numStrengths = 3;
PlutchikWheel flower;
int numTweets=0;
int oldTweets = 0;
String emotionCategory;
String tweetText = "";
//arrays to count number of emotions and strength
int[][] emotionCount; 
//colour to draw emotions in
int [] emotionCountCategoryTotal;
int [] emotionAlphas;
int emotionCountPerCategory;
TweetObject aTweet;
ArrayList<TweetObject> tweetObjectList;

void setup () {

  size (800, 600);
  //authorise();
  setUpArrays();
  getNewTweets();
  setUpGraphics();
}


void draw () {

  background(0);
  smooth();
  flower.drawFlower();
  updateTweetObjects();
}

void setUpArrays() {

  emotionAlphas = new int [numEmotions];
  tweetObjectList = new ArrayList();
  emotionCount=new int[numEmotions][numStrengths];
  emotionCountCategoryTotal = new int[numEmotions];
  for (int i=0; i<numEmotions; i++) {
    emotionCountCategoryTotal[i] = 0;
    emotionAlphas[i] = 0;
    for (int j=0; j<numStrengths; j++) {
      emotionCount[i][j]=0;
    }
  }
}

void getNewTweets() {

  ConfigurationBuilder cb = new ConfigurationBuilder();
  //oAuth access codes for I am Not Alone (Emotweetion II)
  cb.setDebugEnabled(true);
  cb.setOAuthConsumerKey("yOoeyBH6hSn1M8JItZGew");
  cb.setOAuthConsumerSecret("j5XgQpGezivQs7njcCK0qRNl7jHCiC2FOsLNCY46I");
  cb.setOAuthAccessToken("223807372-MHaShE1rIL1oQga0aYwbFmDzOADBRKEuqUuJfRvJ");
  cb.setOAuthAccessTokenSecret("2phamiFXHpSqteYfG1kW4a53qotlwgHK5kbE0WfOcTc");

  StatusListener listener = new StatusListener() {
    
    public void onStatus(Status status) {
    //System.out.println("@" + status.getUser().getScreenName() + " - " + status.getText());
      numTweets ++;
      tweetText=status.getText(); //store latest tweet text:
      tweetText = tweetText.toLowerCase();
      //tweetSearch.search(tweetText); //perfom a search on tweet text

      int emotionCategoryIndex = 0; //tweetSearch.getEmotionCategoryIndex();
      int strengthIndex = 1; //tweetSearch.getStrengthIndex();
      String screenName = status.getUser().getScreenName();
      aTweet = new TweetObject(tweetText, 0, 0, wheelCentreX, wheelCentreY, screenName);

      tweetObjectList.add(aTweet);
println("***num tweet object = " + tweetObjectList.size());
      //emotionCount = tweetSearch.getEmotionCount(); //every time a new Tweet comes in, emotion count score array is fetched
      //emotionCountCategoryTotal = tweetSearch.getEmotionCountCategoryArray();
      
    }

    //@Override
    public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {
      System.out.println("Got a status deletion notice id:" + statusDeletionNotice.getStatusId());
    }

    //@Override
    public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
      System.out.println("Got track limitation notice:" + numberOfLimitedStatuses);
    }

    //@Override
    public void onScrubGeo(long userId, long upToStatusId) {
      System.out.println("Got scrub_geo event userId:" + userId + " upToStatusId:" + upToStatusId);
    }

    //@Override
    public void onStallWarning(StallWarning warning) {
      System.out.println("Got stall warning:" + warning);
    }

    //@Override
    public void onException(Exception ex) {
      ex.printStackTrace();
    }
  };

  TwitterStream twitterStream = new TwitterStreamFactory(cb.build()).getInstance();
  twitterStream.addListener(listener);
  // sample() method internally creates a thread which manipulates TwitterStream and calls these adequate listener methods continuously.
  twitterStream.sample();
  twitterStream.filter(new FilterQuery(0, null, searchString));
}

void setUpGraphics() {

  wheelCentreX = (width /2);
  wheelCentreY = (height) /2;
  wheelRadius = ((width-10)/2);

  flower = new PlutchikWheel(wheelCentreX, wheelCentreY, wheelRadius, numEmotions);
}

void updateTweetObjects() {

  int numTweetObj = tweetObjectList.size();
  for (int k=0; k < numTweetObj; k++) {

    tweetObjectList.get(k).updateTweet();
    //println("***tweet  " + tweetObjectList.get(k) + "  is updated***");
  }

  for (int i=numTweetObj-1; i>=0; i--) {
    if (!tweetObjectList.get(i).amIStillAlive()) { //check if object is alive
      tweetObjectList.remove(i); // ...remove it from the list, if not....
    }
  }
}

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
      emotionAlphas[i] =  10;
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

//  int getFullCircleDiam() {
//
//    return fullCircleDiam;
//  }

  void setNewEmoAlphas(int [] alphaVal) {
    
   // newEmotionAlphas = alphaVal;
   emotionAlphas = alphaVal;
    
  }
}
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

  TweetObject(String tweetText, int emotionCategoryIndex, int strengthIndex, float x, float y, String screenName) {

    myTweetText = tweetText;
    myEmotionCategoryIndex = emotionCategoryIndex;
    myStrengthIndex = strengthIndex;   
    xPos = homeX = x;
    yPos = homeY = y;
    name = screenName;
    amITheUserObject = false;
    init();
  }

  TweetObject(float x, float y) { //constructor for creating User-inputted tweet

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
import java.util.*;

class XMLSearch {

  XML xml;
  XML emotionData; //Data for each emotion in XML
  XML tempEmotionData; // store inital data to count strength number
  XML emotionStrengths; //Data for each strength of each emotion in XML
  XML emotionWords; //Each emotion word under strength category in the XML
  XML[] allXMLWords;
  XML[] emotionCategories;
  //ArrayList allWords; //stores all <words>
  int numStrengths = 3;
  int numEmotions = 8;
  int numTotalWords;
  String strength, emotionCat, emotionName; //actual names of strengths,main emotions(parents) and actual keywords (without xml data) **Might not need emotions & strengths,as uses indexes of arrays,but just in case
  int [][] emotionCount; //counts instances of each type of emotion and strength of it
  String searchText;
  String [] allWords;
  int [] emotionCountCategoryTotal;
  int strengthIndex, emotionCategoryIndex;

  XMLSearch() {
    initXML();
    initEmotions();
  }

  void initXML() {

    xml = loadXML("Emotions.xml"); //load XML
    XML[] children = xml.getChildren("emotion");

    for (int i=0; i<numEmotions; i++) {
      println("xml get child = "  + children);
    }

    allXMLWords = xml.getChildren("emotion/strength/word");
    println(xml.getChildren("emotion/strength/word"));
    numTotalWords = allXMLWords.length;
    allWords = new String[numTotalWords];
  }

  void initEmotions() {

    emotionCount=new int[numEmotions][numStrengths];
    emotionCountCategoryTotal = new int [numEmotions];
    for (int i=0; i<numEmotions; i++) {
      emotionCountCategoryTotal[i] = 0;
      for (int j=0; j<numStrengths; j++) {
        emotionCount[i][j]=0;
      }
    }
  }

  String [] getAllSearchWords() {

    for (int i=0; i<numEmotions; i++) {
      XML strengths = xml.getChild(i);

      for (int j=0; j<numStrengths; j++) {
        XML emotionWords = strengths.getChild(j);
        int numWords = emotionWords.getChildCount();  

        for (int k=0; k<numWords; k++) {
          XML words = emotionWords.getChild(k);
          String tempWord = words.getContent();
          allWords [k] = tempWord;
        }
      }
    }

    return allWords;
  }

  void search(String tweetText) {

    searchText = tweetText; //tweet text sent from Tweet Stream
    for (int i = 0; i < numEmotions; i++) { //cycle round "emotions"
      emotionData = xml.getChild(i); //get each emotion

      for (int j = 0; j<numStrengths; j++) { //cycle round "strengths" of emotions
        emotionStrengths = emotionData.getChild(j); //get each strength
        int numWords = emotionStrengths.getChildCount(); //number of words under each strength

        for (int k = 0; k<numWords; k++) {
          emotionWords = emotionStrengths.getChild(k); //get each word
          emotionName = emotionWords.getContent(); //get the name of each emotion word

          String[] matchCase=match(searchText, "\\b"+emotionName+"\\b");
          String[] matchBirthday=match(searchText, "\\bbirthday\\b");
          String[] matchNegatives=match(searchText, "\\bnot\\b|\\bno\\b");

          if (matchCase!=null&& matchNegatives==null&& matchBirthday==null) {
            //println("********************found " + emotionName);
            //String strength = emotionWords.getParent().getAttribute("name");
            //String emotion = emotionWords.getParent().getParent().getAttribute("name");
            emotionCategoryIndex = i;
            strengthIndex = j;
            //println("strength is = " + strength);
            // println("emotion is =  " + emotion);

            //if it matches, bump emotion count for that emotion
            emotionCount[i][j]+=1;
            emotionCountCategoryTotal[i] +=1;
          }
        }
      }
    }
  }

  int[][] getEmotionCount() {

    return emotionCount;
  }

  int getEmotionCategoryIndex() {

    return emotionCategoryIndex;
  }

  int getStrengthIndex() {

    return strengthIndex;
  }

  int[] getEmotionCountCategoryArray() {

    return emotionCountCategoryTotal;
  }

  int getEmotionCountCategoryTotal(int i) {

    return emotionCountCategoryTotal[i];
  }

  int getNumEmotions() {

    return numEmotions;
  }

  int getNumStrengths() {

    return numStrengths;
  }

  String getEmotionCatName(int index) {

    int emotIndex = index;
    //println(xml.getChild(emotIndex));
    String emotion = xml.getString("emotion"); 

    return emotion;
  }
}


