// 2_RPG_GAME_game.dart
import 'dart:io';
import 'dart:math';
import '3_RPG_GAME_character.dart';
import '4_RPG_GAME_monster.dart';

class Game {
  Character? character;
  List<Monster> monsters = [];
  int defeatedMonsters = 0;
  
  Game() {
    // 게임 초기화
    loadCharacterStats();
    loadMonsterStats();
    
    // 도전 기능 1 - 30% 확률로 보너스 체력 제공
    if (Random().nextDouble() < 0.3) {
      character!.health += 10;
      print('보너스 체력을 얻었습니다! 현재 체력: ${character!.health}');
    }
  }
  
  void loadCharacterStats() {
    try {
      final file = File('characters.txt');
      final contents = file.readAsStringSync();
      final stats = contents.split(',');
      
      if (stats.length != 3) throw FormatException('Invalid character data');
      
      int health = int.parse(stats[0]);
      int attack = int.parse(stats[1]);
      int defense = int.parse(stats[2]);
      
      String name = getCharacterName();
      character = Character(name, health, attack, defense);
      
    } catch (e) {
      print('캐릭터 데이터를 불러오는 데 실패했습니다: $e');
      exit(1);
    }
  }
  
  void loadMonsterStats() {
    try {
      final file = File('monsters.txt');
      final contents = file.readAsStringSync();
      final lines = contents.split('\n');
      
      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        
        final stats = line.split(',');
        if (stats.length != 3) throw FormatException('Invalid monster data: $line');
        
        String name = stats[0];
        int health = int.parse(stats[1]);
        int maxAttack = int.parse(stats[2]);
        
        // 캐릭터 방어력 전달
        monsters.add(Monster(name, health, maxAttack, character!.defense));
      }
      
      print('${monsters.length}마리의 몬스터를 불러왔습니다.');
      
    } catch (e) {
      print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
      exit(1);
    }
  }
  
  String getCharacterName() {
    String? name;
    final RegExp validNamePattern = RegExp(r'^[a-zA-Z가-힣]+$');
    
    while (name == null || name.isEmpty || !validNamePattern.hasMatch(name)) {
      print('캐릭터의 이름을 입력하세요 (한글, 영문 대소문자만 허용):');
      name = stdin.readLineSync();
      
      if (name == null || name.isEmpty) {
        print('이름은 비워둘 수 없습니다.');
      } else if (!validNamePattern.hasMatch(name)) {
        print('이름에는 한글, 영문 대소문자만 사용할 수 있습니다.');
      }
    }
    
    return name;
  }
  
  Monster getRandomMonster() {
    if (monsters.isEmpty) {
      throw Exception('더 이상 몬스터가 없습니다!');
    }
    
    final random = Random();
    int index = random.nextInt(monsters.length);
    return monsters[index];
  }
  
  void battle(Monster monster) {
    print('\n===== 전투 시작: ${character!.name} vs ${monster.name} =====');
    
    while (character!.health > 0 && monster.health > 0) {
      // 상태 표시
      character!.showStatus();
      monster.showStatus();
      
      // 사용자 행동 선택
      print('\n행동을 선택하세요:');
      print('1. 공격하기');
      print('2. 방어하기');
      
      // 도전 기능 2 - 아이템 사용 옵션 추가
      if (!character!.hasUsedItem) {
        print('3. 아이템 사용하기');
      }
      
      String? input = stdin.readLineSync();
      
      switch (input) {
        case '1': // 공격
          character!.attackMonster(monster);
          break;
        case '2': // 방어
          character!.defend();
          // 도전 기능 - 방어 시 몬스터가 입힌 데미지만큼 체력 회복
          int prevHealth = character!.health;
          monster.attackCharacter(character!);
          int damageReceived = prevHealth - character!.health;
          character!.health += damageReceived;
          print('${character!.name}이(가) 방어를 통해 $damageReceived만큼 체력을 회복했습니다!');
          continue; // 몬스터의 공격은 이미 처리했으므로 다음 턴으로
        case '3': // 아이템 사용
          if (!character!.hasUsedItem) {
            bool used = character!.useItem();
            if (used) {
              // 공격력 두 배로 일시적 증가 적용
              int originalAttack = character!.attack;
              int boostedAttack = originalAttack * 2;
              
              // 임시적으로 공격력 두 배 적용
              int damage = boostedAttack - monster.defense;
              damage = damage < 0 ? 0 : damage;
              
              monster.health -= damage;
              print('\n${character!.name}이(가) 강화된 공격으로 ${monster.name}에게 $damage의 데미지를 입혔습니다!');
              
              if (monster.health <= 0) {
                monster.health = 0;
                print('${monster.name}을(를) 처치했습니다!');
              }
            }
          } else {
            print('잘못된 입력입니다. 다시 선택하세요.');
            continue;
          }
          break;
        default:
          print('잘못된 입력입니다. 다시 선택하세요.');
          continue;
      }
      
      // 몬스터가 살아있으면 공격
      if (monster.health > 0) {
        monster.attackCharacter(character!);
      }
    }
    
    // 전투 결과 처리
    if (monster.health <= 0) {
      print('\n${monster.name}을(를) 물리쳤습니다!');
      defeatedMonsters++;
      // 몬스터 리스트에서 제거
      monsters.remove(monster);
    }
    
    print('===== 전투 종료 =====');
  }
  
  void startGame() {
    print('\n===== 게임 시작 =====');
    print('${character!.name}님, 당신은 몬스터 세계에 도착했습니다.');
    print('생존을 위해 몬스터들과 싸워야 합니다!');
    
    while (character!.health > 0 && !monsters.isEmpty) {
      try {
        Monster currentMonster = getRandomMonster();
        battle(currentMonster);
        
        // 캐릭터가 살아있고, 모든 몬스터를 물리치지 않았다면 다음 몬스터와 싸울지 선택
        if (character!.health > 0 && !monsters.isEmpty) {
          print('\n다음 몬스터와 대결하시겠습니까? (y/n)');
          String? input = stdin.readLineSync();
          
          if (input?.toLowerCase() != 'y') {
            print('게임을 종료합니다.');
            break;
          }
        }
      } catch (e) {
        print('오류 발생: $e');
        break;
      }
    }
    
    // 게임 결과 처리
    if (character!.health <= 0) {
      print('\n${character!.name}이(가) 쓰러졌습니다. 게임 오버!');
    } else if (monsters.isEmpty) {
      print('\n모든 몬스터를 물리쳤습니다! 승리!');
    }
    
    // 게임 결과 저장
    saveGameResult();
  }
  
  void saveGameResult() {
    print('\n결과를 저장하시겠습니까? (y/n)');
    String? input = stdin.readLineSync();
    
    if (input?.toLowerCase() == 'y') {
      try {
        final file = File('result.txt');
        String result = character!.health > 0 ? '승리' : '패배';
        String content = '캐릭터 이름: ${character!.name}, 남은 체력: ${character!.health}, 게임 결과: $result';
        
        file.writeAsStringSync(content);
        print('결과가 저장되었습니다: result.txt');
      } catch (e) {
        print('결과 저장 중 오류 발생: $e');
      }
    }
  }
}