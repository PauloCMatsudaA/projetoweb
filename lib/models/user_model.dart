class UserModel {
  final String uid;
  final String name;
  final String email;
  final String city;
  final List<String> skillsOffered;
  final List<String> skillsWanted;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.city,
    required this.skillsOffered,
    required this.skillsWanted,
  });

  // Construtor para criar a partir de um documento do Firestore
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      city: map['city'] ?? '',
      skillsOffered: List<String>.from(map['skillsOffered'] ?? []),
      skillsWanted: List<String>.from(map['skillsWanted'] ?? []),
    );
  }

  // Converter para mapa para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'city': city,
      'skillsOffered': skillsOffered,
      'skillsWanted': skillsWanted,
    };
  }
}
