class CreateTweets {

  import twitter4j.TwitterFactory.*;

  String msg = "";
  String iFeel = "I feel ... ";
  String userName = "unknown";
  //oAuth access codes for I am Not Alone (Emotweetion II)
  String consumerKey = "yOoeyBH6hSn1M8JItZGew";
  String consumerSecret = "j5XgQpGezivQs7njcCK0qRNl7jHCiC2FOsLNCY46I";
  String accessToken = "223807372-MHaShE1rIL1oQga0aYwbFmDzOADBRKEuqUuJfRvJ";
  String accessTokenSecret = "2phamiFXHpSqteYfG1kW4a53qotlwgHK5kbE0WfOcTc";
  
  Twitter twitter;

  CreateTweets() {

    authorise();
  }

  void authorise() {

    twitter = new TwitterFactory().getOAuthAuthorizedInstance (consumerKey, consumerSecret,
    new AccessToken(accessToken, accessTokenSecret) ); 
  }

  void post2Twitter(String msg, String name) {

    if(name != null){
      userName = name;
    }else{
      
      userName = "unknown";
      
    }
    try {
      twitter4j.Status st = twitter.updateStatus(iFeel + msg + " ...by " + userName); //+  "" + second());
      println("Successfully updated the status to [" + st.getText() + "].");
    }
    catch (TwitterException e) {
      println("Twitter Error: " + e.getStatusCode());
    }
  }
}

