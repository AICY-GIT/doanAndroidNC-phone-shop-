import 'package:buoi4/models/earphone.dart';
import 'package:flutter/material.dart';
import 'package:buoi4/models/constants.dart';
import 'package:buoi4/models/phones.dart';

class DetailEarphone extends StatefulWidget {
  final int earphoneId;
  const DetailEarphone({Key? key, required this.earphoneId}) : super(key: key);

  @override
  State<DetailEarphone> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailEarphone> {
  //Toggle Favorite button
  bool toggleIsFavorated(bool isFavorited) {
    return !isFavorited;
  }

  //Toggle add remove from cart
  bool toggleIsSelected(bool isSelected) {
    return !isSelected;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Earphone> earphoneList = Earphone.earphoneList;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Constants.primaryColor.withOpacity(.15),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Constants.blackColor,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    debugPrint('favorite');
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Constants.primaryColor.withOpacity(.15),
                    ),
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            bool isFavorited = toggleIsFavorated(
                                earphoneList[widget.earphoneId].isFavorated);
                            earphoneList[widget.earphoneId].isFavorated =
                                isFavorited;
                          });
                        },
                        icon: Icon(
                          earphoneList[widget.earphoneId].isFavorated == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Color.fromARGB(255, 255, 0, 0),
                        )),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Container(
              width: size.width * .8,
              height: size.height * .8,
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  Positioned(
                    top: 30,
                    left: 0,
                    child: SizedBox(
                      height: 190,
                      width: 190,
                      child: Image.asset(earphoneList[widget.earphoneId].imageURL,),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 0,
                    child: SizedBox(
                      height: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          PlantFeature(
                            title: 'Connect',
                            plantFeature: earphoneList[widget.earphoneId].size,
                            
                          ),
                          PlantFeature(
                            title: 'Color',
                            plantFeature:
                                earphoneList[widget.earphoneId].color.toString(),
                          ),
                          PlantFeature(
                            title: 'Battery Capacity',
                            plantFeature:
                                earphoneList[widget.earphoneId].batterycapacity,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 80, left: 30, right: 30),
              height: size.height * .5,
              width: size.width,
              decoration: BoxDecoration(
                color: Constants.primaryColor.withOpacity(.4),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            earphoneList[widget.earphoneId].earphoneName,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2, // Giới hạn số dòng là 2
                            style: TextStyle(
                              color: Color.fromARGB(255, 38, 0, 0),
                              fontWeight: FontWeight.bold,
                              fontSize: 30.0,
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            r'$' + earphoneList[widget.earphoneId].price.toString(),
                            style: TextStyle(
                              color: Color.fromARGB(255, 38, 0, 0),
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          earphoneList[widget.earphoneId].rating.toString(),
                          style: TextStyle(
                            fontSize: 30.0,
                            color: Constants.blackColor,
                          ),
                        ),
                        Icon(
                          Icons.star,
                          size: 30.0,
                          color: Constants.blackColor,
                        ),
                      ],
                    ),
                  ],
                ),


                  const SizedBox(
                    height: 5.0,
                  ),
                  Expanded(
                    child: Text(
                      earphoneList[widget.earphoneId].decription,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        height: 1.5,
                        fontSize: 18,
                        color: Constants.blackColor.withOpacity(.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: size.width * .9,
        height: 50,
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  color: earphoneList[widget.earphoneId].isSelected == true ? Constants.primaryColor.withOpacity(.5) : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 1),
                      blurRadius: 5,
                      color: Constants.primaryColor.withOpacity(.3),
                    ),
                  ]),
              child: IconButton(onPressed: (){
                setState(() {
                  bool isSelected = toggleIsSelected(earphoneList[widget.earphoneId].isSelected);

                  earphoneList[widget.earphoneId].isSelected = isSelected;
                });
              }, icon: Icon(
                Icons.shopping_cart,
                color: earphoneList[widget.earphoneId].isSelected == true ? Colors.white : Constants.primaryColor,
              )),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Constants.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 1),
                        blurRadius: 5,
                        color: Constants.primaryColor.withOpacity(.3),
                      )
                    ]),
                child: const Center(
                  child: Text(
                    'BUY NOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlantFeature extends StatelessWidget {
  final String plantFeature;
  final String title;
  const PlantFeature({
    Key? key,
    required this.plantFeature,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Constants.blackColor,
          ),
        ),
        Text(
          plantFeature,
          style: TextStyle(
            color: Color.fromARGB(255, 38, 0, 0),
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
