// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import 'sample.dart';

import 'package:fluttertoast/fluttertoast.dart';
// void main() {
//   runApp(MyApp());
// }

const bool kAutoConsume =
    true; // Set it to false if you don't want to auto-consume products
bool heisvalid = false;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Play Subscription Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _isPurchased = false;
  var purchased_product_id;
  var purchased_product_raw_price;
  var purchased_product_discription;
  var purchased_product_title;
  

  // ProductDetails prod = ProductDetails(
  //     id: '',
  //     title: '',
  //     description: '',
  //     price: '',
  //     rawPrice: 0.0,
  //     currencyCode: '');
  //  GooglePlayProductDetails googlePlayProductDetails = googlePlayProductDetails
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    // Initialize the in_app_purchase plugin
    // InAppPurchaseConnection.enablePendingPurchases();
//  InAppPurchase.instance
// .connect();
    // Fetch products for purchase
    _initializeProducts();

    // Listen for purchases updates
    _subscription = InAppPurchase.instance.purchaseStream.listen((data) {
      _handlePurchaseUpdates(data);
    });
    check_valid();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _initializeProducts() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      // The store is not available, handle accordingly
      return;
    }

    // Define your product IDs for subscriptions
    const Set<String> _kProductIds = {'subscription_silver', 'upgrade_abc','1_week_subscription'};

    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_kProductIds);

    if (response.notFoundIDs.isNotEmpty) {
      // Some product IDs were not found, handle accordingly
    }
    print('1234567890');
    print(response.productDetails[2].rawPrice);
    print(response.productDetails[2].description);
    print(response.productDetails[2].title);
    print(response.productDetails[2].id);
    final List<ProductDetails> products = response.productDetails;

    if (mounted) {
      setState(() {
        _products = products;
      });
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          // Purchase is pending, handle accordingly
          break;
        case PurchaseStatus.purchased:
          // Purchase was successful, verify and process the purchase
          _verifyPurchase(purchaseDetails);
          break;
        case PurchaseStatus.error:
          // Purchase failed, handle accordingly
          break;
        case PurchaseStatus.restored:
          // Purchase was restored, handle accordingly
          _verifyPurchase(purchaseDetails);
          break;
      }
    }
  }

  // DateTime _calculateValidDate(PurchaseDetails purchaseDetails) {
  //   if (purchaseDetails.billingPeriod == BillingPeriod.month) {
  //     return purchaseDetails.purchaseDate.add(Duration(days: 31));
  //   } else if (purchaseDetails.billingPeriod == BillingPeriod.sixMonths) {
  //     return purchaseDetails.purchaseDate.add(Duration(days: 186));
  //   }
  //   return null;
  // }

  void _verifyPurchase(PurchaseDetails purchaseDetails) async {
    int dataNo=0;
    // Verify the purchase if necessary
    if (purchaseDetails.pendingCompletePurchase) {
      await InAppPurchase.instance.completePurchase(purchaseDetails);
    }

    if (purchaseDetails.productID == 'upgrade_abc') {
      // Update the Firestore document for the user
      try {
        DateTime purchaseDate = DateTime.now();
       DocumentSnapshot us= await _userCollection.doc('seenu').get();
       
       if (us.exists) {
      // setState(() {
      //   dataNo = us['subscription_silver'] as int;
       
      // });
      dataNo = us['subscription_silver'] as int;

      print(dataNo);
    }
        DateTime validDate = purchaseDate.add(Duration(days: dataNo));

        await _userCollection.doc('user_id').update({
          'purchased': true,
          'purchaseDate': purchaseDate,
          'validDate': validDate,
          'no_of_days':dataNo
        });
        
        setState(() {
          _isPurchased = true;
        });
        check_valid();
        // if (_isPurchased == true) {
        //   Navigator.push(
        //       context, MaterialPageRoute(builder: (context) => HomePage()));
        // }
      } catch (e) {
        // Handle Firestore update error
      }
    }
    if (purchaseDetails.productID == 'upgrade_abch') {
      // Update the Firestore document for the user
      try {
        DateTime purchaseDate = DateTime.now();
        DateTime validDate = purchaseDate.add(Duration(days: 38));

        await _userCollection.doc('user_id').update({
          'purchased': true,
          'purchaseDate': purchaseDate,
          'validDate': validDate,
          'no_of_days':38
        });
        setState(() {
          _isPurchased = true;
        });
        check_valid();
        // if (_isPurchased == true) {
        //   Navigator.push(
        //       context, MaterialPageRoute(builder: (context) => HomePage()));
        // }
      } catch (e) {
        // Handle Firestore update error
      }
    }
     if (purchaseDetails.productID == '1_week_subscription') {
      // Update the Firestore document for the user
      try {
        DateTime purchaseDate = DateTime.now();
        DateTime validDate = purchaseDate.add(Duration(days: 7));

        await _userCollection.doc('user_id').update({
          'purchased': true,
          'purchaseDate': purchaseDate,
          'validDate': validDate,
          'no_of_days':7
        });
        setState(() {
          _isPurchased = true;
        });
        check_valid();
        // if (_isPurchased == true) {
        //   Navigator.push(
        //       context, MaterialPageRoute(builder: (context) => HomePage()));
        // }
      } catch (e) {
        // Handle Firestore update error
      }
    }
  }



  Future<void> check_valid() async {
    final userDoc = await _firestore.collection('users').doc('user_id').get();
    bool isPurchased = userDoc.get('purchased');
    final isvalid = userDoc.get('validDate') as Timestamp;
    final validDate = isvalid.toDate();
    final now = DateTime.now();
    //  DateTime isvalid =userDoc.get('validDate') ;
    //  DateTime now=DateTime.now();
    if (isPurchased == true && now.isBefore(validDate)) {
      heisvalid = true;
      print(heisvalid);
      setState(() {
        heisvalid = true;
      });
    } else {
      heisvalid = false;
      print(heisvalid);
      setState(() {
        heisvalid = false;
      });
    }
  }

  Future<void> _buySubscription() async {
    print(purchased_product_id);
    // int index = _products.indexOf(ProductDetails(
    //     id: prod.id,
    //     title: prod.title,
    //     description: prod.description,
    //     price: prod.price,
    //     rawPrice: prod.rawPrice,
    //     currencyCode: prod.currencyCode));
    // int index= _products.indexOf(_products)

    // int index=_products.indexOf(prod);
    int index = 0;
    print(_products.elementAt(0));
    // print(prod);
    for (int i = 0; i < _products.length; i++) {
      if (_products[i].id == purchased_product_id &&
      _products[i].title == purchased_product_title&&
      _products[i].description == purchased_product_discription&&
      _products[i].rawPrice == purchased_product_raw_price) {
        index = i;

      }
    }
    final PurchaseParam purchaseParam = PurchaseParam(
      // productDetails: prod,

      productDetails: _products[index],
      applicationUserName:
          null, // Set it if you want to use an application-specific username
      // sandboxTesting: false, // Set it to true for testing in sandbox mode
    );

    try {
      await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: purchaseParam,
        // autoConsume: kAutoConsume,
      );
    } catch (e) {
      // Handle purchase error
    }
  }

  void reloadApp() {
    // Restart the Flutter app.
    // This will reload the app with the latest changes.
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Play Subscription Demo'),
      ),
      drawer: Drawer(
        child: ListTile(
          title: const Text('move'),
          onTap: () {
            heisvalid == true
                ? Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const MyWidget()))
                : showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RefreshIndicator(
                        onRefresh: check_valid,
                        child: SingleChildScrollView(
                          child: AlertDialog(
                            actions: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(Icons.close))
                            ],
                            title: const Text('subscription Details'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available Subscriptions:',
                                  style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(height: 10),
                                if (_products.isNotEmpty)
                                  Column(
                  children: _products.map((product) {
                    return ListTile(
                      title: Text(product.title),
                      subtitle: Text(product.price),

                      trailing: ElevatedButton(
                        onPressed: () {
                          if (_isPurchased == true) {


Fluttertoast.showToast(
                msg: 'you still have premium access so not need to purchase',
                toastLength: Toast.LENGTH_LONG,
                backgroundColor: Color.fromARGB(255, 64, 249, 255),
                textColor: const Color.fromARGB(255, 15, 0, 0),
                gravity: ToastGravity.CENTER,
                fontSize: 20.0,
                
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'you still have premium access so not need to purchase'),
                ),
              );
                            
                          } else if (_isPurchased == false) {
                            setState(() {
                              purchased_product_id=product.id;
                              purchased_product_title=product.title;
                              purchased_product_raw_price=product.rawPrice;
                              purchased_product_discription=product.description;
                              _buySubscription();
                            });
                          }
                        },
                        // onPressed: _isPurchased ? null : _buySubscription,
                        child: Text(_isPurchased ? 'Purchased' : 'Buy'),
                      ),
                    );
                  }).toList(),
                ),
                                ElevatedButton(
                                    onPressed: check_valid,
                                    child: Text('press')),
                                heisvalid == true
                                    ? Text('valid')
                                    : Text('Not valid'),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: check_valid,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Available Subscriptions:',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              if (_products.isNotEmpty)
//               ListView.builder(

//                 itemBuilder: (context ,index){
//        _products.map((product){});

//                 return ListTile(
// title: Text(''),
//                 );
//               },itemCount: _products.length,),
                Column(
                  children: _products.map((product) {
                    return ListTile(
                      title: Text(product.title),
                      subtitle: Text(product.price),

                      trailing: ElevatedButton(
                        onPressed: () {
                          if (_isPurchased == true) {


Fluttertoast.showToast(
                msg: 'you still have premium access so not need to purchase',
                toastLength: Toast.LENGTH_LONG,
                backgroundColor: Color.fromARGB(255, 64, 249, 255),
                textColor: const Color.fromARGB(255, 15, 0, 0),
                gravity: ToastGravity.CENTER,
                fontSize: 20.0,
                
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'you still have premium access so not need to purchase'),
                ),
              );
                            
                          } else if (_isPurchased == false) {
                            setState(() {
                              purchased_product_id=product.id;
                              purchased_product_title=product.title;
                              purchased_product_raw_price=product.rawPrice;
                              purchased_product_discription=product.description;
                              _buySubscription();
                            });
                          }
                        },
                        // onPressed: _isPurchased ? null : _buySubscription,
                        child: Text(_isPurchased ? 'Purchased' : 'Buy'),
                      ),
                    );
                  }).toList(),
                ),
              ElevatedButton(onPressed: check_valid, child: Text('press')),
              heisvalid == true ? Text('valid') : Text('Not valid'),
            ],
          ),
        ),
      ),
    );
  }
}

Column buypagecolumn() {
  return Column();
}
