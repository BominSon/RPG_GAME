// 1_RPG_GAME_main.dart
import '2_RPG_GAME_game.dart';

void main() {
  print('전투 RPG 게임에 오신 것을 환영합니다!');
  
  // 게임 인스턴스 생성 및 시작
  Game game = Game();
  game.startGame();
}