class RobotConfig {
  final String head;
  final String eyes;
  final String mouth;
  final String body;
  final String arms;
  final String legs;
  final String accessory;
  final String pattern;
  final String color;
  final String? skinImage;

  const RobotConfig({
    this.head = 'round',
    this.eyes = 'round',
    this.mouth = 'smile',
    this.body = 'box',
    this.arms = 'normal',
    this.legs = 'normal',
    this.accessory = 'none',
    this.pattern = 'none',
    this.color = 'blue',
    this.skinImage,
  });

  factory RobotConfig.fromMap(Map<String, dynamic> map) {
    return RobotConfig(
      head: map['head'] ?? 'round',
      eyes: map['eyes'] ?? 'round',
      mouth: map['mouth'] ?? 'smile',
      body: map['body'] ?? 'box',
      arms: map['arms'] ?? 'normal',
      legs: map['legs'] ?? 'normal',
      accessory: map['accessory'] ?? 'none',
      pattern: map['pattern'] ?? 'none',
      color: map['color'] ?? 'blue',
      skinImage: map['skinImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'head': head,
      'eyes': eyes,
      'mouth': mouth,
      'body': body,
      'arms': arms,
      'legs': legs,
      'accessory': accessory,
      'pattern': pattern,
      'color': color,
      if (skinImage != null) 'skinImage': skinImage,
    };
  }

  RobotConfig copyWith({
    String? head,
    String? eyes,
    String? mouth,
    String? body,
    String? arms,
    String? legs,
    String? accessory,
    String? pattern,
    String? color,
    String? skinImage,
  }) {
    return RobotConfig(
      head: head ?? this.head,
      eyes: eyes ?? this.eyes,
      mouth: mouth ?? this.mouth,
      body: body ?? this.body,
      arms: arms ?? this.arms,
      legs: legs ?? this.legs,
      accessory: accessory ?? this.accessory,
      pattern: pattern ?? this.pattern,
      color: color ?? this.color,
      skinImage: skinImage ?? this.skinImage,
    );
  }
}
