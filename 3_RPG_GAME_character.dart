// 3_RPG_GAME_character.dart
import '4_RPG_GAME_monster.dart';

class Character {
  final String name;
  int health;
  final int attack;
  final int defense;
  bool hasUsedItem = false; // 도전 기능 2 - 아이템 사용 여부

  Character(this.name, this.health, this.attack, this.defense);

  void attackMonster(Monster monster) {
    // 몬스터에게 데미지를 입힘
    int damage = attack - monster.defense;
    // 데미지는 최소 0
    damage = damage < 0 ? 0 : damage;
    
    monster.health -= damage;
    
    print('\n$name이(가) ${monster.name}에게 $damage의 데미지를 입혔습니다!');
    
    // 몬스터의 체력이 0 이하가 되면 처치 메시지 출력
    if (monster.health <= 0) {
      monster.health = 0;
      print('${monster.name}을(를) 처치했습니다!');
    }
  }

  void defend() {
    // 방어 시, 방어 메시지 출력
    print('\n$name이(가) 방어 자세를 취했습니다.');
  }

  void showStatus() {
    print('\n--- $name의 상태 ---');
    print('체력: $health');
    print('공격력: $attack');
    print('방어력: $defense');
    print('------------------');
  }
  
  // 도전 기능 2 - 아이템 사용 메서드
  bool useItem() {
    if (hasUsedItem) {
      print('\n이미 아이템을 사용했습니다!');
      return false;
    } else {
      hasUsedItem = true;
      print('\n$name이(가) 특수 아이템을 사용했습니다! 이번 턴 공격력이 두 배가 됩니다!');
      return true;
    }
  }
}