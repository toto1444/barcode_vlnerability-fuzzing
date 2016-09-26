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

