import org.json.*;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.HttpResponse;

import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;

import org.apache.commons.codec.binary.Base64;

class RequestHandler {
  // your app key
  private String appKey;

  private String protocol = "http://";
  private String host = "appconnector.joernroeder.de";
  private int port = 80;
  private String postUrl = "/app/publish";
  private String descUrl = "/app/desc";
  private String getUrl = "/app/sync";
  private String setupUrl = "/app/setup";
  
  private boolean debugResponse;

  private HttpClient client;
  private HttpPost post;
  private HttpResponse response;

  RequestHandler(PApplet applet, String appKey) {
    this.appKey = appKey;

    client = new DefaultHttpClient();
    post = new HttpPost();
  }
  
  public void setDebugResponse(boolean val) {
    debugResponse = val;
  }
  
  public boolean getDebugResponse() {
    return debugResponse;
  }

/*  private String getCredentials() {
    return new String(Base64.encodeBase64((appID + ":" + appKey).getBytes()));
  }*/

  /**
   * pushes values to the server
   */
  public boolean post(JSONObject values) {
    values = addAppKey(values);
    String r = postRequest(values, postUrl);
    return !r.equals("") ? true : false;
  }

  /**
   * get synced variables
   */
  public String get(JSONObject obj) {
    return postRequest(obj, getUrl);
  }
  
  /**
   * returns setup stuff. at the moment starttime and interval
   *
   */
  public JSONObject setup() {
    String[] r = loadStrings(protocol + host + setupUrl);
    return new JSONObject(r[0]);
  }
  
  /**
   * returns the current interval from the server
   */
  public int getInterval() {
    String[] r = loadStrings(protocol + host + setupUrl + "/interval");
    return int(r[0]);
  }
  
  /**
   * pushes the descriptions to the server
   * @param JSONObject descriptions
   */
  public void setDescription(JSONObject desc) {
    desc = addAppKey(desc);
    String r = postRequest(desc, descUrl);
  }
  
  
  // ====== INTERNAL METHODS ==================================

  /**
   * converts a JSONObject to a HashMap
   *
   * @param JSONObject obj
   * @return HashMap
   */
  private HashMap JSONToMap(JSONObject obj) {
    HashMap<String, Object> m = new HashMap();

    Iterator ks = obj.keys();
    while (ks.hasNext ()) {
      String k = ks.next().toString();
      m.put(k, obj.get(k));
    }

    return m;
  }

  /**
   * internal post request handler
   */
  private String postRequest(JSONObject obj, String url) {
    // return string
    String r = "";

    try {
      List<BasicNameValuePair> nameValuePairs = new ArrayList<BasicNameValuePair>();

      // set params
      Iterator ks = obj.keys();
      while (ks.hasNext ()) {
        String k = ks.next().toString();
        nameValuePairs.add(new BasicNameValuePair(k, obj.get(k).toString()));
      }

      //post.setURI(new URI(protocol + appID + ":" + appKey + "@" + host + ":" + port + url));
      post.setURI(new URI(protocol + host + url));
      post.setEntity(new UrlEncodedFormEntity(nameValuePairs));
      //post.addHeader("Authorization", "Basic " + getCredentials());

      // execute request and get response
      response = client.execute(post);

      BufferedReader rd = new BufferedReader(new InputStreamReader(response.getEntity().getContent()));

      String l;
      while ( (l = rd.readLine ()) != null) {
        r += l + "\n";
      }
      
      if (debugResponse) {
        println(r);
      }
    }
    catch (IOException e) {
      e.printStackTrace();
      return "";
    }
    catch (URISyntaxException e) {
      e.printStackTrace();
      return "";
    }
    
    return r;
  }

  private JSONObject addAppKey(JSONObject vals) {

    if (!vals.has("appKey")) {
      vals.put("appKey", appKey);
    }

    return vals;
  }
}
