import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
// void main() {
//   runApp(MyApp());
// }

const bool kAutoConsume = true; // Set it to false if you don't want to auto-consume products
bool heisvalid=false;

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
    _subscription =
        InAppPurchase.instance.purchaseStream.listen((data) {
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
    const Set<String> _kProductIds = {'subscription_silver','upgrade_abc'};

    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_kProductIds);

    if (response.notFoundIDs.isNotEmpty) {
      // Some product IDs were not found, handle accordingly
    }

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
    // Verify the purchase if necessary
    if (purchaseDetails.pendingCompletePurchase) {
      await InAppPurchase.instance.completePurchase(purchaseDetails);
    }

    if (purchaseDetails.productID == 'subscription_silver') {
      // Update the Firestore document for the user
      try {
       DateTime purchaseDate =DateTime.now();
       DateTime validDate = purchaseDate.add(Duration(days: 3));
      
        await _userCollection.doc('user_id').update({

          'purchased': true,
          'purchaseDate':purchaseDate,
          'validDate':validDate,
        });
        setState(() {
          _isPurchased = true;
        });
      } catch (e) {
        // Handle Firestore update error
      }
    }
}

Future<void> check_valid() async{
   final userDoc = await _firestore.collection('users').doc('user_id').get();
       bool isPurchased= userDoc.get('purchased') ;
        final isvalid =userDoc.get('validDate') as Timestamp;
         final validDate = isvalid.toDate();
       final now=DateTime.now();
      //  DateTime isvalid =userDoc.get('validDate') ;
      //  DateTime now=DateTime.now();
if(isPurchased==true && now.isBefore(validDate)){
heisvalid=true;
print(heisvalid);
setState(() {
  heisvalid=true;
});

}
else{
heisvalid=false;
print(heisvalid);
setState(() {
  heisvalid=false;
});

}
}

  Future<void> _buySubscription() async {
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: _products[0],
      applicationUserName: null, // Set it if you want to use an application-specific username
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Play Subscription Demo'),
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
                Column(
                  children: _products.map((product) {
                    return ListTile(
                      title: Text(product.title),
                      subtitle: Text(product.description),
                      trailing: ElevatedButton(
                        onPressed: _isPurchased ? null : _buySubscription,
                        child: Text(_isPurchased ? 'Purchased' : 'Buy'),
                      ),
                    );
                  }).toList(),
                ),
                ElevatedButton(onPressed: check_valid, child: Text('press')),
                heisvalid==true?Text('valid'):Text('Not valid'),

            ],
          ),
        ),
      ),
    );
  }
}
