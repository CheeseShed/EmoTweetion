import twitter4j.conf.*;
import twitter4j.*;
import twitter4j.auth.*;
import twitter4j.api.*;

class CreateTweets {

  String msg = "";
  String iFeel = "I feel ... ";
  String userName = "unknown";
  //oAuth access codes for I am Not Alone (Emotweetion II)
  
  Twitter twitter;

  CreateTweets() {

    authorise();
  }

  void authorise() {

    ConfigurationBuilder cb = new ConfigurationBuilder();
    cb.setOAuthConsumerKey(consumerKey);
    cb.setOAuthConsumerSecret(consumerSecret);
    cb.setOAuthAccessToken(accessToken);
    cb.setOAuthAccessTokenSecret(accessTokenSecret);

    TwitterFactory tf = new TwitterFactory(cb.build());

    twitter = tf.getInstance();
    
    //twitter = new TwitterFactory().getOAuthAuthorizedInstance (consumerKey, consumerSecret, new AccessToken(accessToken, accessTokenSecret) );
   
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

