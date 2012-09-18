

// == App Connector ===============
AppConnector app;
String appKey = "529e9da544c4e3bb87c5751d031346a8";


// == Public App Variables ========
color myColor;

int rectX = 10;
int rectY = 10;
int rectWidth = 40;
int rectHeight = 40;

// == Private App Variables =======


// == App =========================
void setup() {
  size(640, 480);
  noStroke();

  app = new AppConnector(this, appKey);
  app.isDebug(true);

  // will publish "getRandom()" return value
  app.publish("Random", "(float) a random number between 0-100");

  // will push "joern.MyColor" into setMyColor()
  app.sync("joern", "MyColor");
  
  // will push "johnny.BiggestBlob" into setRect()
  app.sync("johnny", "BiggestBlob", "Rect");
  
  // load the synced values from the server, and set app.available to true
  app.setup();
}

void draw() {
  if (!app.available()) return;
  
  // filled with @joern#myColor
  fill(myColor);

  // populated with @johnny#BiggestBlob
  rect(rectX, rectY, rectWidth, rectHeight);
}


// == Public App Methods ========

// will called on app.publish
float getRandom() {
  return random(100);
}

// will called on app.sync
void setMyColor(String val) {
  int[] v = int(split(val, ","));
  myColor = color(v[0], v[1], v[2]);
}

// will called on app.sync
void setRect(String val) {
  int[] v = int(split(val, ","));

  rectX = v[0];
  rectY = v[1];
  rectWidth = v[2];
  rectHeight = v[3];
}


