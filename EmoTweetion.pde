//import netscape.javascript.*;
import com.twitter.processing.*;
import java.util.ArrayList;
import twitter4j.conf.*;
import twitter4j.*;
import twitter4j.auth.*;
import twitter4j.api.*;
import controlP5.*;

int tweets=0;
int oldTweets = 0;
int numTweetsDiff = 5;
int numEmotions,numStrengths, timeLastInteraction;
int wheelCentreX, wheelCentreY, wheelRadius, tweetTextAlpha;
String tweetText = "";
String username="emotweetion";
String password="sunshine333";
String searchWords = "";
String emotionCategory, userTweetText, userName;
//arrays for storing calculated x,y co-ordinates
float[]textPointOnCircleX,textPointOnCircleY;
//arrays to count number of emotions and strength
int[][] emotionCount; 
//colour to draw emotions in
int [] emotionCountCategoryTotal;
int [] emotionAlphas;
int emotionCountPerCategory;
int maxTweetObj = 1000;
int numTweetObj = 0;
int noInteractionGap = 20000; //length of time with no interaction
//Objects:
PlutchikWheel plutchikWheel; //wheel containing visualisation info
GSR gsr; //gsr object
XMLSearch tweetSearch; //xml tweet search object
TweetObject aTweet, userTweet;
Panel tweetInputPanel; //input field for posting to twitter
int sidePanelWidth;
CreateTweets twitterPosting; //object to post to twitter (uses twitter4J Twitter Factory)
boolean draggingUserObject = false;
boolean displayUserTweet = true;
ArrayList<TweetObject> tweetObjectList, mouseOnTweetObj;
ArrayList<String> mouseOverTweetArray;

void setup() {

  background(0);
  size(1200, 1000); //big for projector
  //size(800,800); //size for smaller screen
  frameRate(30);
  setUpSearch(); //instantiates the XML search object
  setUpTwitter(); //instantiates the tweet stream object
  setUpArrays();
  setUpGraphics();
  setTextPos();
  createUserTweet();
}

void draw() {

  background(0);
  smooth();
  updateEverything(); //no. total Tweets, no. each emotion
}

void setUpSearch() {

  tweetSearch = new XMLSearch(this);
  numEmotions= tweetSearch.getNumEmotions();
  numStrengths = tweetSearch.getNumStrengths();
  searchWords = tweetSearch.getAllSearchWords();
}

void setUpTwitter() {

  String streamSearch = "1/statuses/filter.json?track="+searchWords;
  TweetStream s = new TweetStream(this,"stream.twitter.com",80,streamSearch,username,password);
  s.go();

  twitterPosting = new CreateTweets();
}

void createUserTweet() { //creates user tweet on launch
  userTweet = new TweetObject(this, wheelCentreX, wheelCentreY);
}

void setUpArrays() {

  //any array creation goes in here
  textPointOnCircleX = new float[numEmotions];
  textPointOnCircleY = new float[numEmotions];
  emotionAlphas = new int [numEmotions];
  tweetObjectList = new ArrayList();
  mouseOnTweetObj = new ArrayList();
  mouseOverTweetArray = new ArrayList();

  emotionCount=new int[numEmotions][numStrengths];
  emotionCountCategoryTotal = new int[numEmotions];
  for(int i=0; i<numEmotions; i++) {
    emotionCountCategoryTotal[i] = 0;
    emotionAlphas[i] = 0;
    for(int j=0; j<numStrengths; j++) {
      emotionCount[i][j]=0;
    }
  }
}

void setUpGraphics() {

  //any graphics set up goes in here

  tweetInputPanel = new Panel(this);
  sidePanelWidth = tweetInputPanel.getSidePanelWidth();

  wheelCentreX = ((width - sidePanelWidth) /2) + sidePanelWidth;
  wheelCentreY = (height - 100) /2;
  if(wheelCentreX <= wheelCentreY) {
    wheelRadius = wheelCentreX - sidePanelWidth - 10;
  }
  else {
    wheelRadius = wheelCentreY - 10;
  }

  plutchikWheel = new PlutchikWheel(wheelCentreX,wheelCentreY,wheelRadius,numEmotions);

  PFont font=loadFont("CharcoalCY-24.vlw");
  textFont(font,24);
}

