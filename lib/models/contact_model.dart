const String tableContact = 'table_contact';
const String tableContactColId = 'id';
const String tableContactColName = 'name';
const String tableContactColEmail = 'email';
const String tableContactColImage = 'image';
const String tableContactColMobile = 'mobile';
const String tableContactColWebsite = 'website';
const String tableContactColAddress = 'address';
const String tableContactColCompany = 'company';
const String tableContactColIsFavorite = 'favorite';
const String tableContactColDesignation = 'designation';

class ContactModel {
  int id;
  String name;
  String email;
  String image;
  String mobile;
  String website;
  String company;
  String address;
  bool isFavorite;
  String designation;

  ContactModel({
    this.id = -1,
    this.image = '',
    this.email = '',
    this.address = '',
    this.website = '',
    this.company = '',
    this.designation = '',
    required this.name,
    required this.mobile,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      tableContactColName: name,
      tableContactColEmail: email,
      tableContactColMobile: mobile,
      tableContactColImage: image,
      tableContactColAddress: address,
      tableContactColWebsite: website,
      tableContactColCompany: company,
      tableContactColDesignation: designation,
      tableContactColIsFavorite: isFavorite ? 1 : 0,
    };
    if (id > 0) {
      map[tableContactColId] = id;
    }
    return map;
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) => ContactModel(
        id: map[tableContactColId] ?? '',
        name: map[tableContactColName] ?? '',
        email: map[tableContactColEmail] ?? '',
        image: map[tableContactColImage] ?? '',
        mobile: map[tableContactColMobile] ?? '',
        address: map[tableContactColAddress] ?? '',
        company: map[tableContactColCompany] ?? '',
        website: map[tableContactColWebsite] ?? '',
        designation: map[tableContactColDesignation] ?? '',
        isFavorite: map[tableContactColIsFavorite] == 1 ? true : false,
      );
}
