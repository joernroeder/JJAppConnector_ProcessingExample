
AppConnector app;

void setup() {
  // stage
  size(400, 400);
  noStroke();
  
  // connector
  app = new AppConnector("1992678518e6eb285f645ee4f87f8061");
  
  app.addPublication("color", "(int) a random color from @hell");
  app.addPublication("f00", "BAR");
  
  app.subscribeTo("foofoo.ma");
  app.subscribeTo("processing01.f00", "foo");
  
//  app.get("color");
  //app.get("joern.color");
  
  /*
  Foo foo = new Foo(app);
  class Foo {
    Foo(AppConnector app) {
      app.addPublication("color");
      app.subscribeTo("bar");
    }
  }
  */
  app.start();
}

void draw() {
  if (!app.connected()) return;
  
  int c = frameCount % 255;

  //app.publish("color", c);
  
  fill(c);
  ellipse(width / 2, height / 2, 100, 100);
  
  println(app.get("foofoo.ma"));
}
