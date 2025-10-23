class Patient {
  int? id;
  String name;
  String birthdate; // ISO string
  int age;
  String sex;
  String residency;
  String mobile;
  String? note;

  Patient({this.id, required this.name, required this.birthdate, required this.age, required this.sex, required this.residency, required this.mobile, this.note});

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'birthdate': birthdate,
      'age': age,
      'sex': sex,
      'residency': residency,
      'mobile': mobile,
      'note': note,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> m) {
    return Patient(
      id: m['id'] is int ? m['id'] as int : int.tryParse('${m['id']}'),
      name: m['name'] ?? '',
      birthdate: m['birthdate'] ?? '',
      age: m['age'] is int ? m['age'] as int : int.tryParse('${m['age']}') ?? 0,
      sex: m['sex'] ?? '',
      residency: m['residency'] ?? '',
      mobile: m['mobile'] ?? '',
      note: m['note'],
    );
  }
}
