int button1 = 4;
int button2 = 5;
int button3 = 6;
int button4 = 7;

int v1, v2, v3, v4;

int delayValue = 1000;

void setup() {
  // put your setup code here, to run once:
  pinMode(button1, INPUT);
  pinMode(button2, INPUT);
  pinMode(button3, INPUT);
  pinMode(button4, INPUT);

  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  v1 = digitalRead(button1);
  v2 = digitalRead(button2);
  v3 = digitalRead(button3);
  v4 = digitalRead(button4);

  if (v1 == HIGH) {
    Serial.print(1);
    delay(delayValue);
  } else if (v2 == HIGH) {
    Serial.print(2);
    delay(delayValue);
  } else if (v3 == HIGH) {
    Serial.print(3);
    delay(delayValue);
  } else if (v4 == HIGH) {
    Serial.print(4);
    delay(delayValue);
  }
  
}
