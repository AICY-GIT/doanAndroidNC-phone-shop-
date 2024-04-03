class Earphone {
  final int earphoneId;
  final int price;
  final String size;
  final double rating;
  final String batterycapacity;
  final String category;
  final String earphoneName;
  final String color;
  final String imageURL;
  bool isFavorated;
  final String decription;
  bool isSelected;

  Earphone(
      {required this.earphoneId,
        required this.price,
        required this.category,
        required this.earphoneName,
        required this.size,
        required this.color,
        required this.rating,
        required this.batterycapacity,
        required this.imageURL,
        required this.isFavorated,
        required this.decription,
        required this.isSelected});

  static List<Earphone> earphoneList = [
    Earphone(
        earphoneId: 0,
         price: 235,
        category: 'Apple',
        earphoneName: 'Apple AirPods Pro',
        size: 'Bluetooth',
        rating: 4.9,
        color: 'White',
        batterycapacity: '6h',
        imageURL: 'assets/phoneimages/anhb1.png',
        isFavorated: false,
        decription:
        'Airpods Pro 2 Type-C with active noise cancellation technology provides 2 times more noise cancellation for an impressive listening, calling and music experience..',
        isSelected: false),
   Earphone(
        earphoneId: 1,
         price: 119,
        category: 'JBL',
        earphoneName: 'JBL Tune 770NC',
        size: 'Bluetooth',
        rating: 4.9,
        color: 'Black',
        batterycapacity: '70h',
        imageURL: 'assets/phoneimages/anhb2.png',
        isFavorated: false,
        decription:
        'JBL Tune 770NC headphones offer a youthful design, wireless connection, supporting experiences anytime, anywhere. With the outstanding noise canceling feature on these JBL headphones..',
        isSelected: false),
    Earphone(
        earphoneId: 2,
         price: 199,
        category: 'Sony',
        earphoneName: 'Sony Inzone H9',
        size: 'Bluetooth',
        rating: 4.9,
        color: 'White',
        batterycapacity: ' 32h',
        imageURL: 'assets/phoneimages/anhb3.png',
        isFavorated: false,
        decription:
        'Sony INZONE H9 headphones provide a vivid sound experience, helping you play with the highest concentration. If you are interested in this headphone product, please read the content below to understand better..',
        isSelected: false),
   Earphone(
        earphoneId: 3,
         price: 231,
        category: 'Sennheiser',
        earphoneName: 'Sennheiser MOMENTUM 4',
        size: 'Bluetooth',
        rating: 4.9,
        color: 'White',
        batterycapacity: '60h',
        imageURL: 'assets/phoneimages/anhb4.png',
        isFavorated: false,
        decription:
        'Sennheiser Momentum 4 is the latest headphone model just launched by Sennheiser. After a period of absence..',
        isSelected: false),
  ];

  //Get the favorated items
  static List<Earphone> getFavoritedPhone(){
    List<Earphone> _travelList = Earphone.earphoneList;
    return _travelList.where((element) => element.isFavorated == true).toList();
  }

  //Get the cart items
  static List<Earphone> addedToCartPhones(){
    List<Earphone> _selectedPhones = Earphone.earphoneList;
    return _selectedPhones.where((element) => element.isSelected == true).toList();
  }
}
