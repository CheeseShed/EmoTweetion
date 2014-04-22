import processing.xml.*;

class XMLSearch {
  PApplet pApplet;
  XMLElement node; // full XML data
  XMLElement emotionData; //Data for each emotion in XML
  XMLElement tempEmotionData; // store inital data to count strength number
  XMLElement emotionStrengths; //Data for each strength of each emotion in XML
  XMLElement emotionWords; //Each emotion word under strength category in the XML (still jas <word> as it's an XMLElement)
  XMLElement[] allXMLWords;
  ArrayList allWords; //stores all <words>
  int numEmotions, numStrengths, numTotalWords; //number of emotions & strengths and total words
  String strength, emotionCat, emotionName, allWordsInOneString; //actual names of strengths,main emotions(parents) and actual keywords (without xml data) **Might not need emotions & strengths,as uses indexes of arrays,but just in case
  int [][] emotionCount; //counts instances ofeach type of emootion and strength of it
  String searchText;
  int [] emotionCountCategoryTotal;
  int strengthIndex, emotionCategoryIndex;

  XMLSearch(PApplet pa) {

    pApplet = pa;
    initXML();
    initEmotions();

  }

  void initXML() {

    node = new XMLElement(pApplet, "emotweetionWords.xml"); //load XML
    numEmotions = node.getChildCount(); //counts number of emotion categories
    tempEmotionData = node.getChild(0); //gets first emotion category data
    numStrengths = tempEmotionData.getChildCount(); //takes number of strengths from first category of emotions
    allXMLWords = node.getChildren("emotion/strength/word");
    numTotalWords = allXMLWords.length;
    allWords = new ArrayList();
    allWordsInOneString = "";

  }

  void initEmotions() {

    emotionCount=new int[numEmotions][numStrengths];
    emotionCountCategoryTotal = new int [numEmotions];
    for(int i=0; i<numEmotions; i++) {
      emotionCountCategoryTotal[i] = 0;
      for(int j=0; j<numStrengths; j++) {
        emotionCount[i][j]=0;
      }
    }

  }

  void search(String tweetText) {

    searchText = tweetText; //tweet text sent from Tweet Stream
    for (int i = 0; i < numEmotions; i++) { //cycle round "emotions"
      emotionData = node.getChild(i); //get each emotion

      for(int j = 0; j<numStrengths; j++) { //cycle round "strengths" of emotions
        emotionStrengths = emotionData.getChild(j); //get each strength
        int numWords = emotionStrengths.getChildCount(); //number of words under each strength

        for(int k = 0; k<numWords; k++) {
          emotionWords = emotionStrengths.getChild(k); //get each word
          emotionName = emotionWords.getContent(); //get the name of each emotion word

          String[] matchCase=match(searchText,"\\b"+emotionName+"\\b");
          String[] matchBirthday=match(searchText,"\\bbirthday\\b");
          String[] matchNegatives=match(searchText,"\\bnot\\b|\\bno\\b");

          if(matchCase!=null&& matchNegatives==null&& matchBirthday==null) {
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
  
  int getEmotionCategoryIndex(){
  
    return emotionCategoryIndex;

  }
  
  int getStrengthIndex(){
  
    return strengthIndex;
  
  }

  int[] getEmotionCountCategoryArray() {

    return emotionCountCategoryTotal;
  }
  
  int getEmotionCountCategoryTotal(int i){
  
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
    String emotion = node.getChild(emotIndex).getAttribute("name");

    return emotion;
  }

  String getAllSearchWords() {

    for(int i=0; i<numEmotions; i++) {
      XMLElement strengths = node.getChild(i);

      for(int j=0; j<numStrengths; j++) {
        XMLElement emotionWords = strengths.getChild(j);
        int numWords = emotionWords.getChildCount();  

        for(int k=0; k<numWords; k++) {
          XMLElement words = emotionWords.getChild(k);
          String tempWord = words.getContent();
          allWords.add(tempWord);
          if(k<numWords-1) {
            allWordsInOneString = allWordsInOneString.concat(tempWord).concat(",");
          }
          else {
            allWordsInOneString = allWordsInOneString.concat(tempWord);
          }
        }
      }
    }

    return allWordsInOneString;
  }
}

