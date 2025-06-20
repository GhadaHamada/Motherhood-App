import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // Added for NumberFormat

import 'ProductDetailScreen.dart'; // تأكد من استيراد صفحة تفاصيل المنتج

class SavedProductsScreen extends StatefulWidget {
  @override
  _SavedProductsScreenState createState() => _SavedProductsScreenState();
}

class _SavedProductsScreenState extends State<SavedProductsScreen> {
  List<Map<String, dynamic>> savedProducts = [];
  bool isLoading = true;
  String errorMessage = '';
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    await fetchSavedProducts();
    setState(() => isLoading = false);
  }

  // Function to format price in EGP
  String formatPrice(dynamic price) {
    if (price == null || price == 'N/A') return 'N/A';
    final formatter = NumberFormat.currency(locale: 'en-EG', symbol: 'EGP ');
    return formatter.format(double.tryParse(price.toString()) ?? 0.0);
  }

  Future<void> fetchSavedProducts() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        setState(() => errorMessage = 'يجب تسجيل الدخول أولاً');
        return;
      }

      final response = await http.get(
        Uri.parse('https://momshood.runasp.net/api/Products/Saved-product'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          savedProducts = data.map((product) {
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
              'isSaved': true,
            };
          }).toList();
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage =
              'فشل في تحميل المنتجات المحفوظة: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ في الاتصال: ${e.toString()}';
      });
    }
  }

  Future<void> removeSavedProduct(String productId) async {
    try {
      // حذف المنتج محلياً أولاً
      setState(() {
        savedProducts.removeWhere((product) => product['id'] == productId);
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        setState(() => errorMessage = 'يجب تسجيل الدخول أولاً');
        return;
      }

      final response = await http.delete(
        Uri.parse(
            'https://momshood.runasp.net/api/Products/DeleteSavedProduct?productId=$productId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        // إذا فشل الحذف في السيرفر، نعيد تحميل البيانات
        await fetchSavedProducts();
        throw Exception('فشل في إزالة المنتج من السيرفر');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إزالة المنتج بنجاح'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          duration: Duration(seconds: 2),
        ),
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Saved Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: fetchSavedProducts,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : savedProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_border,
                                size: 50, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('لا توجد منتجات محفوظة بعد',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey)),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: savedProducts.length,
                          itemBuilder: (context, index) {
                            final product = savedProducts[index];
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(
                                      product: product,
                                    ),
                                  ),
                                );
                                await fetchSavedProducts();
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(15)),
                                        child: product['image'].isEmpty
                                            ? Icon(Icons.image_not_supported,
                                                size: 50, color: Colors.grey)
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
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Icon(
                                                      Icons.broken_image,
                                                      size: 50,
                                                      color: Colors.grey);
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
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            product['state'],
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                product[
                                                    'price'], // Formatted price
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.favorite,
                                                  color: Color(0xff8D7D97),
                                                ),
                                                onPressed: () async {
                                                  await removeSavedProduct(
                                                      product['id']);
                                                },
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
      ),
    );
  }
}
/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'ProductDetailScreen.dart'; // تأكد من استيراد صفحة تفاصيل المنتج

class SavedProductsScreen extends StatefulWidget {
  @override
  _SavedProductsScreenState createState() => _SavedProductsScreenState();
}

class _SavedProductsScreenState extends State<SavedProductsScreen> {
  List<Map<String, dynamic>> savedProducts = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchSavedProducts();
  }

  Future<void> fetchSavedProducts() async {
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
        Uri.parse('https://localhost:7054/api/Products/Saved-product'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          savedProducts = data.map((product) {
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
              'isSaved': true, // المنتجات هنا محفوظة بالفعل
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'فشل في تحميل المنتجات المحفوظة: ${response.statusCode}';
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

  Future<void> removeSavedProduct(String productId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      setState(() {
        errorMessage = 'يجب تسجيل الدخول أولاً';
      });
      return;
    }

    final response = await http.delete(
      Uri.parse(
          'https://localhost:7054/api/Products/DeleteSavedProduct?productId=$productId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        savedProducts.removeWhere((product) => product['id'] == productId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمت إزالة المنتج من المحفوظات')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إزالة المنتج')),
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
        title: Text('Saved Products'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : savedProducts.isEmpty
                  ? Center(child: Text('لا توجد منتجات محفوظة'))
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: savedProducts.length,
                        itemBuilder: (context, index) {
                          final product = savedProducts[index];
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
                                            IconButton(
                                              icon: Icon(
                                                Icons.favorite,
                                                color: Color(0xff8D7D97),
                                              ),
                                              onPressed: () async {
                                                await removeSavedProduct(
                                                    product['id']);
                                              },
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
*/
