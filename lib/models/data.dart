class Data {
  final String id;
  final String name;
  final String url;
  final String email;
  final String password;
  final bool isLeaked;
  

  Data({required this.id,required this.name, required this.url,required this.email, required this.password,  required this.isLeaked});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      email: json['email'],
      password: json['password'],
      isLeaked: json['is_leaked']??false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'email': email,
      'password': password,
      'is_leaked': isLeaked,
      
    };
  }

  
}