void setTextPos() {

  //works out angles for placing text on wheel
  for(int i=0; i<numEmotions; i++) {

    float eachAngle = (TWO_PI/numEmotions);
    float textAngle= eachAngle*i + (eachAngle/2);

    textPointOnCircleX[i]=wheelCentreX + (wheelRadius-150)*cos(textAngle);
    textPointOnCircleY[i]=wheelCentreY + (wheelRadius-150)*sin(textAngle);
  }
}

void setUpGSR() { 

  //GSR gsr = new GSR(this);
}

void tweet(com.twitter.processing.Status tweet) { //this is from the tweet stream library - called automatically when a tweet comes in

  tweetText=tweet.text(); //store latest tweet text:
  tweetText = tweetText.toLowerCase(); //make everything lower case for easy comparison
  tweets+=1; //increase tweet count by one

  tweetSearch.search(tweetText); //perfom a search on tweet text

    int emotionCategoryIndex = tweetSearch.getEmotionCategoryIndex();
  int strengthIndex = tweetSearch.getStrengthIndex();
  String screenName = tweet.user().screenName();
  aTweet = new TweetObject(this,tweetText, emotionCategoryIndex, strengthIndex, wheelCentreX, wheelCentreY, screenName);
  //if(tweetObjectList.size() < 1){ //allowing only one tweet object at a time to be put into the list for error checking
  tweetObjectList.add(aTweet);
  // }
  emotionCount = tweetSearch.getEmotionCount(); //every time a new Tweet comes in, emotion count score array is fetched
  emotionCountCategoryTotal = tweetSearch.getEmotionCountCategoryArray(); //every time new tweet comes in, total category count array is fetched

  //redraw();
}

void updateEverything() {

  if(tweets > 0) {
    if(tweets - oldTweets >= numTweetsDiff) {
      calculateEmoAlpha(); //update alpha of each petal
      oldTweets = tweets;
    }
  }

  plutchikWheel.drawFlower();
  tweetInputPanel.update();
  updateText();
  updateTweetObjects();
  //displayMouseOverTweets();

  if(displayUserTweet) {
    userTweet.updateTweet();
    userTweet.mouseOver();
    if(!userTweet.amIStillAlive()) {
      displayUserTweet = false; //won't draw tweet if "dead"
    }
  } 
  else {
    //do nothing
  }

  if(millis() - timeLastInteraction >= noInteractionGap) {

    userTweet.killMe(); //set "alive" to false
    userTweet.setXYPos(wheelCentreX, wheelCentreY); //re-position to centre for next "spawning"
  }
}

void mouseDragged() {

  if(userTweet.getMouseOver()) {

    draggingUserObject = true;
    userTweet.setDragPos();
    userTweet.mouseOver();
  }
  timeLastInteraction = millis();
}

void mouseReleased() {
  //println("***********mouse released**");
  if(userTweet.getMouseOver()) {
   // println("get mouse over is " + userTweet.getMouseOver());
    draggingUserObject = false;

    if(displayUserTweet) {
      //works out which section of the Wheel the user object is released in....
      float currentX = userTweet.getXPos();
      float currentY = userTweet.getYPos();
      float distX = currentX - wheelCentreX;
      float distY = currentY - wheelCentreY;
      float a = atan2(distY, distX);
      if(a < 0) {
        a += TWO_PI;
      }
      float eachAngle = (TWO_PI/numEmotions);

      for(int i = 0; i<numEmotions; i++) {
        //println("a = " + a);
        if(a >= eachAngle*i && a < eachAngle*(i+1)) {
          //      float theta = eachAngle*i + (eachAngle/2);
          //      float xPos = distX*cos(theta);
          //      float yPos = distY*sin(theta);

          //      userTweetObject.get(0).setXYPos(xPos, yPos);
          userTweet.setMyEmotionCategory(i); //sets emotion category
          String emotion = tweetSearch.getEmotionCatName(i);
          tweetInputPanel.setTweetInputText(emotion);
          userTweetText = tweetInputPanel.getTweetInputText();
          twitterPosting.post2Twitter(userTweetText, username);
          userTweetText = emotion;
          userTweet.setTweetText("I feel ... " + userTweetText);
          //println("********mouse released at category: " + i);
        }
      }
    }
  }
  timeLastInteraction = millis();
}

