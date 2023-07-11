// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';



// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Google Play Subscription Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   StreamSubscription<List<PurchaseDetails>> _subscription;
//   FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   bool _purchased = false;
//   DateTime _purchaseDate;
//   DateTime _validDate;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize in-app purchases
//     InAppPurchaseConnection.enablePendingPurchases();
//     _initSubscription();
//   }

//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }

//   void _initSubscription() {
//     final Stream<List<PurchaseDetails>> purchaseUpdated =
//         InAppPurchaseConnection.instance.purchaseUpdatedStream;

//     _subscription = purchaseUpdated.listen((List<PurchaseDetails> purchases) {
//       _listenToPurchaseUpdated(purchases);
//     }, onDone: () {
//       _subscription.cancel();
//     }, onError: (error) {
//       // Handle error
//     });

//     // Check previous purchases
//     InAppPurchaseConnection.instance
//         .queryPastPurchases()
//         .then(_listenToPurchaseUpdated);
//   }

//   void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
//     purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
//       if (purchaseDetails.status == PurchaseStatus.purchased) {
//         // Purchase successful
//         _purchased = true;
//         _purchaseDate = purchaseDetails.purchaseDate;
//         _validDate = _calculateValidDate(purchaseDetails);
//         _updateFirestore();
//       } else if (purchaseDetails.status == PurchaseStatus.error) {
//         // Purchase failed
//         // Handle error
//       }
//     });
//   }

//   DateTime _calculateValidDate(PurchaseDetails purchaseDetails) {
//     if (purchaseDetails.billingPeriod == BillingPeriod.month) {
//       return purchaseDetails.purchaseDate.add(Duration(days: 31));
//     } else if (purchaseDetails.billingPeriod == BillingPeriod.sixMonths) {
//       return purchaseDetails.purchaseDate.add(Duration(days: 186));
//     }
//     return null;
//   }

//   void _updateFirestore() async {
//     final userDoc = _firestore.collection('your_collection').doc('user');
//     await userDoc.update({
//       'purchased': _purchased,
//       'purchaseDate': _purchaseDate,
//       'validDate': _validDate,
//     });
//   }

//   Future<bool> _isSubscriptionValid() async {
//     final userDoc = await _firestore.collection('your_collection').doc('user').get();
//     if (userDoc.exists) {
//       final purchased = userDoc.data()['purchased'] ?? false;
//       final validDate = userDoc.data()['validDate']?.toDate();
//       return purchased && validDate != null && DateTime.now().isBefore(validDate);
//     }
//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google Play Subscription Demo'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             StreamBuilder<bool>(
//               stream: _isSubscriptionValid().asStream(),
//               initialData: false,
//               builder: (context, snapshot) {
//                 if (snapshot.data == true) {
//                   return Text('Subscription is active');
//                 } else {
//                   return Text('No active subscription');
//                 }
//               },
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Start purchase flow
//                 _startPurchaseFlow();
//               },
//               child: Text('Subscribe'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _startPurchaseFlow() {
//     final List<String> productIds = ['your_product_id']; // Replace with your product ID

//     final ProductDetailsResponse response =
//         InAppPurchaseConnection.instance.queryProductDetails(productIds.toSet());

//     if (response.notFoundIDs.isNotEmpty) {
//       // Handle unavailable products
//       return;
//     }

//     final ProductDetails productDetails = response.productDetails.first;

//     final PurchaseParam purchaseParam = PurchaseParam(
//       productDetails: productDetails,
//       applicationUserName: null,
//       sandboxTesting: false, // Set to true for testing with Google Play sandbox
//     );

//     InAppPurchaseConnection.instance.buyNonConsumable(purchaseParam: purchaseParam);
//   }
// }
