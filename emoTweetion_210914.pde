import twitter4j.util.*;
import twitter4j.*;
import twitter4j.management.*;
import twitter4j.api.*;
import twitter4j.conf.*;
import twitter4j.json.*;
import twitter4j.auth.*;
import java.util.*;

String [] searchString;
int wheelCentreX, wheelCentreY, wheelRadius;
int numberOfEmotionCategories = 8;
int numStrengths = 3;
PlutchikWheel flower;
int numTweets=0;
int oldTweets = 0;
int numTweetsDiff = 5;
String emotionCategory;
String tweetText = "";
//arrays for storing calculated x,y co-ordinates
float[]textPointOnCircleX, textPointOnCircleY;
//colour to draw emotions in
int [] emotionCountCategoryTotal;
int [] emotionAlphas;
int emotionCountPerCategory, numTotEmotions;
TweetObject aTweet;
ArrayList<TweetObject> tweetObjectList, mouseOnTweetObj;
ArrayList<String> mouseOverTweetArray;
XMLSearch tweetSearch;
PApplet thisSketch;
int numLostTweets = 0;
PrintWriter errorCheckFile;

void setup () {

  size (800, 600);
  frameRate(30);
  thisSketch = this;
  setUpArrays();
  setUpSearch();
  setUpGraphics();
  setTextPos();
  boolean xmlReady = tweetSearch.finishedParsing();
  if (xmlReady) {
    getNewTweets();
  }
  errorCheckFile = createWriter("error.txt");
}


void draw () {

  background(0);
  smooth();
  flower.drawFlower();
  updateTweetObjects();
  updateText();
  updateCategoryCounts();
}

void setUpArrays() {

  emotionAlphas = new int [numberOfEmotionCategories];
  textPointOnCircleX = new float[numberOfEmotionCategories];
  textPointOnCircleY = new float[numberOfEmotionCategories];
  tweetObjectList = new ArrayList();
  mouseOnTweetObj = new ArrayList();
  mouseOverTweetArray = new ArrayList();
  
  emotionCountCategoryTotal = new int[numberOfEmotionCategories];
  for (int i=0; i<numberOfEmotionCategories; i++) {
    emotionCountCategoryTotal[i] = 0;
    emotionAlphas[i] = 0;
  }
}

void setUpSearch() {

  tweetSearch = new XMLSearch();
  numTotEmotions = tweetSearch.getTotalNumberOfEmotions();
  searchString = new String [numTotEmotions];
  searchString = tweetSearch.getAllSearchWords();
}

void setTextPos() {

  //works out angles for placing text on wheel
  for (int i=0; i<numberOfEmotionCategories; i++) {

    float eachAngle = (TWO_PI/numberOfEmotionCategories);
    float textAngle= eachAngle*i + (eachAngle/2);

    textPointOnCircleX[i]=wheelCentreX + (wheelRadius-150)*cos(textAngle);
    textPointOnCircleY[i]=wheelCentreY + (wheelRadius-150)*sin(textAngle);
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
      tweetSearch.search(tweetText); //perfom a search on tweet text

        String emotionCategory = tweetSearch.getTweetCategory();
      if (emotionCategory!=null) {
        int emotionCategoryIndex = tweetSearch.getCategoryIndex(emotionCategory);
        String emotionStrength = tweetSearch.getTweetStrength();
        String screenName = status.getUser().getScreenName();
        aTweet = new TweetObject(thisSketch, tweetText, emotionCategory, emotionCategoryIndex, emotionStrength, wheelCentreX, wheelCentreY, screenName);
        //aTweet = new TweetObject(thisSketch, wheelCentreX, wheelCentreY, "invisible");
        tweetObjectList.add(aTweet);
        // println("***object added***");
        updateCategoryCount(emotionCategoryIndex);
      } else {
        //println(tweetText);
        copyToFile(tweetText);
      }
    }

    //@Override
    public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {
      System.out.println("Got a status deletion notice id:" + statusDeletionNotice.getStatusId());
    }

    //@Override
    public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
      numLostTweets += numberOfLimitedStatuses;
      //println(numLostTweets);
      //int numToMake = 0;  
      //while(numToMake <= numberOfLimitedStatuses){
      //aTweet = new TweetObject(thisSketch, wheelCentreX, wheelCentreY, "invisible");
      //tweetObjectList.add(aTweet);
      // numToMake++;
      //}
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
  twitterStream.filter(new FilterQuery(0, null, searchString));
}

void copyToFile(String tweetText) {

  errorCheckFile.println(tweetText);
  errorCheckFile.flush();
}

void setUpGraphics() {

  wheelCentreX = (width /2);
  wheelCentreY = (height) /2;
  wheelRadius = ((width-10)/2);
  flower = new PlutchikWheel(wheelCentreX, wheelCentreY, wheelRadius, numberOfEmotionCategories);
  PFont font=loadFont("CharcoalCY-24.vlw");
  textFont(font, 18);
}

