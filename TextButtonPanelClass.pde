class Panel {

  import controlP5.*;

  ControlP5 controlP5;

  String tweetInputText;
  String userName;
  Textfield myTextfield, userNameInputField;
  PApplet myParent;
  int xPos, yPos, myWidth, myHeight;
  boolean sidePanelLeft = true; //is side panel on left? if not, then it's on the right.
  boolean inputPanelBottom = true;
  int sidePanelWidth, sidePanelHeight, tweetInputPanelWidth, tweetInputPanelHeight, sidePanelX, inputPanelY, sketchWidth, sketchHeight;
  int textFieldWidth, textFieldHeight, iFeelX, iFeelY, gap;

  Panel(PApplet pa) {

    myParent = pa;
    sketchWidth = myParent.width;
    sketchHeight = myParent.height;
    init();
  }

  void init() {

    controlP5 = new ControlP5(myParent);
    PFont font=loadFont("CharcoalCY-24.vlw");
    textFont(font,24);

    sidePanelWidth = 200;
    sidePanelHeight = sketchHeight;
    tweetInputPanelWidth = sketchWidth - sidePanelWidth;
    tweetInputPanelHeight = 100;
    textFieldWidth = 550;
    textFieldHeight = 20;
    gap = 10;
    iFeelX = sidePanelWidth + gap;
    iFeelY = sketchHeight - (6*gap);

    setUpTweetPanel();
    setUpUserNamePanel();
    update();
  }

  void update() {

    drawInfoPanel();
    //updates ControlP5 stuff automatically
  }

  void drawInfoPanel() {

    fill(0);
    stroke(255);
    strokeWeight(0.5);
    rect(0,0,sidePanelWidth, sidePanelHeight-0.5);
    rect(sidePanelWidth, sketchHeight-tweetInputPanelHeight-0.5, tweetInputPanelWidth, tweetInputPanelHeight);

    fill(255);
    textAlign(LEFT);
    textSize(12);
    text("Hello! Please enter your name:",gap,110);

  }
  
  void setUpUserNamePanel(){
  
    userNameInputField = controlP5.addTextfield("userNameInput", gap, 120, 120, 20);
    userNameInputField.setAutoClear(false);
    userNameInputField.keepFocus(false);
    controlP5.addButton("newUser",0, (2*gap) + 120,120,50,20);
  
  }

  void setUpTweetPanel() {

    myTextfield = controlP5.addTextfield("TweetTextInput", iFeelX+100, iFeelY, textFieldWidth, textFieldHeight);
    myTextfield.setAutoClear(false);
    myTextfield.keepFocus(false);

    controlP5.addButton("submit",0,(iFeelX+100+textFieldWidth+gap),iFeelY,60,20); //button place at same y position as Text, but x pos is text box x + length of box + 10 px
    controlP5.addButton("clear",0,(iFeelX+100+textFieldWidth+(8*gap)),iFeelY,50,20);
  }

  public void clear() {
    //println("clear!");
    myTextfield.clear();
    //println("pressed clear");
  }

  public void submit() {
    //println("********pressed submit****");
    myTextfield.submit();
    //println("pressed submit from inside text field class");
    tweetInputText = myTextfield.getText();
  }

  public void newUser() {
    userNameInputField.submit();
    //println("pressed submit from inside text field class");
    userName = userNameInputField.getText();
  }

  String getTweetInputText() {
    //println("### got an event from textA : "); //+ theEvent.controller().stringValue());
    return tweetInputText;
  }

  String getUserName() {
    return userName;
  }

  void setTweetInputText(String inputTextFromWheel) {
//println("****setting my text field text to " + inputTextFromWheel);
    tweetInputText = inputTextFromWheel;
    myTextfield.setText(tweetInputText);
    
  }
  
  void clearUserNameField() {
 // println("clear name field!");
    userNameInputField.clear();
    
  }

  int getSidePanelWidth() {

    return sidePanelWidth;
  }
} //EOF

