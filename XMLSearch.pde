
class XMLSearch {

  XML xml;
  XML[] emotions;
  String[] categories;
  String[] allWords;
  int numberOfStrengths;
  int numberOfEmotionCategories;
  int numberOfTotalEmotions;
  String searchText, categoryName, strengthName, emotionName; 
  int [] emotionCountPerCategory; //number of counts of tweets in each category
  int strengthIndex, categoryIndex;
  boolean finishedParsing;

  XMLSearch () {

    categories = new String[] {
      "Joy", "Trust", "Fear", "Surprise", "Sadness", "Disgust", "Anger", "Anticipation"
    };
    numberOfEmotionCategories = categories.length;
    numberOfStrengths = 3;
    parseEmotionXML();
  }

  void parseEmotionXML() {

    xml = loadXML("emotweetionWords.xml"); //load XML  
    emotions = xml.getChildren("emotion");
    numberOfTotalEmotions = emotions.length;
    allWords = new String [numberOfTotalEmotions];
    emotionCountPerCategory = new int[numberOfEmotionCategories];

    for (int i=0; i<numberOfTotalEmotions; i++) {
      emotionName = emotions[i].getContent();
      allWords[i] = emotionName;
      if (i==numberOfTotalEmotions-1) {
        finishedParsing = true;
      }
    }
  }

  boolean finishedParsing() {
    return finishedParsing;
  }

  void search(String tweetText) {

    searchText = tweetText; //tweet text sent from Tweet Stream
    for (int i = 0; i < numberOfTotalEmotions; i++) { //cycle round "emotions"
      String emotionToSearchFor = allWords[i];
      String[] matchCase=match(searchText, "\\b"+emotionToSearchFor+"\\b");
      String[] matchBirthday=match(searchText, "\\bbirthday\\b");
      String[] matchNegatives=match(searchText, "\\bnot\\b|\\bno\\b");

      if (matchCase!=null&& matchNegatives==null&& matchBirthday==null) {
        categoryName = emotions[i].getString("category");
        strengthName = emotions[i].getString("strength");
      }
    }
  }


  int getTotalNumberOfEmotions() {

    return numberOfTotalEmotions;
  }

  String [] getAllSearchWords() {

    return allWords;
  }

  String getTweetCategory() {

    return categoryName;
  }

  String getTweetStrength() {

    return strengthName;
  }

  String getACategory(int i) {

    String category = categories[i];
    return category;
  }

  int getCategoryIndex(String categoryName) {
    for (int i=0; i<numberOfEmotionCategories; i++) {
      String[] matchCategory=match(categoryName, categories[i]);
      if (matchCategory!=null) {
        categoryIndex = i;
      }
    }

    return categoryIndex;
  }
}

