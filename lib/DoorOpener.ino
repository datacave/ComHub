/* Web_Demo.pde -- sample code for Webduino server library */

/*
 * To use this demo,	enter one of the following USLs into your browser.
 * Replace "host" with the IP address assigned to the Arduino.
 *
 * http://host/
 * http://host/json
 *
 * This URL brings up a display of the values READ on digital pins 0-9
 * and analog pins 0-5.	This is done with a call to defaultCmd.
 * 
 * 
 * http://host/form
 *
 * This URL also brings up a display of the values READ on digital pins 0-9
 * and analog pins 0-5.	But it's done as a form,	by the "formCmd" function,
 * and the digital pins are shown as radio buttons you can change.
 * When you click the "Submit" button,	it does a POST that sets the
 * digital pins,	re-reads them,	and re-displays the form.
 * 
 */

#include "SPI.h"
#include "Ethernet.h"
#include "WebServer.h"

// no-cost stream operator as described at 
// http://sundial.org/arduino/?page_id=119
template<class T>
inline Print &operator <<(Print &obj, T arg)
{ obj.print(arg); return obj; }

// CHANGE THIS TO YOUR OWN UNIQUE VALUE
//static uint8_t mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
static uint8_t mac[] = { 0x90, 0xA2, 0xDA, 0x00, 0xFD, 0x77 };
// Not necessary now that DHCP support is patched
static uint8_t ip[] = { 10, 1, 11, 30 };	 
static uint8_t gateway[] = { 10, 1, 11, 33 };
static uint8_t netmask[] = { 255, 255, 255, 0 };

int signal = 0;

#define PREFIX ""

WebServer webserver(PREFIX, 80);

// commands are functions that get called by the webserver framework
// they can read any posted data from client, and they output to server

void jsonCmd(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
	if (type == WebServer::POST)
	{
		server.httpFail();
		return;
	}

	//server.httpSuccess(false, "application/json");
	server.httpSuccess("application/json");
	
	if (type == WebServer::HEAD)
		return;

	int i;		
	server << "{ ";
	for (i = 0; i <= 9; ++i)
	{
		// ignore the pins we use to talk to the Ethernet chip
		int val = digitalRead(i);
		server << "\"d" << i << "\": " << val << ", ";
	}

	for (i = 0; i <= 5; ++i)
	{
		int val = analogRead(i);
		server << "\"a" << i << "\": " << val;
		if (i != 5)
			server << ", ";
	}
	
	server << " }";
}


void outputPins(WebServer &server, WebServer::ConnectionType type, bool addControls = false)
{
  int val;
  P(htmlHead) =
    "<html>"
    "<head>"
    "<title>Arduino Web Server</title>"
    "<style type=\"text/css\">"
    "BODY { font-family: sans-serif }"
    "H1 { font-size: 14pt; text-decoration: underline }"
    "H2 { font-size: 16pt; text-decoration: underline }"
    "P  { font-size: 10pt; }"
    "</style>"
    "</head>"
    "<body>";

  int i;
  server.httpSuccess();
  server.printP(htmlHead);

  if (addControls)
    server << "<form action='" PREFIX "/form' method='post'>";
  server << "<h2>KTA-223 WebUi Demo</h1><p>";
  server << "<h1>Relays</h1><p>";

  for (i = 1; i <= 8; ++i)
  {
    // ignore the pins we use to talk to the Ethernet chip
    val = digitalRead(i+1);
    server << "Relay " << i << ": ";
    if (addControls)
    {
      char pinName[4];
      pinName[0] = 'R';
      itoa(i, pinName + 1, 10);
      server.radioButton(pinName, "1", "On", val);
      server << " ";
      server.radioButton(pinName, "0", "Off", !val);
    }
    else
      server << (val ? "ON" : "OFF");

    server << "<br/>";
  }

  server << "</p><h1>Opto-Ins</h1><p>";
  for (i = 1; i <= 4; ++i)
  {
    val = digitalRead(i+14);
    server << "Opto-In " << i << ": ";
    if (val==1) server << "OFF <br/>";
    else server << "ON <br/>";
  }
  
  server << "</p><h1>Analogs</h1><p>";
  for (i = 1; i <= 3; ++i)
  {
    
    if (i==1) val = analogRead(6);
    if (i==2) val = analogRead(7);
    if (i==3) val = analogRead(0);
    server << "Analog " << i << ": " << val << "<br/>";
  }
  server << "</p>";

  if (addControls)
    server << "<input type='submit' value='Submit / Refresh'/></form>";

  server << "</body></html>";
}

void formCmd(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
  if (type == WebServer::POST)
  {
    bool repeat;
    char name[16], value[16];
    do
    {
      repeat = server.readPOSTparam(name, 16, value, 16);
      if (name[0] == 'R')
      {
        int pin = strtoul(name + 1, NULL, 10);
        int val = strtoul(value, NULL, 10);
        digitalWrite(pin+1, val);
      }
    } while (repeat);

    server.httpSeeOther(PREFIX "/form");
  }
  else
    outputPins(server, type, true);
}

void defaultCmd(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
  outputPins(server, type, false);  
}

void openDoor(int n)
{
	Serial.print("Trying to open door ");
	Serial.print(n);
	Serial.println(".");
	digitalWrite(2 + n, HIGH);
	delay(3000);
	digitalWrite(2 + n, LOW);
}

// There's got to be a way to do a /open?door=1 or a /open/1, but I'll look into later
void open1Cmd(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
	Serial.println("Got a request from the web");
	openDoor(0);
	server.httpSeeOther(PREFIX "/form");
}

void open2Cmd(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
	Serial.println("Got a request from the web");
	openDoor(1);
	server.httpSeeOther(PREFIX "/form");
}

void open3Cmd(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
	Serial.println("Got a request from the web");
	openDoor(2);
	server.httpSeeOther(PREFIX "/form");
}

void open4Cmd(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
	Serial.println("Got a request from the web");
	openDoor(3);
	server.httpSeeOther(PREFIX "/form");
}

void setup()
{

  for (int i = 0; i < 8; i++) {
    pinMode(i + 2, OUTPUT);
  }  
  for (int i = 0; i < 4; i++) {
    pinMode(i + 15, INPUT);
  } 

	// If using DHCP:
	//Ethernet.begin(mac);
	Ethernet.begin(mac, ip, netmask, gateway);
	webserver.begin();

	Serial.begin(9600);
	Serial.print("Ready on IP address ");
	Serial.print(Ethernet.localIP());
	Serial.println(".");

	webserver.setDefaultCommand(&defaultCmd);
	webserver.addCommand("json", &jsonCmd);
	webserver.addCommand("form", &formCmd);
	webserver.addCommand("open1", &open1Cmd);
	webserver.addCommand("open2", &open2Cmd);
	webserver.addCommand("open3", &open3Cmd);
	webserver.addCommand("open4", &open4Cmd);
}

void loop()
{
	// process incoming connections one at a time forever
	webserver.processConnection();

  for (int p = 0; p < 4; p++) {
    signal = digitalRead(p + 15);
		// The logic is flipped on a Relayduino: 0 is "on"
		if (signal == 0) {
			Serial.print("Got a request to open door ");
		 	Serial.print(p);
		 	Serial.println(".");
			openDoor(p);
		}
  }

	// if you wanted to do other work based on a connecton, it would go here
}
