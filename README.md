# Processing API

JJAppConnector for Processing is actually very simple to use.
The general setup is:

*	[Create](#constructor) an instance of AppConnector with your key
*	Specify your [publications](#pub) and [subscriptions](#sub)
*	Kick things off by using [start()](#start)
*	[Publish](#pub-func) your variables and [access](#get-func) your subscriptions
*	Have fun!

---
<a name="constructor" />
## Constructor

Construct an instance of the AppConnector-class by passing as an argument the key which you got after registering an app:

```java
String appKey = "1234567890abcdefg";
AppConnector app = new AppConnector(appKey);
```

## isConnected()

Checks whether your application is connected to the server, i.e.
```java
if (app.isConnected()) {
	System.out.print("I am connected!");
}
```

## isConnected(_appTitle_)

Checks whether an app with the specified _appTitle_ is currently online and running, i.e.
```java
if (app.isConnected("david")) {
	System.out.print("David's app is connected");
}
```

<a name="start" />
## start()

Kick off things by:

```java
app.start()
```

Please remember that by now you have to specify your [publications](#pub) and [subscriptions](#sub) __before__ using `start`

<a name="pub" />
## addPublication(_varName_, _description_)

Define a publication for your application. (By now you have to use this function __before__ kicking things off with _start()_ ) As first parameter, specify a name for the publication. As second parameter, specify a description which will be displayed within the app list (starting with the returnType in brackets).
Let's say we want to register a publication that is a random integer between 1 and 100:

```java
app.addPublication("random", "(int) a random value between 1 and 100");
```

To publish a value, use [_publish()_](#pub-func)

<a name="sub" />
## subscribeTo(_appTitle.varName_[, _shortcut_ ])

If you want to have access to the value of an app's publication, you need to subscribe to it by using `app.subscribeTo("appName.variableName")`. For example, if you want to subscribe to David's random-publication, use
```java
app.subscribeTo("david.random");
```

You could now access the value of the subscription by using `app.get("david.random").getValue()` __or__ the shortcut `app.get("random").getValue()`.
Please note that you can define your own shortcuts by passing in a shortcut argument. This is especially useful if multiple apps are using the same publication names. For example I could subscribe to David's random-publication this way

```java
app.subscribeTo("david.random", "d-random");
```

and then access the value by `app.get("d-random")`.

<a name="pub-func" />
## publish(_varName_, _value_)

Publish a value and push it to the server. Pass in the publication name and the value you want to publish. Using the "random" example from above:

```java
app.publish("random", floor(random(1, 101)));
```

Please note that you can only publish to publications which you have specified! See [_addPublication()_](#pub) for more information.

<a name="get-func" />
## get(_appTitle.varName_ || _shortcut_).getValue()

Access the current value of one of your subscriptions by either `appTitle.varName` or a `shortcut`. Using the example above this could look like 

```java
app.get("david.random").getValue();
```
or
```java
app.get("random").getValue();
```
or (if the shortcut has been specified)
```java
app.get("d-random").getValue();
```

__Please note__ that the method `getValue()` returns the current value as an instance of __java.lang.Object__.
There are, though, several helper methods which let you directly cast the value.
Let's take a look at an example.

Instead of writing
```java
Object randomObj = app.get("david.random").getValue();
int i = (Integer) randomObj;	// this could throw a ClassCastExeption or NullPointerException
```
you can write
```java
int randInt = app.get("david.random").toInt();
```

Following methods are currently available:

### toString()
Casts to `String`. If Object is null, an empty String will be returned.

### toBoolean()
Casts to `boolean`. If Object is null, `false` will be returned. If the Object is numeric and greater than 0, `true` will be returned, else `false`.

### toInt()
Casts to `int`. If Object is null, 0 will be returned. If the String-value of the Object equals "true", 1 will be returned.

### toDouble()
Casts to `double`. See `toInt()` above.

### toFloat()
Casts to `float`. See `toInt()` above.

### toPImage()
Tries to convert the data to an instance of PImage (see [_processing.core.PImage_](http://processing.googlecode.com/svn/trunk/processing/build/javadoc/core/processing/core/PImage.html)). If Object is null, a new instance of PImage will be returned.

For more information on subscriptions and shortcuts, see [_subscribeTo()_](#sub).

## debug(_value_)

Prints `value` to the console if debug mode is on.

## setDebug(_boolean_)

Enable or disable debug mode. If disabled, no messages will be logged.

## isDebug()

Returns `true` if debug mode is on, else `false`.

## version()

Returns the version of AppConnector you are using as a `float`-value.
```java
System.print.out("Version is " + app.version()); // prints out "Version is 0.1"
```
