class UserData {
  final String id;
  final String email;
  final String password;

  UserData(this.id,this.email, this.password);

  // Converts a UserData into a Map
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'password': password,
  };

  // Creates a UserData from a Map
  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    json['id'],
    json['email'],
    json['password'],
  );
}
