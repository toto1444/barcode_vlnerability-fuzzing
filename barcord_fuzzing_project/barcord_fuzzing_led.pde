/*
 Flashing LED Barcode Fuzzing ver 0.330.8
 by
 An AhHyeon

 Inspired by my orange board and team crew "Park Bumjun"
 Thanks to Professor Lee. for some tips on idea

 This code will maybe not work if your barcode scanner is optical,
 only pens and laser barcode readers should work.

 You may have to playing with the timing (delay base).
 */

const int ledPin =  13;      // LED 꽂혀있는 핀번호
// 변수 변경:
int delaybase = 25;
//100 펜리더는 100이 가장 좋은것 같은데?
//20 은 코드 39랑 레이저 리더에 좋음.

#define STR_LENGTH 500 //500 should give us 100 Code 128 characters and 50 Code 39
char BarcodeBuf[STR_LENGTH]="";
//char RevBarcodeBuf[STR_LENGTH]="";

//All Code 39 symbols buffered by 1 so we end on a white space.
char* code39bars[]={
  "1113313111", "3113111131", "1133111131", "3133111111", "1113311131", "3113311111", "1133311111",
  "1113113131", "3113113111", "1133113111", "3111131131", "1131131131", "3131131111", "1111331131",
  "3111331111", "1131331111", "1111133131", "3111133111", "1131133111", "1111333111", "3111111331",
  "1131111331", "3131111311", "1111311331", "3111311311", "1131311311", "1111113331", "3111113311",
  "1131113311", "1111313311", "3311111131", "1331111131", "3331111111", "1311311131", "3311311111",
  "1331311111", "1311113131", "3311113111", "1331113111", "1313131111", "1313111311", "1311131311",
  "1113131311", "1311313111" };

char* code128bars[]={
  "212222", "222122", "222221", "121223", "121322", "131222", "122213", "122312", "132212",
  "221213", "221312", "231212", "112232", "122132", "122231", "113222", "123122", "123221",
  "223211", "221132", "221231", "213212", "223112", "312131", "311222", "321122", "321221",
  "312212", "322112", "322211", "212123", "212321", "232121", "111323", "131123", "131321",
  "112313", "132113", "132311", "211313", "231113", "231311", "112133", "112331", "132131",
  "113123", "113321", "133121", "313121", "211331", "231131", "213113", "213311", "213131",
  "311123", "311321", "331121", "312113", "312311", "332111", "314111", "221411", "431111",
  "111224", "111422", "121124", "121421", "141122", "141221", "112214", "112412", "122114",
  "122411", "142112", "142211", "241211", "221114", "413111", "241112", "134111", "111242",
  "121142", "121241", "114212", "124112", "124211", "411212", "421112", "421211", "212141",
  "214121", "412121", "111143", "111341", "131141", "114113", "114311", "411113", "411311",
  "113141", "114131", "311141", "411131", "211412", "211214", "211232", "2331112"};


void setup() {
  pinMode(ledPin, OUTPUT);
  for (int thispin=3; thispin <=10;thispin++){
    pinMode(thispin, INPUT_PULLUP); // Se them high by default
  }
}

void loop()
{

  if (!digitalRead(3)){ //Uber simple test sting
    SendUSingDIPChoice("abc123");
  }
  if (!digitalRead(4)){ //My old Shmoocon 2010 barcode
    SendUSingDIPChoice("e7e7f559-ce13-fd7f-baf0-9b4908dd1c73");
  }
  if (!digitalRead(5)){ //Simple XSS attack, who sanitizes barcode input?
    SendUSingDIPChoice("<script>alert(\"AhHyeon Was Here\")</script>");
  }
  if (!digitalRead(6)){ //Simle SQL Injection attack via barcode
    SendUSingDIPChoice("' or 1=1 -- ");
  }
  if (!digitalRead(7)){//The EICAR test string, to see if AV freaks out
    SendUSingDIPChoice("X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*");
  }
  if (!digitalRead(8)){
    Code128StringSend("TRY TO PASTE v",103); //v in 128a should be a Ctrl+V
  }
  if (!digitalRead(9)){//Send some odd stuff, see what key press it is interpreted as
    int points[]={
      64,65,66,67,68,69,70,71,72,73,74,75,75,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95        };
    Code128IntArrSend(points,  103,  31);
  }

  //Uncomment code below to try alternating timings
  /*
 char buf[6];
   Code128StringSend(strcat(TestString, itoa(delaybase, buf, 10)));

   delaybase++;
   if (delaybase>1000){
   delaybase=1;
   }
   */
}
void SendUSingDIPChoice(char *SomeString) {
  if (!digitalRead(10)) { //Default to sending in Code 128b
    Code39StringSend(SomeString);
  }
  else {
    Code128StringSend(SomeString, 104); //104 means 128b, 103 is a, 105 is c
  }
}

//Based on stuff from http://www.codeguru.com/forum/showthread.php?t=303185
//not used yet
char* rev(char* str)
{
  int end= strlen(str)-1;
  int start = 0;
  while( start<end )
  {
    str[start] ^= str[end];
    str[end] ^=   str[start];
    str[start]^= str[end];
    ++start;
    --end;
  }
  return str;
}


int ASCIItoCode128Point(char Cvalue)// Converts the ASCII value to it's place in the Code 128 chart
{
  int Ivalue=(int)Cvalue;
  if  (Ivalue == 32){
    return 0;
  }
  if (Ivalue >= 33 && Ivalue <= 126){
    return Ivalue-32;
  }
  if (Ivalue >= 145){
    return Ivalue-50;
  }
  if (Ivalue <= 31){ //Not used yet, but will be needed for Code 128a
    return Ivalue+64;
  }

}