void updateTweetObjects() {

  int numTweetObj = tweetObjectList.size();
  int recordIndexOfMouseOverTweet = -1;

  //if(!draggingUserObject) {
  for(int k=0; k < numTweetObj; k++) { //cycle through the array list of tweet objects....

    if(mouseOnTweetObj.size() == 0 && !draggingUserObject) {  //if the mouse is not dragging the user object

        tweetObjectList.get(k).mouseOver(); //run the mouse over checking function on everything in the list

      if(tweetObjectList.get(k).getMouseOver()) { //retrieve the mouseOn boolean for each item an dif it returns true...
        recordIndexOfMouseOverTweet = k; //record the index of that item
        break;
      }
    }

    tweetObjectList.get(k).updateTweet();
    //tweetObjectList.get(0).errorCheckMe();
  }

  if(recordIndexOfMouseOverTweet != -1) {
    mouseOnTweetObj.add(tweetObjectList.get(recordIndexOfMouseOverTweet));
  }

  if(mouseOnTweetObj.size() == 1) {

    mouseOnTweetObj.get(0).mouseOver();
    String mouseOverText = mouseOnTweetObj.get(0).getMyTweetText();
    displayMouseOverTweets(mouseOverText);
   // mouseOverTweetArray.add(mouseOverText);
    
    if(!mouseOnTweetObj.get(0).getMouseOver()) { //when checking if the mouse is On soemthing, it then is NOT over something (get mouse over returns as false)
      mouseOnTweetObj.remove(0);       //remove it from the mouseOn array
      recordIndexOfMouseOverTweet = -1; //return the index back to -1
    }
  }

  for(int i=numTweetObj-1; i>=0; i--) {
    if(!tweetObjectList.get(i).amIStillAlive()) { //check if object is alive
      tweetObjectList.remove(i); // ...remove it from the list, if not....
    }
  }
  //    if(tweetObjectList.size() >0){
  //     println("******************" + tweetObjectList.get(0) + "****************");
  //    tweetObjectList.get(0).errorCheckMe();
  //    }
}

void displayMouseOverTweets(String mouseOverText){

  //if(mouseOverTweetArray.size() > 0){
  //String tweetText = "";
  int textY = 200;
  fill(255); //tweetTextAlpha);
  textAlign(LEFT);
  textSize(12);
  text(mouseOverText,10,textY, 180, 600);
//  for(int j=0; j<mouseOverTweetArray.size(); j++){
//   
//    tweetText = mouseOverTweetArray.get(j);
//    text(tweetText,10,textY);
//  }

//    tweetTextAlpha -= 10;
//    textY += 50;
//    println(tweetText);

  //}
    /*for(int i=numTweetObj-1; i>=0; i--) {
    if(!tweetObjectList.get(i).amIStillAlive()) { //check if object is alive
      tweetObjectList.remove(i); // ...remove it from the list, if not....
    }*/
  


}

void updateText() {

  //draw text
  int textX = 10;
  int textY = 40;

  //emotweetion product name
  fill(255,135,180);
  textAlign(CENTER);
  textSize(32);
  text("I Am",width-100,height-63);
  text("Not Alone", width-100, height - 35);
  fill(255);
  textSize(20);
  text("Emotweetion II",width-100,height-10);

  //"I feel...." input box text
  fill(255,135,180);
  textAlign(LEFT);
  textSize(24);
  text("I feel...", sidePanelWidth + 10,height - 40);

  fill(255);
  textAlign(LEFT);
  textSize(20);
  //text(tweetText,textX,textY+45);
  text("Total Tweet",textX,textY);
  text("Count ="+tweets,textX,textY+22);

  for(int i=0; i<numEmotions; i++) {
    fill(plutchikWheel.getEmoColour(i));

    if(i>1 && i<6) {
      textAlign(RIGHT);
    }
    else {
      textAlign(LEFT);
    }
    emotionCategory = tweetSearch.getEmotionCatName(i);

    if(i>=0 && i<4) {

      text(emotionCategory+":"+ emotionCountCategoryTotal[i], textPointOnCircleX[i],textPointOnCircleY[i]+23);
    }
    else {
      text(emotionCategory+":"+ emotionCountCategoryTotal[i], textPointOnCircleX[i],textPointOnCircleY[i]-3);
    }
  }
}

