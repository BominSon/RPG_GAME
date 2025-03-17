// 4_RPG_GAME_monster.dart
import 'dart:math';
import '3_RPG_GAME_character.dart';

class Monster {
  final String name;
  int health;
  int attack = 0; // 초기값 설정 (생성자에서 다시 할당됨)
  int defense = 0; // 몬스터의 방어력은 0으로 초기화
  int turnCount = 0; // 도전 기능 3 - 방어력 증가 기능을 위한 턴 카운터

  Monster(this.name, this.health, int maxAttack, int characterDefense) {
    // 공격력은 캐릭터의 방어력보다 작을 수 없음
    // 랜덤 값과 캐릭터 방어력 중 최대값으로 설정
    final random = Random();
    int randomAttack = random.nextInt(maxAttack) + 1; // 1부터 maxAttack까지
    attack = max(randomAttack, characterDefense);
  }

  void attackCharacter(Character character) {
    // 캐릭터에게 데미지를 입힘
    int damage = attack - character.defense;
    // 데미지는 최소 0
    damage = damage < 0 ? 0 : damage;

    character.health -= damage;

    print('\n$name이(가) ${character.name}에게 $damage의 데미지를 입혔습니다!');

    // 캐릭터가 방어 자세를 취했다면 체력 회복 (문제 지시에 따름)
    if (character.health <= 0) {
      character.health = 0;
      print('${character.name}이(가) 쓰러졌습니다!');
    }

    // 도전 기능 3 - 3턴마다 방어력 증가
    turnCount++;
    if (turnCount % 3 == 0) {
      defense += 2;
      print('$name의 방어력이 증가했습니다! 현재 방어력: $defense');
    }
  }

  void showStatus() {
    print('\n--- $name의 상태 ---');
    print('체력: $health');
    print('공격력: $attack');
    print('방어력: $defense');
    print('------------------');
  }
}
