// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';


// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'In-App Purchase Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final CollectionReference _userCollection =
//       FirebaseFirestore.instance.collection('users');

//   late StreamSubscription<List<PurchaseDetails>> _subscription;
//   List<String> _productIds = ['product_id_1', 'product_id_2']; // Replace with your actual product IDs
//   bool _isPurchased = false;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize the in_app_purchase package
//     InAppPurchaseConnection.enablePendingPurchases();
//     _subscription = InAppPurchaseConnection.instance.purchaseUpdatedStream.listen((List<PurchaseDetails> purchases) {
//       _listenToPurchaseUpdated(purchases);
//     });
//   }

//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }

//   void _listenToPurchaseUpdated(List<PurchaseDetails> purchases) {
//     purchases.forEach((PurchaseDetails purchase) async {
//       if (purchase.status == PurchaseStatus.purchased) {
//         // Purchase completed, update Firestore document
//         await _updateFirestoreDocument(true);
//         setState(() {
//           _isPurchased = true;
//         });
//       } else if (purchase.status == PurchaseStatus.error) {
//         // Handle error
//         // Display an error message to the user
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text('Purchase Error'),
//               content: Text('An error occurred during the purchase process.'),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text('OK'),
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     });
//   }

//   Future<void> _updateFirestoreDocument(bool isPurchased) async {
//     try {
//       await _userCollection.doc('user').update({'purchased': isPurchased});
//     } catch (e) {
//       // Handle Firestore exception
//       print('Firestore Error: $e');
//     }
//   }

//   Future<void> _buyProduct(String productId) async {
//     try {
//       final PurchaseParam purchaseParam = PurchaseParam(
//         productDetails: await _getProductDetails(productId),
//       );
//       InAppPurchaseConnection.instance.buyNonConsumable(
//         purchaseParam: purchaseParam,
//       );
//     } catch (e) {
//       // Handle in_app_purchase exception
//       print('In-App Purchase Error: $e');
//     }
//   }

//   Future<ProductDetails> _getProductDetails(String productId) async {
//     final ProductDetailsResponse productDetailsResponse =
//         await InAppPurchaseConnection.instance.queryProductDetails({productId}.toSet());
//     if (productDetailsResponse.error != null) {
//       // Handle error
//       throw Exception('Failed to retrieve product details.');
//     }
//     return productDetailsResponse.productDetails.first;
//   }

//   Widget _buildProductList() {
//     return ListView.builder(
//       itemCount: _productIds.length,
//       itemBuilder: (BuildContext context, int index) {
//         final String productId = _productIds[index];
//         return ListTile(
//           title: Text(productId),
//           trailing: ElevatedButton(
//             onPressed: () => _buyProduct(productId),
//             child: Text('Buy'),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('In-App Purchase Example'),
//       ),
//       body: Center(
//         child: _isPurchased
//             ? Text(
//                 'You have purchased the product.',
//                 style: TextStyle(fontSize: 20.0),
//               )
//             : _buildProductList(),
//       ),
//     );
//   }
// }