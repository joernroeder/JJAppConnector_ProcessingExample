import org.json.*;
import io.socket.*;

class AppConnector implements IOCallback {

  SocketIO socket;

  // server
  //  private String host = "http://localhost";
  private String host = "http://192.168.178.77";
  private int port = 3000;

  // app
  private String appKey;

  private HashMap<String, String> descriptions; // varName, description
  private HashMap<String, Object> publications; // varName, value
  private HashMap<String, Object> subscriptions; // varName, value
  private HashMap<String, String> subscriptionsShortcuts; // shortcut, name

  private HashMap<String, String> currentApps; // appKey, appTitle

  private boolean updating;

  private boolean isDebug = true;

  AppConnector(String appKey) {
    this.appKey = appKey;

    this.descriptions = new HashMap<String, String>();
    this.publications = new HashMap<String, Object>();
    this.subscriptions = new HashMap<String, Object>();
    this.subscriptionsShortcuts = new HashMap<String, String>();

    this.currentApps = new HashMap<String, String>();

    Properties props = new Properties();
    props.setProperty("appkey", this.appKey);

    try {
      this.socket = new SocketIO(host + ":" + port, props);
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  /**
   * Returns, if a connection is established at the moment
   * 
   * @return true if a connection is established, false if the transport is
   *         not connected or currently connecting
   */
  public boolean connected() {
    return this.socket.isConnected();
  }

  public boolean connected(String appName) {
    return true;
  }

  public void setDebug(boolean val) {
    this.isDebug = val;
  }

  public boolean isDebug() {
    return isDebug;
  }

  private void debug(Object obj) {
    if (isDebug) println(obj);
  }


  // --- publish ------------------------------------------------

  public void addPublication(String varName, String desc) {
    descriptions.put(varName, desc);
  }

  public void publish(String varName, Object val) {

    if (!descriptions.containsKey(varName)) {
      debug("wrong varName");
      return;
    }

    if (updating) {
      debug("still updating");
      return;
    }

    if (!connected()) {
      debug("not connected");
      return;
    }

    updating = true;

    if (isNewVal(varName, val)) {
      // cache value
      publications.put(varName, val);
      // publish
      socket.emit("update", varName, val);
    }
  }


  // --- subscribe ----------------------------------------------

  // joern.color
  public void subscribeTo(String name) {
    String[] app = split(name, ".");

    if (app.length >= 2) {
      subscribeTo(name, app[1]);
    }
    else {
      debug("nor appspace defined for varname: " + name + ". Format: app.varname");
    }
  }

  public void subscribeTo(String name, String varName) {
    subscriptions.put(name, null);

    // add and check shortcuts
    if (!subscriptionsShortcuts.containsKey(varName)) {
      subscriptionsShortcuts.put(varName, name);
    }
    else {
      debug("");
    }
  }


  public Object get(String varName) {
    if (varName.indexOf(".") > -1) {
      return subscriptions.get(varName);
    }
    else {
      return subscriptions.get(subscriptionsShortcuts.get(varName));
    }
  }

  public void start() {
    if (this.socket != null) {
      connectSocket();
    }
    else {
      debug("no socket");
    }
  }

  // === PRIVATE METHODS ========================================

  private boolean isNewVal(String varName, Object val) {
    if (publications.containsKey(varName)) {
      Object oldVal = publications.get(varName);

      if (oldVal.equals(val)) return false;
    }

    return true;
  }

  private void connectSocket() {
    this.socket.connect(this);
    updatePublications();
    sendSubscriptions();
  }

  private void updatePublications() {
    socket.emit("set publications", descriptions);
  }

  private void sendSubscriptions() {
    socket.emit("set subscriptions", subscriptions.keySet());
  }

  // --- SOCKET -------------------------------------------------

  void onMessage(JSONObject json, IOAcknowledge ack) {
    debug("Server said:" + json.toString(2));
  }

  void onMessage(String data, IOAcknowledge ack) {
    debug("Server said: " + data);
  }

  void onError(SocketIOException socketIOException) {
    debug("an Error occured");
    debug(socketIOException.getStackTrace());
  }

  void onDisconnect() {
    debug("Connection terminated.");
  }

  void onConnect() {
    debug("Connection established");
  }

  // handle custom socket events and there callbacks defined at SocketCallbacks.java
  void on(String event, IOAcknowledge ack, Object... args) {

    String eventName = event.replace(" ", "_").toUpperCase();

    try {
      switch (SocketCallbacks.valueOf(eventName)) {

      case CURRENTAPPS:
        updateCurrentApps(args);
        break;

      case SUBSCRIPTIONS_SUCCESS:
        onSubscriptionsSuccess(args);
        break;

      case UPDATE_SUCCESS:
        onUpdateSuccess(args);
        break;

      case BROADCAST:
        onBroadcast(args);
        break;

      default:
        debug("Server triggered event '" + event + "'");
        break;
      }
    }
    catch (Exception e) {
      debug(e.getStackTrace());
    }
  }

  void onSubscriptionsSuccess(Object... args) {
    JSONObject subMap = (JSONObject) args[0];

    Iterator<?> keys = subMap.keys();

    subscriptions.clear();

    while (keys.hasNext()) {
      String key = (String) keys.next();
      subscriptions.put(key, subMap.get(key));
    }
  }

  void updateCurrentApps(Object... args) {
    JSONObject current = (JSONObject) args[0];
    Iterator<?> keys = current.keys();

    currentApps.clear();

    while (keys.hasNext()) {
      String key = (String) keys.next();
      if (!key.equals(this.appKey)) {
        currentApps.put(key, (String) current.get(key));
      }
    }

    debug(currentApps);
  }

  void onUpdateSuccess(Object... args) {
    if ((Boolean) args[0]) {
      updating = false;
    }
  }

  void onBroadcast(Object... args) {
    if (args.length < 2) return;

    String name = (String) args[0];
    Object val = args[1];

    if (subscriptions.containsKey(name)) {
      subscriptions.put(name, val);
    }
  }
}

