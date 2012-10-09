//
//  JJAppConnector Processing Example 0.1  
//  (c) 2012, Jörn Röder & Jonathan Pirnay a.k.a jj
//  
//  Do what the fuck you want to under the WTFPL license (http://en.wikipedia.org/wiki/WTFPL)
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  http://appconnector.jit.su
//  Project on GitHub: http://github.com/joernroeder/JJAppConnector_ProcessingExample
//

import jj.appconnector.*;

AppConnector app;
String appKey = "765dd8a94d96472e8c7ea3ce571a6f04";

void setup() {
  // stage
  size(400, 400);
  noStroke();

  // connector
  app = new AppConnector(appKey);

  app.addPublication("color", "(int) a random int between 0 and 255");

  app.subscribeTo("OfExample.color");

  app.start();
}

void draw() {
  if (!app.isConnected()) return;

  // publish a color
  int myColor = frameCount % 255;
  app.publish("color", myColor);

  // get the OfExample.color
  int ofColor = app.get("OfExample.color").toInt();
  // int ofColor = app.get("color").toInt();          <-- this would also work (see http://bit.ly/OQgxo1)
  
  fill(ofColor);

  ellipse(width / 2, height / 2, 100, 100);
}