void calculateEmoAlpha() {

  float maxEmotionPercent = 0;
  float [] emotionPercentArray = new float [numEmotions];

  for(int i=0; i<numEmotions; i++) {

    float categoryTweetCount = tweetSearch.getEmotionCountCategoryTotal(i);
    //println("category tweet count = " + categoryTweetCount);
    float emotionPercent = (categoryTweetCount/ tweets) *100;
    //println("emotionPercent = " + emotionPercent);
    //println("emotion Alpha = " + emotionAlpha);
    emotionPercentArray[i] = emotionPercent;
    //println("emotion Percent at: " + i + " = " + emotionPercent);
    if(emotionPercent > maxEmotionPercent) {
      maxEmotionPercent = emotionPercent;
    }
  }

  for(int j=0; j<numEmotions; j++) {

    int emotionAlpha = floor(map(emotionPercentArray[j],0,maxEmotionPercent,0,220));
    emotionAlphas[j] = emotionAlpha;
  }

  maxEmotionPercent = 0; //re-set maximum to zero on each iteration
  plutchikWheel.setNewEmoAlphas(emotionAlphas);
  //println("maxEmotionPercent outside of for loop = " + maxEmotionPercent);
}

void keyPressed() {

  if(key == RETURN || key == ENTER) {
    if(tweetInputPanel.myTextfield.isFocus()) {
      //println("tweet input is focus *******");
      tweetInputPanel.submit();
      userTweetText = tweetInputPanel.getTweetInputText();
      if(userTweetText != null) {
        
        tweetSearch.search(userTweetText);
        int emotionCategoryIndex = tweetSearch.getEmotionCategoryIndex();
        userTweet.setMyEmotionCategory(emotionCategoryIndex);
        twitterPosting.post2Twitter(userTweetText, userName);
        //println("user tweet text = " + userTweetText + "by " + userName);
        userTweet.setTweetText("I feel ... " + userTweetText);
      }
    } 
    else if(tweetInputPanel.userNameInputField.isFocus()) {
      //println("name input is focus *******");
      tweetInputPanel.newUser(); 
      userName = tweetInputPanel.getUserName();
      if(userName != null) {
        tweetInputPanel.newUser();
        userTweet.setName(userName);
      }
    }
  }
  
  if(key == 's') {
    save("emoTweetion.png");
  }
  
  timeLastInteraction = millis();

    if(!displayUserTweet) {
      userTweet.spawn();
      displayUserTweet = true;
    }
}

void mousePressed() {

  timeLastInteraction = millis(); //means interaction was done
}

public void controlEvent(ControlEvent theEvent) {

  //println("got a control event from controller with name "+theEvent.controller().name());
  if(theEvent.name().matches("submit")) {  // submit button 
    tweetInputPanel.submit();
    //println("************user input name ***");
    userTweetText = tweetInputPanel.getTweetInputText(); //get user tweet text from input box....
    if(userTweetText != null) { //if it's not empty, then create and send a tweet
      //send text in controller.name == "tweetInputText" to create a tweet
      println("userTweetText " + userTweetText);
      tweetSearch.search(userTweetText);
      int emotionCategoryIndex = tweetSearch.getEmotionCategoryIndex();
      println("emotion category index = " + emotionCategoryIndex);
      userTweet.setMyEmotionCategory(emotionCategoryIndex);
      twitterPosting.post2Twitter(userTweetText, userName); //post to twitter the contents of the text field
      //println("user tweet text = " + userTweetText + "by " + userName);
      userTweet.setTweetText("I feel ... " + userTweetText);
    }
    if(!displayUserTweet) { //if it's not currently displaying the user object, then display it and sapwn it back alive (because interaction was detected)
      
      userTweet.spawn();
      displayUserTweet = true;
    }
  }
  else if(theEvent.name().matches("clear")) {  // clear button
    //println("************user input name ***");
    tweetInputPanel.clear(); //clear the text in "tweetINputText"
  }
  else if(theEvent.name().matches("newUser")) {
    tweetInputPanel.newUser(); // press user name input button and set name in panel to text in field
    //println("************user input name ***");
    userName = tweetInputPanel.getUserName();
   // println("user name from event is " + userName);
    if(userName != null) {
    //  println("name is not null and is =  " + userName);
      userTweet.setMyEmotionCategory(-1);
      userTweet.spawn();
      userTweet.setName(userName); // get name from input panel and send to the user tweet to set as it's Name.
    }
    if(!displayUserTweet) {
      userTweet.spawn();
      displayUserTweet = true;
    }
  }

  timeLastInteraction = millis(); //means interaction was done
}

