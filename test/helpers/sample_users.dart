import 'package:itt632_lab_2025197599/models/user.dart';

Map<String, dynamic> sampleJson({int id = 1, String name = 'Aisha Rahman'}) => {
  'id': id,
  'name': name,
  'username': 'aisha',
  'email': 'aisha@example.com',
  'phone': '012-3456789',
  'website': 'aisha.example.com',
  'address': {
    'street': 'Jalan Ilmu',
    'suite': 'Unit 8',
    'city': 'Shah Alam',
    'zipcode': '40450',
    'geo': {'lat': '3.0738', 'lng': '101.5183'},
  },
  'company': {
    'name': 'Example Studio',
    'catchPhrase': 'Ideas made simple',
    'bs': 'create useful software',
  },
};

List<User> sampleUsers() => [
  User.fromJson(sampleJson()),
  User.fromJson(sampleJson(id: 2, name: 'Daniel Tan')),
];
