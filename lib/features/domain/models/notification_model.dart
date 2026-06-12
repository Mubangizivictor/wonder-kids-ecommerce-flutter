import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 4)
enum NotificationType {
  @HiveField(0)
  order,
  @HiveField(1)
  promotion,
  @HiveField(2)
  security,
  @HiveField(3)
  system,
}

@HiveType(typeId: 3)
class NotificationModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String subtitle;
  @HiveField(3)
  final String time;
  @HiveField(4)
  final int iconCodePoint;
  @HiveField(5)
  final String? iconFontFamily;
  @HiveField(6)
  final String? iconFontPackage;
  @HiveField(7)
  final bool isRead;
  @HiveField(8)
  final NotificationType type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.iconCodePoint,
    this.iconFontFamily,
    this.iconFontPackage,
    required this.isRead,
    required this.type,
  });

  IconData get icon => IconData(
        iconCodePoint,
        fontFamily: iconFontFamily,
        fontPackage: iconFontPackage,
      );

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      subtitle: subtitle,
      time: time,
      iconCodePoint: iconCodePoint,
      iconFontFamily: iconFontFamily,
      iconFontPackage: iconFontPackage,
      isRead: isRead ?? this.isRead,
      type: type,
    );
  }
}
