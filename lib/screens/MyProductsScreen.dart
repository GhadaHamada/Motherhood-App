import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // Added for NumberFormat

import 'ProductDetailScreen.dart';
import 'EditProductScreen.dart';

class MyProductsScreen extends StatefulWidget {
  @override
  _MyProductsScreenState createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List<Map<String, dynamic>> myProducts = [];
  bool isLoading = true;
  String errorMessage = '';

  // Function to format price in EGP
  String formatPrice(dynamic price) {
    if (price == null || price == 'N/A') return 'N/A';
    final formatter = NumberFormat.currency(locale: 'en-EG', symbol: 'EGP ');
    return formatter.format(double.tryParse(price.toString()) ?? 0.0);
  }

  @override
  void initState() {
    super.initState();
    fetchMyProducts();
  }

  Future<void> fetchMyProducts() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        setState(() {
          errorMessage = 'يجب تسجيل الدخول أولاً';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://momshood.runasp.net/api/Products/my-products'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          myProducts = data.map((product) {
            return {
              'id': product['id'],
              'image':
                  'https://momshood.runasp.net${product['pictureUrl'] ?? ''}',
              'title': product['name'] ?? 'لا يوجد عنوان',
              'price': formatPrice(product['price']), // Formatted price
              'description': product['description'] ?? 'لا يوجد وصف',
              'state': product['state'] ?? 'غير معروف',
              'phoneNumber': product['phoneNumber'] ?? '',
              'whatsappNumber': product['whatsappNumber'] ?? '',
              'userName': product['userName'] ?? '',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'فشل في تحميل المنتجات: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ: $e';
        isLoading = false;
      });
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        setState(() {
          errorMessage = 'يجب تسجيل الدخول أولاً';
        });
        return;
      }

