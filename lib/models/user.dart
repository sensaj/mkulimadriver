class User {
  String? id;
  String? name;
  String? licence;
  String? phone;
  String? plateNo;
  String? truck;

  User(
      {this.id, this.phone, this.licence, this.plateNo, this.truck, this.name});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['user_id'],
      phone: map['phone'],
      licence: map['licence'],
      plateNo: map['plate_no'],
      truck: map['truck'],
      name: map['name'],
    );
  }
}
