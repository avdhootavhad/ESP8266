include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>

#ifndef STASSID
#define STASSID "darkmatter"
#define STAPSK  "darkmatter"
#endif    Hello from darkmatter!!

const char *ssid = STASSID;
const char *password = STAPSK;

ESP8266WebServer server(80);


// TEMP DETECTION
const int led = 13;
int val;
float cel;
float tempin = A0;

// GAS DETECTION
int smoke = 16;
int buzzer = 15 ;
int MQ;

//IR
int IR = 5;
int count;

//ULTRASONIC
const int trigPin = 0;
const int echoPin = 4;
int led1 = 2;

long  duration;
float distance;
//TEMP
void handleRoot() {
  digitalWrite(led, 1);
  char temp[400];
  snprintf(temp, 400,

           "<html>\
  <head>\
    <meta http-equiv='refresh' content='2'/>\
    <title>ESP8266 Demo</title>\
    <style>\
      body { background-color: #cccccc; font-family: Arial, Helvetica, Sans-Serif; Color: #000088; }\
    </style>\
  </head>\
  <body>\
    <h1>Temperature is: %02f</h1>\
    <h2>Gas Status:%02d </h2>\
    <h3>No. Of People = %02d</h3>\
    <h4>Distance : %02f </h4>\
           </body>\
  </html>",

           cel, MQ, count, distance
          );
  server.send(200, "text/html", temp);
  digitalWrite(led, 0);
}


void handleNotFound() {
  digitalWrite(led, 1);
  String message = "File Not Found\n\n";
  message += "URI: ";
  message += server.uri();
  message += "\nMethod: ";
  message += (server.method() == HTTP_GET) ? "GET" : "POST";
  message += "\nArguments: ";
  message += server.args();
  message += "\n";

  for (uint8_t i = 0; i < server.args(); i++) {
    message += " " + server.argName(i) + ": " + server.arg(i) + "\n";
  }

  server.send(404, "text/plain", message);
  digitalWrite(led, 0);
}

void setup(void) {
  pinMode(led, OUTPUT);
  digitalWrite(led, 0);
  Serial.begin(115200);
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  Serial.println("");

  pinMode (tempin, INPUT);       //NEW

  // GAS DETECTION
  pinMode (smoke, INPUT);
  pinMode (buzzer, OUTPUT);

  //IR
  pinMode(IR, INPUT);

  //ULTRASONIC

  pinMode (trigPin, OUTPUT);
  pinMode (echoPin, INPUT);

  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
Serial.println("");
  Serial.print("Connected to ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  if (MDNS.begin("esp8266")) {
    Serial.println("MDNS responder started");
  }

  server.on("/", handleRoot);

  server.onNotFound(handleNotFound);
  server.begin();
  Serial.println("HTTP server started");
}

void loop(void) {
  server.handleClient();
  MDNS.update();

  val = analogRead (A0);

  float mv = (val / 1024.0) * 3300;
  cel = mv / 10;
  Serial.print("TEMPRATURE = ");
  Serial.print(cel);
  Serial.print("*c");
  Serial.println();
  delay(1000);
  server.on("/", handleRoot);


  // GAS DETECTION
  MQ = digitalRead (smoke);
  Serial.println(MQ);
  if (MQ = HIGH)
  {
    digitalWrite ( buzzer, HIGH);
  }
  else
  {
    digitalWrite ( buzzer, LOW);
  }
  server.on("/", handleRoot);

  //IR

  int People = digitalRead(IR);
  Serial.println(People);
  if (People == 0)
  {
    count = count + 1;
    Serial.print("No. of people =");
    Serial.println (count);

  }
  server.on("/", handleRoot);

  //ULTRASONIC

  digitalWrite (trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite (trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite (trigPin, LOW);

  duration = pulseIn(echoPin, HIGH);



  // Calculation the distance
  distance = duration*0.034 / 2;

  Serial.print ("Distance :  " + String(distance));
  Serial.println (" cm");
  server.on("/", handleRoot);
}
