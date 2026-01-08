enum UserRole { admin, customer, rider }

class AppUser {
  final String uid;
  final UserRole role;

  AppUser({required this.uid, required this.role});

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
      ),
    );
  }
}
