class User {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.company,
  });

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final Address address;
  final Company company;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      website: json['website'] as String,
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      company: Company.fromJson(json['company'] as Map<String, dynamic>),
    );
  }

  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.first.isEmpty) return '?';
    return '${words.first[0]}${words.length > 1 ? words.last[0] : ''}'
        .toUpperCase();
  }
}

class Address {
  const Address({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
  });

  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final Geo geo;

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] as String,
      suite: json['suite'] as String,
      city: json['city'] as String,
      zipcode: json['zipcode'] as String,
      geo: Geo.fromJson(json['geo'] as Map<String, dynamic>),
    );
  }

  String get fullAddress => '$suite, $street\n$city, $zipcode';
}

class Geo {
  const Geo({required this.latitude, required this.longitude});

  final String latitude;
  final String longitude;

  factory Geo.fromJson(Map<String, dynamic> json) =>
      Geo(latitude: json['lat'] as String, longitude: json['lng'] as String);
}

class Company {
  const Company({
    required this.name,
    required this.catchPhrase,
    required this.business,
  });

  final String name;
  final String catchPhrase;
  final String business;

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    name: json['name'] as String,
    catchPhrase: json['catchPhrase'] as String,
    business: json['bs'] as String,
  );
}