      final response = await http.delete(
        Uri.parse('https://momshood.runasp.net/api/Products/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        setState(() {
          myProducts.removeWhere((product) => product['id'] == productId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف المنتج بنجاح')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في حذف المنتج')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD2C6E0),
      appBar: AppBar(
        backgroundColor: Color(0xFFD2C6E0),
        elevation: 0,
        leading: IconButton(
          icon:
              Image.asset('assets/images/back (1).png', width: 30, height: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(
            'My Products',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : myProducts.isEmpty
                  ? Center(child: Text('لا توجد منتجات'))
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: myProducts.length,
                        itemBuilder: (context, index) {
                          final product = myProducts[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                    product: product,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(15)),
                                      child: product['image'].isEmpty
                                          ? Icon(Icons.image_not_supported,
                                              size: 50)
                                          : Image.network(
                                              product['image'],
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                print(
                                                    'خطأ في تحميل الصورة: $error');
                                                return Icon(Icons.broken_image,
                                                    size: 50);
                                              },
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product['title'],
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            PopupMenuButton<String>(
                                              icon: Icon(Icons.more_vert),
                                              onSelected: (value) {
                                                if (value == 'edit') {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditProductScreen(
                                                        product: product,
                                                      ),
                                                    ),
                                                  ).then((_) {
                                                    fetchMyProducts();
                                                  });
                                                } else if (value == 'delete') {
                                                  deleteProduct(product['id']);
                                                }
                                              },
                                              itemBuilder:
                                                  (BuildContext context) {
                                                return [
                                                  PopupMenuItem(
                                                    value: 'edit',
                                                    child: Text('Edit'),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text('Delete'),
                                                  ),
                                                ];
                                              },
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          product['state'],
                                          style: TextStyle(color: Colors.grey),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              product[
                                                  'price'], // Formatted price
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'ProductDetailScreen.dart'; // تأكد من استيراد صفحة تفاصيل المنتج
import 'EditProductScreen.dart'; // صفحة تعديل المنتج

class MyProductsScreen extends StatefulWidget {
  @override
  _MyProductsScreenState createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List<Map<String, dynamic>> myProducts = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchMyProducts();
  }

  Future<void> fetchMyProducts() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        setState(() {
          errorMessage = 'يجب تسجيل الدخول أولاً';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://localhost:7054/api/Products/my-products'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          myProducts = data.map((product) {
            return {
              'id': product['id'],
              'image': 'https://localhost:7054${product['pictureUrl'] ?? ''}',
              'title': product['name'] ?? 'لا يوجد عنوان',
              'price': "\$${product['price']?.toString() ?? 'N/A'}",
              'description': product['description'] ?? 'لا يوجد وصف',
              'state': product['state'] ?? 'غير معروف',
              'phoneNumber': product['phoneNumber'] ?? '',
              'whatsappNumber': product['whatsappNumber'] ?? '',
              'userName': product['userName'] ?? '',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'فشل في تحميل المنتجات: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ: $e';
        isLoading = false;
      });
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        setState(() {
          errorMessage = 'يجب تسجيل الدخول أولاً';
        });
        return;
      }

      final response = await http.delete(
        Uri.parse('https://localhost:7054/api/Products/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        setState(() {
          myProducts.removeWhere((product) => product['id'] == productId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف المنتج بنجاح')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في حذف المنتج')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD2C6E0),
      appBar: AppBar(
        backgroundColor: Color(0xFFD2C6E0),
        elevation: 0,
        leading: IconButton(
          icon:
              Image.asset('assets/images/back (1).png', width: 30, height: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('My Products'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : myProducts.isEmpty
                  ? Center(child: Text('لا توجد منتجات'))
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: myProducts.length,
                        itemBuilder: (context, index) {
                          final product = myProducts[index];
                          return GestureDetector(
                            onTap: () {
                              // التنقل إلى صفحة تفاصيل المنتج
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                    product: product,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(15)),
                                      child: product['image'].isEmpty
                                          ? Icon(Icons.image_not_supported,
                                              size: 50)
                                          : Image.network(
                                              product['image'],
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                print(
                                                    'خطأ في تحميل الصورة: $error');
                                                return Icon(Icons.broken_image,
                                                    size: 50);
                                              },
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              product['title'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            PopupMenuButton<String>(
                                              icon: Icon(Icons.more_vert),
                                              onSelected: (value) {
                                                if (value == 'edit') {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditProductScreen(
                                                        product: product,
                                                      ),
                                                    ),
                                                  ).then((_) {
                                                    fetchMyProducts(); // تحديث القائمة بعد التعديل
                                                  });
                                                } else if (value == 'delete') {
                                                  deleteProduct(product['id']);
                                                }
                                              },
                                              itemBuilder:
                                                  (BuildContext context) {
                                                return [
                                                  PopupMenuItem(
                                                    value: 'edit',
                                                    child: Text('Edit'),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text('Delete'),
                                                  ),
                                                ];
                                              },
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          product['state'],
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              product['price'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}*/
/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'ProductDetailScreen.dart'; // تأكد من استيراد صفحة تفاصيل المنتج

class MyProductsScreen extends StatefulWidget {
  @override
  _MyProductsScreenState createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List<Map<String, dynamic>> myProducts = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchMyProducts();
  }

  Future<void> fetchMyProducts() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        setState(() {
          errorMessage = 'يجب تسجيل الدخول أولاً';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://localhost:7054/api/Products/my-products'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          myProducts = data.map((product) {
            return {
              'id': product['id'],
              'image': 'https://localhost:7054${product['pictureUrl'] ?? ''}',
              'title': product['name'] ?? 'لا يوجد عنوان',
              'price': "\$${product['price']?.toString() ?? 'N/A'}",
              'description': product['description'] ?? 'لا يوجد وصف',
              'state': product['state'] ?? 'غير معروف',
              'phoneNumber': product['phoneNumber'] ?? '',
              'whatsappNumber': product['whatsappNumber'] ?? '',
              'userName': product['userName'] ?? '',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'فشل في تحميل المنتجات: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD2C6E0),
      appBar: AppBar(
        backgroundColor: Color(0xFFD2C6E0),
        elevation: 0,
        leading: IconButton(
          icon:
              Image.asset('assets/images/back (1).png', width: 30, height: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('My Products'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : myProducts.isEmpty
                  ? Center(child: Text('لا توجد منتجات'))
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: myProducts.length,
                        itemBuilder: (context, index) {
                          final product = myProducts[index];
                          return GestureDetector(
                            onTap: () {
                              // التنقل إلى صفحة تفاصيل المنتج
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                    product: product,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(15)),
                                      child: product['image'].isEmpty
                                          ? Icon(Icons.image_not_supported,
                                              size: 50)
                                          : Image.network(
                                              product['image'],
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                print(
                                                    'خطأ في تحميل الصورة: $error');
                                                return Icon(Icons.broken_image,
                                                    size: 50);
                                              },
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['title'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          product['state'],
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              product['price'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}*/
