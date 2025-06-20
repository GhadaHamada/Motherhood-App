/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'CreateScreen.dart';
import 'MyProductsScreen.dart';
import 'ProductDetailScreen.dart';
import 'SavedProductsScreen.dart';
import 'CommunityChatScreen.dart'; // تأكد من استيراد الصفحات الأخرى
import 'MomsGuideScreen.dart';
import 'VoiceRecognitionScreen.dart';
import 'ProfileScreen.dart';
//import 'HomeScreen.dart';
import 'home_screen.dart'; // تأكد من استيراد HomeScreen

class MarketplaceScreen extends StatefulWidget {
  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  List<Map<String, dynamic>> displayedProducts = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String errorMessage = '';
  int currentPage = 1;
  int _selectedIndex = 0; // المتغير الذي يخزن الرقم المحدد في الشريط السفلي

  @override
  void initState() {
    super.initState();
    fetchProducts();
    loadSavedProducts();
  }

  Future<void> loadSavedProducts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? savedProducts = prefs.getStringList('savedProducts');
    if (savedProducts != null) {
      setState(() {
        for (var product in displayedProducts) {
          if (savedProducts.contains(product['id'].toString())) {
            product['isSaved'] = true;
          } else {
            product['isSaved'] = false;
          }
        }
      });
    }
  }

  Future<void> fetchProducts({
    String? sort,
    String? brandId,
    String? categoryId,
    int pageIndex = 1,
    int pageSize = 10,
    String? search,
  }) async {
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

      final Uri uri =
          Uri.parse('https://momshood.runasp.net/api/Products').replace(
        queryParameters: {
          if (sort != null) 'Sort': sort,
          if (brandId != null) 'BrandId': brandId,
          if (categoryId != null) 'CategoryId': categoryId,
          'PageIndex': pageIndex.toString(),
          'PageSize': pageSize.toString(),
          if (search != null) 'Search': search,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print(data); // تصحيح الأخطاء: اطبع الرد من الـ API
        setState(() {
          displayedProducts = (data['data'] as List).map((product) {
            // إضافة النطاق الكامل للخادم إلى رابط الصورة
            String fullImageUrl =
                'https://momshood.runasp.net${product['pictureUrl'] ?? ''}';
            return {
              'id': product['id'],
              'image': fullImageUrl,
              'title': product['name'] ?? 'لا يوجد عنوان',
              'price': "\$${product['price']?.toString() ?? 'N/A'}",
              'description': product['description'] ?? 'لا يوجد وصف',
              'state': product['state'] ?? 'غير معروف',
              'phoneNumber': product['phoneNumber'] ?? '',
              'whatsappNumber': product['whatsappNumber'] ?? '',
              'userName': product['userName'] ?? '',
              'isSaved': false, // حالة الحفظ الافتراضية
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

  Future<void> saveProduct(Map<String, dynamic> product) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse(
          'https://momshood.runasp.net/api/Products/saved-product?productId=${product['id']}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        product['isSaved'] = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ المنتج')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في حفظ المنتج')),
      );
    }
  }

  Future<void> removeSavedProduct(Map<String, dynamic> product) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
      );
      return;
    }

    final response = await http.delete(
      Uri.parse(
          'https://momshood.runasp.net/api/Products/DeleteSavedProduct?productId=${product['id']}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        product['isSaved'] = false;
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
      backgroundColor: Color(0xFFCBC3D6),
      appBar: AppBar(
        backgroundColor: Color(0xffCBC3D6),
        elevation: 0,
        title: TextField(
          controller: searchController,
          onChanged: (query) {
            fetchProducts(search: query);
          },
          decoration: InputDecoration(
            hintText: 'search....',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: Color(0xff8D7D97)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedProductsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.black),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateScreen()),
              );
              if (result == true) {
                fetchProducts();
              }
            },
          ),
          IconButton(
            icon:
                Image.asset('assets/images/Vector.png', width: 30, height: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyProductsScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: displayedProducts.length,
                          itemBuilder: (context, index) {
                            final product = displayedProducts[index];
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
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  print(
                                                      'خطأ في تحميل الصورة: $error');
                                                  return Icon(
                                                      Icons.broken_image,
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
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                product['price'],
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  product['isSaved'] == true
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color:
                                                      product['isSaved'] == true
                                                          ? Color(0xff8D7D97)
                                                          : null,
                                                ),
                                                onPressed: () async {
                                                  if (product['isSaved'] ==
                                                      true) {
                                                    await removeSavedProduct(
                                                        product);
                                                  } else {
                                                    await saveProduct(product);
                                                  }
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
                  ],
                ),
      bottomNavigationBar: Container(
        height: 75, // تحديد الارتفاع
        width: 326, // تحديد العرض
        child: BottomNavigationBar(
          backgroundColor: Color(0xff8d7d9d), // لون الخلفية للشريط السفلي
          selectedItemColor: Color(0xffcbc3d6), // لون الأيقونة المحددة
          unselectedItemColor: Color(0xffcbc3d6), // لون الأيقونات غير المحددة
          showSelectedLabels: false, // إخفاء النصوص
          showUnselectedLabels: false, // إخفاء النصوص
          type: BottomNavigationBarType.fixed,
          currentIndex:
              _selectedIndex, // تعيين الأيقونة المحددة بناءً على الفهرس
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });

            // تحديد الصفحات حسب الأيقونة التي يتم الضغط عليها
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommunityChatScreen(
                        //apiUrl: 'https://localhost:7054/api/Messages',
                        ),
                  ),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MomsGuideScreen(),
                  ),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VoiceRecognitionScreen(),
                  ),
                );
                break;
              case 4:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MarketplaceScreen(),
                  ),
                );
                break;
              case 5:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                        //token: 'https://localhost:7054/api/Account/register',
                        ),
                  ),
                );
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mic),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildHomeIcon(), //Icon(Icons.shopping_cart),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '',
            ),
          ],
        ),
      ),
    );
  }

  // تخصيص أيقونة home داخل دائرة
  Widget _buildHomeIcon() {
    return Container(
      width: 40.0, // حجم الدائرة
      height: 40.0, // حجم الدائرة
      decoration: BoxDecoration(
        color: Color(0xffCBC3D6), // لون الدائرة (نفس لون الخلفية)
        shape: BoxShape.circle, // الشكل دائري
      ),
      child: Icon(
        Icons.shopping_cart,
        color: Colors.white, // لون الأيقونة
        size: 24.0, // حجم الأيقونة
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // Added for NumberFormat

import 'CreateScreen.dart';
import 'MyProductsScreen.dart';
import 'ProductDetailScreen.dart';
import 'SavedProductsScreen.dart';
import 'CommunityChatScreen.dart';
import 'MomsGuideScreen.dart';
import 'VoiceRecognitionScreen.dart';
import 'ProfileScreen.dart';
import 'home_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  List<Map<String, dynamic>> displayedProducts = [];
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  bool isSaving = false;
  bool isRefreshing = false;
  String errorMessage = '';
  int currentPage = 1;
  int _selectedIndex = 4;

  // API URLs
  static const String _baseUrl = 'https://momshood.runasp.net/api/';
  static const String _productsUrl = '${_baseUrl}Products';
  static const String _searchUrl = '${_baseUrl}Products/search';
  static const String _saveProductUrl = '${_baseUrl}Products/saved-product';
  static const String _deleteSavedProductUrl =
      '${_baseUrl}Products/DeleteSavedProduct';
  static const String _isProductSavedUrl =
      '${_baseUrl}Products/IsProductSavedByUser';
  static const String _getSavedProductsUrl =
      '${_baseUrl}Products/Saved-product';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<bool> _checkIfProductSaved(String productId, String token) async {
    try {
      final uri = Uri.parse('$_isProductSavedUrl?productId=$productId');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'text/plain',
          'Cache-Control': 'no-cache',
        },
      );

      debugPrint(
          'Checking isSaved for product $productId: Status ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final isSaved = response.body.toLowerCase() == 'true';
        debugPrint('Product $productId isSaved: $isSaved');
        return isSaved;
      } else if (response.statusCode == 401) {
        debugPrint('Unauthorized access for product $productId');
        return false;
      } else {
        debugPrint(
            'Failed to check if product $productId is saved: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error checking if product $productId is saved: $e');
      return false;
    }
  }

  Future<List<String>> _fetchSavedProductIds(String token) async {
    try {
      final response = await http.get(
        Uri.parse(_getSavedProductsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Cache-Control': 'no-cache',
        },
      );

      debugPrint(
          'Saved Products API Response: Status ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> savedProducts = jsonDecode(response.body);
        return savedProducts
            .map((product) => product['id'].toString())
            .toList();
      } else if (response.statusCode == 401) {
        debugPrint('Unauthorized access for saved products');
        return [];
      } else {
        debugPrint('Failed to fetch saved products: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching saved products: $e');
      return [];
    }
  }

  // Function to format price in EGP
  String formatPrice(dynamic price) {
    if (price == null || price == 'N/A') return 'N/A';
    final formatter = NumberFormat.currency(locale: 'en-EG', symbol: 'EGP ');
    return formatter.format(double.tryParse(price.toString()) ?? 0.0);
  }

  Future<void> _fetchProducts({
    String? sort,
    String? brandId,
    String? categoryId,
    int pageIndex = 1,
    int pageSize = 10,
    String? search,
  }) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      debugPrint('Token: $token');

      if (token == null) {
        setState(() {
          errorMessage = 'يجب تسجيل الدخول أولاً';
          isLoading = false;
        });
        return;
      }

      final savedProductIds = await _fetchSavedProductIds(token);

      // اختيار الـ URL بناءً على وجود كلمة بحث
      final baseUrl =
          search != null && search.isNotEmpty ? _searchUrl : _productsUrl;
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          if (search != null && search.isNotEmpty) 'keyword': search,
          if (search == null || search.isEmpty) ...{
            if (sort != null) 'Sort': sort,
            if (brandId != null) 'BrandId': brandId,
            if (categoryId != null) 'CategoryId': categoryId,
            'PageIndex': pageIndex.toString(),
            'PageSize': pageSize.toString(),
          },
        },
      );

      debugPrint('Fetching products from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Cache-Control': 'no-cache',
        },
      );

      debugPrint(
          'Products API Response: Status ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> products;
        if (search != null && search.isNotEmpty) {
          // لما بتستخدم /api/Products/search، الـ response بيكون list مباشرة
          products = jsonDecode(response.body);
        } else {
          // لما بتستخدم /api/Products، الـ response بيكون فيه 'data'
          final Map<String, dynamic> data = jsonDecode(response.body);
          products = data['data'] as List;
        }
        debugPrint('Found ${products.length} products');

        List<Map<String, dynamic>> tempProducts = [];
        for (var product in products) {
          final productId = product['id']?.toString();
          if (productId == null) {
            debugPrint('Skipping product with null id: $product');
            continue;
          }
          bool isSaved = savedProductIds.contains(productId);
          String fullImageUrl =
              'https://momshood.runasp.net${product['pictureUrl'] ?? ''}';
          tempProducts.add({
            'id': productId,
            'image': fullImageUrl,
            'title': product['name'] ?? 'لا يوجد عنوان',
            'price': formatPrice(product['price']),
            'description': product['description'] ?? 'لا يوجد وصف',
            'state': product['state'] ?? 'غير معروف',
            'phoneNumber': product['phoneNumber'] ?? '',
            'whatsappNumber': product['whatsappNumber'] ?? '',
            'userName': product['userName'] ?? '',
            'isSaved': isSaved,
          });
        }

        setState(() {
          displayedProducts = tempProducts;
          isLoading = false;
        });
        debugPrint(
            'Updated displayedProducts: ${displayedProducts.length} items');
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'جلسة تسجيل الدخول انتهت، من فضلك سجل دخول مرة أخرى';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'فشل في تحميل المنتجات: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      setState(() {
        errorMessage = 'خطأ: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _saveProduct(Map<String, dynamic> product) async {
    setState(() => isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
          );
        }
        return;
      }

      final productId = product['id']?.toString();
      if (productId == null) {
        debugPrint('Cannot save product with null id');
        return;
      }

      final response = await http.post(
        Uri.parse('$_saveProductUrl?productId=$productId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
        },
      );

      debugPrint(
          'Save Product Response: Status ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        bool isSaved = await _checkIfProductSaved(productId, token);
        setState(() {
          final index =
              displayedProducts.indexWhere((p) => p['id'] == productId);
          if (index != -1) {
            displayedProducts[index]['isSaved'] = isSaved;
            debugPrint('Product $productId marked as saved in UI: $isSaved');
            debugPrint(
                'Updated displayedProducts[$index]: ${displayedProducts[index]}');
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ المنتج')),
          );
        }
      } else if (response.statusCode == 401) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('جلسة تسجيل الدخول انتهت، سجل دخول مرة أخرى')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل في حفظ المنتج')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving product: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ أثناء حفظ المنتج')),
        );
      }
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _removeSavedProduct(Map<String, dynamic> product) async {
    setState(() => isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
          );
        }
        return;
      }

      final productId = product['id']?.toString();
      if (productId == null) {
        debugPrint('Cannot remove product with null id');
        return;
      }

      final response = await http.delete(
        Uri.parse('$_deleteSavedProductUrl?productId=$productId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Cache-Control': 'no-cache',
        },
      );

      debugPrint(
          'Delete Saved Product Response: Status ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        bool isSaved = await _checkIfProductSaved(productId, token);
        setState(() {
          final index =
              displayedProducts.indexWhere((p) => p['id'] == productId);
          if (index != -1) {
            displayedProducts[index]['isSaved'] = isSaved;
            debugPrint('Product $productId marked as unsaved in UI: $isSaved');
            debugPrint(
                'Updated displayedProducts[$index]: ${displayedProducts[index]}');
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تمت إزالة المنتج من المحفوظات')),
          );
        }
      } else if (response.statusCode == 401) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('جلسة تسجيل الدخول انتهت، سجل دخول مرة أخرى')),
          );
        }
      } else {
        debugPrint('Failed to delete saved product: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل في إزالة المنتج')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error removing saved product: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ أثناء إزالة المنتج')),
        );
      }
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBC3D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCBC3D6),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/images/back (1).png'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TextField(
          controller: searchController,
          onChanged: (query) {
            _fetchProducts(search: query.isEmpty ? null : query);
          },
          decoration: const InputDecoration(
            hintText: 'Search...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Color(0xFF8D7D97)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedProductsScreen()),
              );
            },
          ),
          IconButton(
            icon: Image.asset(
                'assets/images/Add.png'), // Changed to custom Add image
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateScreen()),
              );
              if (result == true) {
                setState(() {
                  displayedProducts = [];
                  isRefreshing = true;
                });
                await _fetchProducts(pageIndex: 1);
                setState(() {
                  isRefreshing = false;
                });
              }
            },
          ),
          IconButton(
            icon:
                Image.asset('assets/images/Vector.png', width: 30, height: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyProductsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              setState(() {
                displayedProducts = [];
                isRefreshing = true;
              });
              await _fetchProducts(pageIndex: 1);
              setState(() {
                isRefreshing = false;
              });
            },
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : displayedProducts.isEmpty
                        ? Center(
                            child: Text(
                              searchController.text.isNotEmpty
                                  ? 'لا توجد منتجات مطابقة لـ "${searchController.text}"'
                                  : 'لا توجد منتجات لعرضها',
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(10),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: displayedProducts.length,
                            itemBuilder: (context, index) {
                              final product = displayedProducts[index];
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(15),
                                          ),
                                          child: product['image'].isEmpty
                                              ? const Icon(
                                                  Icons.image_not_supported,
                                                  size: 50)
                                              : Image.network(
                                                  product['image'],
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    debugPrint(
                                                        'Error loading image: $error');
                                                    return const Icon(
                                                        Icons.broken_image,
                                                        size: 50);
                                                  },
                                                ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product['title'],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              product['state'],
                                              style: const TextStyle(
                                                  color: Colors.grey),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  product[
                                                      'price'], // Formatted price
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                isSaving
                                                    ? const CircularProgressIndicator(
                                                        strokeWidth: 2)
                                                    : IconButton(
                                                        icon: Icon(
                                                          product['isSaved']
                                                              ? Icons.favorite
                                                              : Icons
                                                                  .favorite_border,
                                                          color: product[
                                                                  'isSaved']
                                                              ? const Color(
                                                                  0xFF8D7D97)
                                                              : null,
                                                        ),
                                                        onPressed: () async {
                                                          debugPrint(
                                                              'Before action: Product ${product['id']} isSaved: ${product['isSaved']}');
                                                          if (product[
                                                              'isSaved']) {
                                                            await _removeSavedProduct(
                                                                product);
                                                          } else {
                                                            await _saveProduct(
                                                                product);
                                                          }
                                                          debugPrint(
                                                              'After action: Product ${product['id']} isSaved: ${product['isSaved']}');
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
          if (isRefreshing)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF8D7D9D),
        selectedItemColor: const Color(0xFFCBC3D6),
        unselectedItemColor: const Color(0xFFCBC3D6),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CommunityChatScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MomsGuideScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => VoiceRecognitionScreen()),
              );
              break;
            case 4:
              // Already on MarketplaceScreen
              break;
            case 5:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: ''),
          BottomNavigationBarItem(
            icon: _HomeIcon(),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}

class _HomeIcon extends StatelessWidget {
  const _HomeIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFFCBC3D6),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.shopping_cart,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
