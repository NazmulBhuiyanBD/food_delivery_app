enum UserRole { admin, customer, rider, owner }

enum UserStatus { pending, approved, rejected }

class AppUser {
  final String uid;
  final UserRole role;
  final UserStatus status;

  AppUser({
    required this.uid,
    required this.role,
    this.status = UserStatus.approved,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.customer,
      ),
      status: data.containsKey('status')
          ? UserStatus.values.firstWhere(
              (e) => e.name == data['status'],
              orElse: () => UserStatus.pending,
            )
          : UserStatus.approved,
    );
  }
}
