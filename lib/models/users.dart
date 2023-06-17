class Users {
  final String username;
  final String password;

  Users({
    required this.username,
    required this.password,
  });

  // 'Expense' to 'Map'
  Map<String, dynamic> toMap() => {
        // id will generate automatically
        'username': username,
        'passowrd': password,
      };

  // 'Map' to 'Expense'
  factory Users.fromString(Map<String, dynamic> value) => Users(
        username: value['username'],
        password: value['password'],
      );
}
