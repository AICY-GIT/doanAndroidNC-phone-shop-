class Phone {
  final int phoneId;
  final int price;
  final String size;
  final double rating;
  final String batterycapacity;
  final String category;
  final String phoneName;
  final String color;
  final String imageURL;
  bool isFavorated;
  final String decription;
  bool isSelected;

  Phone(
      {required this.phoneId,
        required this.price,
        required this.category,
        required this.phoneName,
        required this.size,
        required this.color,
        required this.rating,
        required this.batterycapacity,
        required this.imageURL,
        required this.isFavorated,
        required this.decription,
        required this.isSelected});

  static List<Phone> phoneList = [
    Phone(
        phoneId: 0,
         price: 1398,
        category: 'Apple',
        phoneName: 'Iphone 15 Pro Max',
        size: '1TB',
        rating: 4.9,
        color: 'Green',
        batterycapacity: '4422 mAh',
        imageURL: 'assets/phoneimages/anh2.png',
        isFavorated: false,
        decription:
        'iPhone 15 Pro is the first iPhone to be designed from aerospace-grade titanium, the same alloy used in spacecraft design for trips to Mars..',
        isSelected: false),
   Phone(
        phoneId: 1,
         price: 999,
        category: 'Samsung',
        phoneName: 'SS Galaxy S23 Ultra',
        size: '256 GB',
        color: 'Black',
        rating: 4.5,
        batterycapacity: '5000 mAh',
        imageURL: 'assets/phoneimages/anh1.png',
        isFavorated: true,
        decription:
        'Samsung Galaxy S23 Ultra 5G 256GB is Samsung most advanced smartphone, possessing an unbelievable configuration with a huge chip optimized specifically for the Galaxy..',
        isSelected: false),
    Phone(
        phoneId: 2,
        price: 359,
        category: 'Oppo',
        phoneName: 'OPPO Reno11 F 5G',
        size: '256 GB',
        rating: 4.5,
        color: 'Black',
        batterycapacity: '5000 mAh',
        imageURL: 'assets/phoneimages/anh2a.png',
        isFavorated: true,
        decription:
        'iPhone 15 Pro is the first iPhone to be designed from aerospace-grade titanium, the same alloy used in spacecraft design for trips to Mars..',
        isSelected: false),
        Phone(
        phoneId: 3,
        price: 383,
        category: 'Apple',
        phoneName: 'Iphone 11 Pro',
        size: '128 GB',
        rating: 4.5,
        color: 'Black',
        batterycapacity: '3110 mAh',
        imageURL: 'assets/phoneimages/anh4.png',
        isFavorated: false,
        decription:
        'Apple has officially launched the trio of iPhone 11 super products, in which the iPhone 11 64GB version has the cheapest price but is still strongly upgraded like the previously launched iPhone Xr.',
        isSelected: false),
        Phone(
        phoneId: 4,
        price: 22,
        category: 'Apple',
        phoneName: 'Iphone 11',
        size: '128GB',
        rating: 4.5,
        color: 'Đen',
        batterycapacity: '23 - 34',
        imageURL: 'assets/phoneimages/anh1.png',
        isFavorated: true,
        decription:
        'iPhone 15 Pro is the first iPhone to be designed from aerospace-grade titanium, the same alloy used in spacecraft design for trips to Mars..',
        isSelected: false),
        Phone(
        phoneId: 5,
        price: 22,
        category: 'Indoor',
        phoneName: '',
        color: 'Đen',
        size: 'Large',
        rating: 4.5,
        batterycapacity: '23 - 34',
        imageURL: 'assets/phoneimages/anh1.png',
        isFavorated: true,
        decription:
        'iPhone 15 Pro is the first iPhone to be designed from aerospace-grade titanium, the same alloy used in spacecraft design for trips to Mars..',
        isSelected: false),
        Phone(
        phoneId: 6,
        price: 22,
        category: 'Indoor',
        color: 'Đen',
        phoneName: '',
        size: 'Large',
        rating: 4.5,
        batterycapacity: '23 - 34',
        imageURL: 'assets/phoneimages/anh1.png',
        isFavorated: true,
        decription:
        'iPhone 15 Pro is the first iPhone to be designed from aerospace-grade titanium, the same alloy used in spacecraft design for trips to Mars..',
        isSelected: false),
        Phone(
        phoneId: 7,
        price: 22,
        category: 'Indoor',
        phoneName: '',
        color: 'Đen',
        size: 'Large',
        rating: 4.5,
        batterycapacity: '23 - 34',
        imageURL: 'assets/phoneimages/anh1.png',
        isFavorated: true,
        decription:
        'iPhone 15 Pro is the first iPhone to be designed from aerospace-grade titanium, the same alloy used in spacecraft design for trips to Mars..',
        isSelected: false),
        Phone(
        phoneId: 8,
        price: 22,
        color: 'Đen',
        category: 'Indoor',
        phoneName: '',
        size: 'Large',
        rating: 4.5,
        batterycapacity: '23 - 34',
        imageURL: 'assets/phoneimages/anh1.png',
        isFavorated: true,
        decription:
        'iPhone 15 Pro is the first iPhone to be designed from aerospace-grade titanium, the same alloy used in spacecraft design for trips to Mars..',
        isSelected: false),
        Phone(
        phoneId: 09,
        price: 22,
        category: 'Indoor',
        phoneName: '',
        size: 'Large',
        color: 'Đen',
        rating: 4.5,
        batterycapacity: '23 - 34',
        imageURL: 'assets/phoneimages/anh1.png',
        isFavorated: true,
        decription:
        'iPhone 15 Pro is the first iPhone to be designed from aerospace-grade titanium, the same alloy used in spacecraft design for trips to Mars..',
        isSelected: false),
        Phone(
        phoneId: 10,
        price: 22,
        category: 'Indoor',
        phoneName: '',
        size: 'Large',
        color: 'Đen',
        rating: 4.5,
        batterycapacity: '23 - 34',
        imageURL: 'assets/phoneimages/anh1.png',
        isFavorated: true,
        decription:
        'iPhone 15 Pro is the first iPhone to be designed from aerospace-grade titanium, the same alloy used in spacecraft design for trips to Mars..',
        isSelected: false),

  ];

  //Get the favorated items
  static List<Phone> getFavoritedPhone(){
    List<Phone> _travelList = Phone.phoneList;
    return _travelList.where((element) => element.isFavorated == true).toList();
  }

  //Get the cart items
  static List<Phone> addedToCartPhones(){
    List<Phone> _selectedPhones = Phone.phoneList;
    return _selectedPhones.where((element) => element.isSelected == true).toList();
  }
}