int ASCIItoCode39Point(char Cvalue)// Converts the ASCII value to it's place in the Code 39 chart
{
  int Ivalue=(int)Cvalue;
  if (Ivalue >= 48 && Ivalue <= 57){
    return Ivalue-48;
  }
  if (Ivalue >= 65 && Ivalue <= 90){
    return Ivalue-55;
  }
  if (Ivalue >= 97 && Ivalue <= 122){
    return Ivalue-87;
  }
  switch (Cvalue) {
  case '-':
    return 36;
    break;
  case '.':
    return 37;
    break;
  case ' ':
    return 38;
    break;
  case '$':
    return 39;
    break;
  case '/':
    return 40;
    break;
  case '+':
    return 41;
    break;
  case '%':
    return 42;
    break;
  case '*':
    return 43;
    break;
  }
}

void UpperCase(char *SomeString) //Not used since I changed the wat I do code 39
{
  int i;
  for (i = 0; SomeString[i]!='\0'; i++) {
    if  (SomeString[i] >= 97 && SomeString[i] <= 122){
      SomeString[i]=SomeString[i]-32;
    }
  }
}

void Code128StringSend(char *SomeString, int ver) //Send the string. Ver should be 103 for 128a, 104 for 128b and 105 for 128c
//Current code does not let you mix Code 128 versions
{
  int i;
  int CheckSum = Code128CheckSum(SomeString, ver); //104 means Code 128B
  BarcodeBuf[0] = '\0';
  //Turn on LED to read as white space
  digitalWrite(ledPin, LOW);
  delayMicroseconds(delaybase*100);

  strcat(BarcodeBuf, code128bars[ver]);//Code 128B start
  for (i = 0; SomeString[i]!='\0'; i++) {
    strcat(BarcodeBuf, code128bars[ASCIItoCode128Point(SomeString[i])]);
  }
  strcat(BarcodeBuf, code128bars[CheckSum]);  //Checksum
  strcat(BarcodeBuf, "2331112"); //Code 128 end
  FlashSeq(BarcodeBuf);
  //Serial.println(BarcodeBuf);
  //Turn on LED to read as white space
  digitalWrite(ledPin, LOW);
  delayMicroseconds(delaybase*25);

  FlashSeq(rev(BarcodeBuf)); //Playing it backard helps reliability
  //Turn on LED to read as white space
  digitalWrite(ledPin, LOW);
  delayMicroseconds(delaybase*100);
  //Serial.println(BarcodeBuf);
}

void Code128IntArrSend(int *SomeIntArr, int ver, int arsize) //Using this for some odd characters
//Send the string. Ver should be 103 for 128a, 104 for 128b and 105 for 128c
//Current code does not let you mix Code 128 versions
{
  int i;
  int CheckSum = Code128CheckSumInt(SomeIntArr, ver, arsize); //104 means Code 128B
  BarcodeBuf[0] = '\0';
  //Turn on LED to read as white space
  digitalWrite(ledPin, LOW);
  delayMicroseconds(delaybase*100);

  strcat(BarcodeBuf, code128bars[ver]);//Code 128B start
  for (i = 0; i<arsize; i++) {
    strcat(BarcodeBuf, code128bars[SomeIntArr[i]]);
  }
  strcat(BarcodeBuf, code128bars[CheckSum]);  //Checksum
  strcat(BarcodeBuf, "2331112"); //Code 128 end
  FlashSeq(BarcodeBuf);

  //Serial.println(BarcodeBuf);
  //Turn on LED to read as white space
  digitalWrite(ledPin, LOW);
  delayMicroseconds(delaybase*25);

  FlashSeq(rev(BarcodeBuf)); //Playing it backard helps reliability
  //Turn on LED to read as white space
  digitalWrite(ledPin, LOW);
  delayMicroseconds(delaybase*100);
  //Serial.println(BarcodeBuf);
}

int Code128CheckSum(char *SomeString, int variant)
{
  int i;
  long PointSum=variant;
  for (i = 0; SomeString[i]!='\0'; i++) {
    PointSum = PointSum + ((i+1)*ASCIItoCode128Point(SomeString[i]));
  }
  return PointSum%103;
}

int Code128CheckSumInt(int *SomeIntArr, int variant, int arsize)
{
  int i;
  long PointSum=variant;
  for (i = 0;  i<arsize; i++) {
    PointSum = PointSum + ((i+1)*SomeIntArr[i]);
  }
  return PointSum%103;
}

void Code39StringSend(char *SomeString)
{
  int i;
  BarcodeBuf[0] = '\0';
  //Turn on LED to read as white space
  digitalWrite(ledPin, LOW);
  delayMicroseconds(delaybase*100);

  strcat(BarcodeBuf, "1311313111");//Code 39 start
  for (i = 0; SomeString[i]!='\0'; i++) {
    strcat(BarcodeBuf, code39bars[ASCIItoCode39Point(SomeString[i])]);
  }
  strcat(BarcodeBuf, "1311313111"); //Code 39 end
  FlashSeq(BarcodeBuf);

  //Turn on LED to read as white space
  digitalWrite(ledPin, LOW);
  delayMicroseconds(delaybase*25);

  //Serial.println(BarcodeBuf);
  FlashSeq(rev(BarcodeBuf));//Playing it backard helps reliability

  //Turn on LED to read as white space
  digitalWrite(ledPin, LOW);
  delayMicroseconds(delaybase*100);
  //Serial.println(BarcodeBuf);
}

void FlashSeq(char* FlashMe)//I do the real work, and switch between black and white areas
{
  int i;
  int B = HIGH;
  for (i = 0; FlashMe[i] != '\0'; i++) {
    digitalWrite(ledPin, B);
    delayMicroseconds(delaybase*(((int)FlashMe[i])-48));
    B=!B;
  }

}
