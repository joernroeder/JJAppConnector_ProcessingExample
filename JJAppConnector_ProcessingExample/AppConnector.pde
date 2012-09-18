import org.json.*;
import java.lang.reflect.Method;

class AppConnector extends Thread {
  
  private boolean isDebug, available, running;
  
  // app reload interval. will be updated from the server
  private int interval = 500;
  
  private float APPCONNECTOR_VERSION = 0.2;

  // your app
  private PApplet applet;

  // interval to get new data from the server
  private int reloadInterval;

  private ArrayList<String> publishMethods;
  private HashMap<String, String> publishDescriptions;
  private HashMap<String, HashMap> syncMethods;

  private RequestHandler handler;

  AppConnector(PApplet applet, String appKey) {
    publishMethods = new ArrayList();
    publishDescriptions = new HashMap<String, String>();

    // synced app variables
    syncMethods = new HashMap<String, HashMap>(); // appKey => [var1 => methodName1, var2 => methodName2]

    handler = new RequestHandler(applet, appKey);

    this.applet = applet;
  }
  
  public void setDebugResponse(boolean val) {
    handler.setDebugResponse(val);
  }
  
  public boolean getDebugResponse() {
    return handler.getDebugResponse();
  }
  
  public void isDebug(boolean val) {
    isDebug = val;
  }
  
  public boolean isDebug() {
    return isDebug;
  }

  public void start() {
    running = true;
    println("Starting AppConnector Sync (will execute every " + interval + " milliseconds.)\n"); 
    super.start();
  }

  /*void quit() {
   println("Quitting."); 
   running = false;
   interrupt();
   }*/

  public void dispose() {
    running = false;

//    handler.dispose();
  }

  public boolean available() {
    return available;
  }

  // app is running
  public boolean isRunning() {
    return running;
  }

  // add method name to app methods
  public void publish(String name, String desc) {
    //name = name.toLowerCase();
    publishMethods.add(name);
    publishDescriptions.put(name, desc);
  }

  public void sync() {
    if (syncMethods.size() > 0) {
      String data = handler.get(new JSONObject(syncMethods));
      setMethods(new JSONObject(data));
    }
  }

  public void sync(String appKey, String name) {
    sync(appKey, name, name);
  }

  public void sync(String appKey, String name, String methodName) {
    if (!syncMethods.containsKey(appKey)) {
      syncMethods.put(appKey, new HashMap<String, String>());
    }
    
    HashMap appList = syncMethods.get(appKey);
    appList.put(name, methodName);
    syncMethods.put(appKey, appList);
  }

  public void setup() {
    JSONObject data = handler.setup();
    checkCurrentAppVersion((String) data.get("p5Version"));
    
    if (isDebug == true) {
      loaded();
    }
    else {
      interval = int(data.getString("interval"));
      
      try {
          // Wait five seconds
        sleep((long) getDelay(data.getInt("timestamp")));
        loaded();
      } 
      catch (Exception e) {
        e.printStackTrace();
      }
    }
  }
  
  void checkCurrentAppVersion(String version) {
    float v = new Float(version);
	
    if (v > APPCONNECTOR_VERSION) {
      println("\n\n------------------------------------------------\n");
      println("You're using an old version of the AppConnector!");
      println("Go to http://appconnector.joernroeder.de/download to get the latest version.");
      println("\n------------------------------------------------\n\n");
    }
  }

  
  // ====== INTERNAL METHODS ==================================

  private void loaded() {
    sync();
    //send descriptions
    handler.setDescription(new JSONObject(publishDescriptions));
    
    // start app sync
    available = true;
    start();
  }
  
  private long getDelay(int t) {
    long cTime = System.currentTimeMillis() / 1000;
    println("start in: " + (t - cTime) + " sec");
    
    return (t - cTime) * 1000;
  }
  
  // get 
  JSONObject publishMethods() {
    JSONObject methods = new JSONObject();

    for (int i = 0; i < publishMethods.size(); i++) {
      String m = publishMethods.get(i);
      JSONObject mo = publishMethod(m);
      methods.put(m, mo.get(m));
    }

    return methods;
  }

  /**
   * get Method Value in a JSONObject. 
   * So we don't have to specify a specific return type.
   *
   * @link http://www.rgagnon.com/javadetails/java-0031.html
   */
  private JSONObject publishMethod(String name) {
    Object paramsObj[] = {
    };
    JSONObject o = new JSONObject();

    try {
      Class thisClass = Class.forName(applet.args[3]);
      Method thisMethod = thisClass.getDeclaredMethod("get" + toUpperCaseFirstChar(name));
      o.put(name, thisMethod.invoke(applet, paramsObj));
    } 
    catch (Exception e) {
      e.printStackTrace();
    }

    return o;
  }

  private String getMethodNameForSyncKey(String appKey, String varName) {
    String r = "";
    
    if (!syncMethods.containsKey(appKey)) return r;

    HashMap app = syncMethods.get(appKey);

    if (!app.containsKey(varName)) return r;

    return (String) app.get(varName);
  }

  private void setMethods(JSONObject data) {
    Iterator appKeys = data.keys();
    while (appKeys.hasNext ()) {
      String appKey = appKeys.next().toString();

      JSONObject appData = (JSONObject) data.get(appKey);
      Iterator methodNames = appData.keys();
      while (methodNames.hasNext()) {
        String methodName = methodNames.next().toString();
        //println(methodName);
        String name = getMethodNameForSyncKey(appKey, methodName);
        if (!name.equals("")) {
          setMethod(name, appData.get(methodName));
        }
      }
    }
  }

  private void setMethod(String name, Object value) {
    try {
      Class thisClass = Class.forName(applet.args[3]);

      Method methods[] = thisClass.getDeclaredMethods();

      for (int i = 0; i < methods.length; i++) {  
        Method m = methods[i];
        Class params[] = m.getParameterTypes();
        // if setValName
        if (params.length != 0 && m.getName().equals("set" + toUpperCaseFirstChar(name))) {

          // call method
          m.invoke(applet, value.toString());
          break;
        }
      }
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }

  void run() {
    while (running) {
      // store it -> post to server
      if (publishMethods.size() > 0) {
        handler.post(publishMethods());
      }
      
      available = true;
      try {
        // Wait five seconds
        sleep((long) interval / 2);
        sync();
        int iv = handler.getInterval();
        sleep((long) interval / 2);
        interval = iv;
        
      } 
      catch (Exception e) {
        e.printStackTrace();
      }
    }
  }

  /**
   * Make a string's first character uppercase
   *
   * @param String s
   * @return String
   */
  private String toUpperCaseFirstChar(String s) {
    String u = s.substring(0, 1);
    u = u.toUpperCase();

    String l = s.substring(1);

    return u + l;
  }
}

