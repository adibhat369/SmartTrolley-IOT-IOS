// define ultrasonic sensor pins numbers
const int trigPin = 2;
const int echoPin = 3;
// define led pin number
const int led = 7;
// defines variables
long duration;
int distance;
void setup() {
pinMode(trigPin, OUTPUT); // Sets the trigPin as an Output
pinMode(echoPin, INPUT);
pinMode(led, OUTPUT);// Sets the echoPin as an Input
Serial.begin(9600); // Starts the serial communication
}
void loop() {
// Clears the trigPin
digitalWrite(trigPin, LOW);
delayMicroseconds(2);
// Sets the trigPin on HIGH state for 10 micro seconds
digitalWrite(trigPin, HIGH);
delayMicroseconds(10);
digitalWrite(trigPin, LOW);
// Reads the echoPin, returns the sound wave travel time in microseconds
duration = pulseIn(echoPin, HIGH);
// Calculating the distance in cm

// Speed of light assumed at 340m/s and dividing by 2 as we the time includes both forward and reflected path
distance= duration*0.034/2;

//If distance is above 30 cm
if((distance <= 30))
{
  digitalWrite(led, HIGH);
}
else if(distance>30) 
{
  digitalWrite(led, LOW);
}


// Prints the distance on the Serial Monitor
Serial.print("Distance: ");
Serial.println(distance);
}
