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
//100 펜리더는 100이 가장 좋은것 같은데?
//20 은 코드 39랑 레이저 리더에 좋음.


#define STR_LENGTH 500 //500 should give us 100 Code 128 characters and 50 Code 39
char BarcodeBuf[STR_LENGTH]="";
//char RevBarcodeBuf[STR_LENGTH]="";

//모든 코드 39는 1을 공백으로 하는듯
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
