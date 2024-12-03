import 'dart:math';

class Generatealphanumeric {

static generateAlphanumeric(int length) {
  const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final Random random = Random();
  
  return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
}

}