void updateTweetObjects() {

  int numTweetObj = tweetObjectList.size();
  int recordIndexOfMouseOverTweet = -1;
  // println("number of objects before = " + numTweetObj);
  for (int i=numTweetObj-1; i>=0; i--) {
    if (!tweetObjectList.get(i).amIStillAlive()) { //check if object is alive
      // println("***object removed***");
      tweetObjectList.remove(i); // ...remove it from the list, if not....
    }
  }

  numTweetObj = tweetObjectList.size();
  // println("number of objects after = " + numTweetObj);
  if (numTweetObj!=0) {
    for (int k=0; k < numTweetObj; k++) {
      if (tweetObjectList.get(k)!=null) {
        tweetObjectList.get(k).mouseOver();

        if (tweetObjectList.get(k).getMouseOver()) { //retrieve the mouseOn boolean for each item an dif it returns true...
          recordIndexOfMouseOverTweet = k; //record the index of that item
          break;
        }
        tweetObjectList.get(k).updateTweet();
      } else {

        println("null tweet found :( ");
      }
    }
  }
  
    if (recordIndexOfMouseOverTweet != -1) {
    mouseOnTweetObj.add(tweetObjectList.get(recordIndexOfMouseOverTweet));
  }

  if (mouseOnTweetObj.size() == 1) {

    mouseOnTweetObj.get(0).mouseOver();
    //String mouseOverText = mouseOnTweetObj.get(0).getMyTweetText();
    //displayMouseOverTweets(mouseOverText);
    // mouseOverTweetArray.add(mouseOverText);

    if (!mouseOnTweetObj.get(0).getMouseOver()) { //when checking if the mouse is On soemthing, it then is NOT over something (get mouse over returns as false)
      mouseOnTweetObj.remove(0);       //remove it from the mouseOn array
      recordIndexOfMouseOverTweet = -1; //return the index back to -1
    }
  }
  
}

void updateCategoryCounts() {

  if (numTweets > 0) {
    if (numTweets - oldTweets >= numTweetsDiff) {
      calculateEmoAlpha(); //update alpha of each petal
      oldTweets = numTweets;
    }
  }
}

void calculateEmoAlpha() {

  float maxEmotionPercent = 0;
  float [] emotionPercentArray = new float [numberOfEmotionCategories];

  for (int i=0; i<numberOfEmotionCategories; i++) {

    float categoryTweetCount = emotionCountCategoryTotal[i];
    float emotionPercent = (categoryTweetCount/ numTweets) *100;
    emotionPercentArray[i] = emotionPercent;
    if (emotionPercent > maxEmotionPercent) {
      maxEmotionPercent = emotionPercent;
    }
  }

  for (int j=0; j<numberOfEmotionCategories; j++) {
    int emotionAlpha = floor(map(emotionPercentArray[j], 0, maxEmotionPercent, 0, 220));
    emotionAlphas[j] = emotionAlpha;
  }

  maxEmotionPercent = 0; //re-set maximum to zero on each iteration
  flower.setNewEmoAlphas(emotionAlphas);
  //println("maxEmotionPercent outside of for loop = " + maxEmotionPercent);
}

void updateText() {

  //draw text
  int textX = 10;
  int textY = 40;

  //emotweetion product name
  fill(255, 135, 180);
  textAlign(RIGHT);
  fill(255);
  textSize(24);
  text("Emotweetion", width-10, height-30);

  fill(255);
  textAlign(LEFT);
  textSize(18);
  //text(tweetText,textX,textY+45);
  text("Total Tweet", textX, textY);
  text("Count ="+numTweets, textX, textY+22);

  for (int i=0; i<numberOfEmotionCategories; i++) {
    fill(flower.getEmoColour(i));

    if (i>1 && i<6) {
      textAlign(RIGHT);
    } else {
      textAlign(LEFT);
    }
    emotionCategory = tweetSearch.getACategory(i);

    if (i>=0 && i<4) {

      text(emotionCategory+":"+ emotionCountCategoryTotal[i], textPointOnCircleX[i], textPointOnCircleY[i]+23);
    } else {
      text(emotionCategory+":"+ emotionCountCategoryTotal[i], textPointOnCircleX[i], textPointOnCircleY[i]-3);
    }
  }
}

void displayMouseOverTweets(String mouseOverText) {

  //if(mouseOverTweetArray.size() > 0){
  //String tweetText = "";
  int textY = 200;
  fill(255); //tweetTextAlpha);
  textAlign(LEFT);
  textSize(12);
  text(mouseOverText, 10, textY, 180, 600);
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

void updateCategoryCount(int i) {

  emotionCountCategoryTotal[i] +=1;
}

