//Initialise Variables
var firebase = require("firebase");
var lat;
var lon;
var initialLat;
var initialLong;
var radius;
var macAddress;
var macAd = require('macaddress');
macAd.one(function(err,mac){
	macAddress = mac;
});
console.log(macAddress);

// Initialize Firebase
var config = {
    apiKey: "Insert API Key here",
    authDomain: "trolleybotpifirebase.firebaseapp.com",
    databaseURL: "https://trolleybotpifirebase.firebaseio.com",
    projectId: "trolleybotpifirebase",
    storageBucket: "trolleybotpifirebase.appspot.com",
    messagingSenderId: "550535484202"
  };
var firebaseDatabase;
var databaseRef;
firebase.initializeApp(config);
firebase.auth().signInWithEmailAndPassword("n.adithyabhat@rocketmail.com", "Assignment3")
 .catch(function(error) {
 console.log("FIREBASE AUTH ERROR:");
 console.log(error.code);
 console.log(error.message);
 }).then
(function(){
 console.log("Firebase Connected");
 firebaseDatabase = firebase.database();
 databaseRef = firebaseDatabase.ref("TrolleyBotStores").child("ColesCaulfield")
 readFirebaseData()
setInterval(function() { getLocation() }, 5000);
});

//Setup listener for firebase data
function readFirebaseData() {
databaseRef.child("PersonalDetails").on('value', function(snapshot) {
   snapshot.forEach(function(childSnapshot) {
	//console.log(childSnapshot.key);
	if(childSnapshot.key == "InitialLatitude") {
	//console.log(childSnapshot.val());
	initialLat = childSnapshot.val(); }
	else if(childSnapshot.key == "InitialLongitude") {
	initialLong = childSnapshot.val(); }
	else if(childSnapshot.key == "Radius") {
	radius = childSnapshot.val(); }

   });
});

}
//Initialise LCD

function updateLCD(msg) {
var Lcd = require('lcd'),
  lcd = new Lcd({
    rs: 12,
    e: 21,
    data: [5, 6, 17, 18],
    cols: 8,
    rows: 2
  });
    
//Clear and print data on LCD
lcd.on('ready', function() {
        lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print(msg);
        setTimeout(function() {
  // code to be executed after 1 second
        lcd.clear();
}, 1000);
});
}

//Serial port to recieve GPS data
var file = '/dev/ttyS0';

const SerialPort = require('serialport');
const parsers = SerialPort.parsers;

/*
SerialPort.list(function (err, ports) {
  console.log(ports);
});
*/

const parser = new parsers.Readline({
  delimiter: '\r\n'
});
//Read from the port and send for parsing
const port = new SerialPort(file);

port.pipe(parser);


//Check if there is internet connection using DNS lookup
function checkInternet(cb) {
    require('dns').lookup('google.com',function(err) {
        if (err && err.code == "ENOTFOUND") {
            cb(false);
        } else {
            cb(true);
        }
    })
}

function getLocation() {
	//var initialLat = -37.877012;
	//var initialLong = 145.043688;
	//console.log("iniitiallat is" ,initialLat);	
	//console.log("initiallong is",initialLong);

	var alarm = false;
	var maxDistance = radius;
	//initialise buzzer
	var Gpio = require('onoff').Gpio,
    buzzer = new Gpio(27,'out');
	
	console.log("calling gps");

	var GPS = require('gps');
	var gps = new GPS;

	gps.on('data', function(data) {
		//When we have proper lat and long values
		if(data.lat && data.lon ) {
			lat = data.lat;
            lon = data.lon;
			//Get distance from the intial location set
			var distance = GPS.Distance(lat, lon, initialLat, initialLong);
			console.log("Distance is", distance);
			if(distance > maxDistance)
			{
				//Out of zone trolley
				alarm = true;
				buzzer.writeSync(1);
				updateLCD('NOT ALLOWED');
	
                var dateNtime = new Date().toISOString();
                console.log(dateNtime);
                //Send data to firebase only if internet connection is there
                checkInternet(function(isConnected) {
                if (isConnected) {
                // connected to the internet

                var newNode = databaseRef.child("trolleys").child(macAddress+"  Rpi 1").push();
 			    newNode.set({
		
                "time" : dateNtime,
                "lat" : lat,
                "long" : lon,
                "Alarm" : alarm

            });
 			console.log("Node added"); 
 			console.log("latitude is",data.lat);
			console.log("longitude is",data.lon);
			console.log("Time: ", data.time);
}
else {
	console.log("No internet connectivity - kindly verify");
}
});
	}
	} });
	// update function gives us the required parsed data
	parser.on('data', function(data) {
 	gps.update(data);
	});

}
