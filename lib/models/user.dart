class User {
  final String phoneNumber;
  final String name;
  final bool isAdmin;
  final String? authToken;

  User({
    required this.phoneNumber,
    this.name = '',
    this.isAdmin = false,
    this.authToken,
  });

  // For demo purposes - hardcoded users
  static final List<User> demoUsers = [
    User(
      phoneNumber: '1234567890',
      name: 'Admin User',
      isAdmin: true,
      authToken: 'dummy_token_1',
    ),
    User(
      phoneNumber: '2345678901',
      name: 'Regular User',
      isAdmin: false,
      authToken: 'dummy_token_2',
    ),
  ];

  // Find user by phone number
  static User? findByPhone(String phoneNumber) {
    try {
      return demoUsers.firstWhere(
        (user) => user.phoneNumber == phoneNumber,
      );
    } catch (e) {
      return null;
    }
  }
}
