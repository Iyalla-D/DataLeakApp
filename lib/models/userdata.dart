class UserData {
  final String email;
  final String password;

  UserData(this.email, this.password);

  // Converts a UserData into a Map
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };

  // Creates a UserData from a Map
  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    json['email'],
    json['password'],
  );
}
