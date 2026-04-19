import 'dart:typed_data';
import 'dart:convert';

class Accounts {
  final int idUser;
  final String userName;
  final String? userDisplayName;
  final String? userFullName;
  final String? userEmail;
  final String userPhone;
  final String? userAddress;
  final DateTime? userBirthday;
  final String? userGender;
  final String? userRole;
  final bool userStatus;
  final Uint8List? userAvatar;
  final Uint8List? userBackground;
  final String? userPassword;
  final DateTime? userCreateDate;
  final DateTime? userLastLogin;
  final String? userDescription;
  final String? userSignature;
  final int timeUsing;
  final int userPoint;
  final double userBalance;

  Accounts({
    required this.idUser,
    required this.userName,
    required this.userDisplayName,
    this.userFullName,
    this.userEmail,
    required this.userPhone,
    this.userAddress,
    this.userBirthday,
    this.userGender,
    this.userRole,
    required this.userStatus,
    this.userAvatar,
    this.userBackground,
    this.userPassword,
    this.userCreateDate,
    this.userLastLogin,
    this.userDescription,
    this.userSignature,
    required this.timeUsing,
    required this.userPoint,
    required this.userBalance
  });

  factory Accounts.fromJson(Map<String, dynamic> json) {
    return Accounts(
      idUser: json['userID'] ?? 0,
      userName: json['userName'] ?? '',
      userDisplayName: (json['userDisplayName'] as String?)?.isNotEmpty == true
          ? json['userDisplayName']
          : null,
      userFullName: json['userFullName'],
      userEmail: json['userEmail'],
      userPhone: json['userPhone'],
      userAddress: json['userAddress'],
      userBirthday: json['userBirthday'] != null
          ? DateTime.tryParse(json['userBirthday'])
          : null,
      userGender: json['userGender'],
      userRole: json['userRole'],
      userStatus: json['userStatus'] ?? false,
      userAvatar: json['userAvatar'] != null
          ? base64Decode(json['userAvatar'])
          : null,
      userBackground: json['userBackground'] != null
          ? base64Decode(json['userBackground'])
          : null,
      userPassword: json['userPassword'],
      userCreateDate: json['userCreateDate'] != null
          ? DateTime.tryParse(json['userCreateDate'])
          : null,
      userLastLogin: json['userLastLogin'] != null
          ? DateTime.tryParse(json['userLastLogin'].toString())
          : null,
      userDescription: json['userDescription'],
      userSignature: json['userSignature'] ?? "",
      timeUsing: int.tryParse(json['timeUsing']?.toString() ?? '0') ?? 0,
      userPoint: int.tryParse(json['userPoint']?.toString() ?? '0') ?? 0,
      userBalance: json['userBalance'] != null
          ? double.tryParse(json['userBalance'].toString()) ?? 0.0
          : 0.0,
    );
  }
  String get displayOrUserName => userDisplayName?.isNotEmpty == true ? userDisplayName! : userName;
}
