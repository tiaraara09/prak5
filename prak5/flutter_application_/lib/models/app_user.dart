class AppUser {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final String salt;
  final String nim;
  final String address;
  final String phone;
  final String major;

  const AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.salt,
    this.nim = '',
    this.address = '',
    this.phone = '',
    this.major = '',
  });

  factory AppUser.fromMap(Map<String, Object?> m) => AppUser(
        id: m['id'] as int?,
        name: m['name'] as String,
        email: m['email'] as String,
        passwordHash: m['password_hash'] as String,
        salt: m['salt'] as String,
        nim: (m['nim'] as String?) ?? '',
        address: (m['address'] as String?) ?? '',
        phone: (m['phone'] as String?) ?? '',
        major: (m['major'] as String?) ?? '',
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'password_hash': passwordHash,
        'salt': salt,
        'nim': nim,
        'address': address,
        'phone': phone,
        'major': major,
      };

  AppUser copyWith({String? name, String? nim, String? address, String? phone, String? major}) =>
      AppUser(
        id: id,
        name: name ?? this.name,
        email: email,
        passwordHash: passwordHash,
        salt: salt,
        nim: nim ?? this.nim,
        address: address ?? this.address,
        phone: phone ?? this.phone,
        major: major ?? this.major,
      );

  List<String> get _words =>
      name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();

  String get initials {
    final parts = _words;
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }

  String get firstName => _words.isEmpty ? name : _words.first;
}
