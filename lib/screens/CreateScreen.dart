import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // للجوال
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // للتحقق من المنصة
import 'dart:html' as html; // للويب

class CreateScreen extends StatefulWidget {
  const CreateScreen({Key? key}) : super(key: key);

  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  File? _image;
  String? _imageUrl; // سيتم استخدامها لعرض الصورة على الويب
  final picker = ImagePicker();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          // تحويل الصورة إلى رابط على الويب
          final bytes = await pickedFile.readAsBytes();
          final blob = html.Blob([bytes], 'image/png');
          final url = html.Url.createObjectUrlFromBlob(blob);
          setState(() {
            _imageUrl = url;
          });
        } else {
          // للجوال
          setState(() {
            _image = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    setState(() {
      _isLoading = true;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You need to login first')),
          );
        }
        return;
      }

      if (kIsWeb) {
        // كود خاص بالويب
        await _uploadProductWeb(token);
      } else {
        // كود خاص بالجوال
        await _uploadProductMobile(token);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadProductMobile(String token) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://momshood.runasp.net/api/Products'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['Title'] = titleController.text;
    request.fields['State'] = stateController.text;
    request.fields['Price'] = priceController.text;
    request.fields['PhoneNumber'] = phoneController.text;
    request.fields['WhatsappNumber'] = whatsappController.text;
    request.fields['Details'] = detailsController.text;
    request.fields['IsLove'] = 'true'; // اختياري

    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('ImageFile', _image!.path),
      );
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added successfully!')),
        );
        Navigator.pop(context);
      }
    } else {
      var responseBody = await response.stream.bytesToString();
      debugPrint(responseBody); // استخدم debugPrint بدلاً من print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product')),
        );
      }
    }
  }

  Future<void> _uploadProductWeb(String token) async {
    // كود خاص بالويب
    if (_imageUrl == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an image')),
        );
      }
      return;
    }

    // تحويل الصورة إلى bytes
    final bytes =
        await html.HttpRequest.request(_imageUrl!, responseType: 'arraybuffer')
            .then((request) => request.response as ByteBuffer)
            .then((buffer) => buffer.asUint8List());

    // إنشاء FormData
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://momshood.runasp.net/api/Products'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['Title'] = titleController.text;
    request.fields['State'] = stateController.text;
    request.fields['Price'] = priceController.text;
    request.fields['PhoneNumber'] = phoneController.text;
    request.fields['WhatsappNumber'] = whatsappController.text;
    request.fields['Details'] = detailsController.text;
    request.fields['IsLove'] = 'true'; // اختياري

    // إضافة الصورة كملف
    request.files.add(http.MultipartFile.fromBytes(
      'ImageFile',
      bytes,
      filename: 'image.png', // يمكنك تغيير اسم الملف
    ));

    var response = await request.send();

    if (response.statusCode == 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added successfully!')),
        );
        Navigator.pop(context);
      }
    } else {
      var responseBody = await response.stream.bytesToString();
      debugPrint(responseBody); // استخدم debugPrint بدلاً من print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff8D7D97),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 0),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Image.asset('assets/images/back (1).png',
                    width: 30, height: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Image.asset('assets/images/Rectangle 26.png', height: 150),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTextField(
                      'Product Title', 'Product title', titleController),
                  _buildTextField(
                      'Product State', 'Product state', stateController),
                  _buildTextField(
                      'Product Price', '0.00\$ product price', priceController),
                  _buildTextField('Phone', '+20 phone number', phoneController),
                  _buildTextField(
                      'WhatsApp', '+20 whatsapp number', whatsappController),
                  _buildTextField(
                      'Details', 'Product details', detailsController,
                      maxLines: 3),
                  const SizedBox(height: 10),
                  _image != null
                      ? kIsWeb
                          ? Image.network(_imageUrl!, height: 100) // للويب
                          : Image.file(_image!, height: 100) // للجوال
                      : _buildButton('Upload Image', const Color(0xff8D7D97),
                          Colors.white, _pickImage),
                  const SizedBox(height: 20),
                  if (_isLoading) const CircularProgressIndicator(),
                  if (!_isLoading)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildButton('Save', const Color(0xff8D7D97),
                              Colors.white, _saveProduct),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildButton(
                              'Cancel', const Color(0xff8D7D97), Colors.white,
                              () {
                            Navigator.pop(context);
                          }),
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
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildButton(
      String text, Color color, Color textColor, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}
/*import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateScreen extends StatefulWidget {
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  File? _image;
  final picker = ImagePicker();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _saveProduct() async {
    setState(() {
      _isLoading = true;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://localhost:7054/api/Products'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['Title'] = titleController.text;
      request.fields['State'] = stateController.text;
      request.fields['Price'] = priceController.text;
      request.fields['PhoneNumber'] = phoneController.text;
      request.fields['WhatsappNumber'] = whatsappController.text;
      request.fields['Details'] = detailsController.text;
      request.fields['IsLove'] = 'true'; // اختياري

      if (_image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('ImageFile', _image!.path),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added successfully!')),
        );
        Navigator.pop(context);
      } else {
        var responseBody = await response.stream.bytesToString();
        print(responseBody); // لطباعة تفاصيل الخطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff8D7D97),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 0),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Image.asset('assets/images/back (1).png',
                    width: 30, height: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Image.asset('assets/images/Rectangle 26.png', height: 150),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ), // تم إغلاق BoxDecoration هنا
              padding: EdgeInsets.all(20), // تم إضافة padding هنا
              child: Column(
                children: [
                  _buildTextField(
                      'Product Title', 'Product title', titleController),
                  _buildTextField(
                      'Product State', 'Product state', stateController),
                  _buildTextField(
                      'Product Price', '0.00\$ product price', priceController),
                  _buildTextField('Phone', '+20 phone number', phoneController),
                  _buildTextField(
                      'WhatsApp', '+20 whatsapp number', whatsappController),
                  _buildTextField(
                      'Details', 'Product details', detailsController,
                      maxLines: 3),
                  SizedBox(height: 10),
                  _image != null
                      ? Image.network(_image!.path,
                          height: 100) // استخدم Image.network
                      : _buildButton('Upload Image', Color(0xff8D7D97),
                          Colors.white, _pickImage),
                  SizedBox(height: 20),
                  if (_isLoading) CircularProgressIndicator(),
                  if (!_isLoading)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildButton('Save', Color(0xff8D7D97),
                              Colors.white, _saveProduct),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _buildButton(
                              'Cancel', Color(0xff8D7D97), Colors.white, () {
                            Navigator.pop(context);
                          }),
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
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildButton(
      String text, Color color, Color textColor, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: Size(double.infinity, 50),
      ),
      child: Text(text, style: TextStyle(fontSize: 16)),
    );
  }
}*/
/*import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'MarketplaceScreen.dart';
//import 'market_screen.dart'; // تأكد من استيراد شاشة السوق

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    final url = Uri.parse('https://localhost:7054/api/Products');
    final request = http.MultipartRequest('POST', url);

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      image.path,
    ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);
      return jsonResponse['imageUrl'];
    } else {
      return null;
    }
  }

  void _addProduct() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    final imageUrl = await _uploadImage(_image!);

    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
      return;
    }

    final productData = {
      'title': _titleController.text,
      'state': _stateController.text,
      'phoneNumber': _phoneController.text,
      'whatsappNumber': _whatsappController.text,
      'price': double.parse(_priceController.text),
      'isLove': true,
      'details': _detailsController.text,
      'imageUrl': imageUrl,
    };

    // إضافة المنتج إلى الخادم
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to login first')),
      );
      return;
    }

    final String url = 'https://localhost:7054/api/Products';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // إضافة الصورة
      request.files.add(await http.MultipartFile.fromPath(
        'ImageFile',
        _image!.path,
      ));

      // إضافة الحقول الأخرى
      request.fields['Title'] = productData['title'];
      request.fields['State'] = productData['state'];
      request.fields['PhoneNumber'] = productData['phoneNumber'];
      request.fields['WhatsappNumber'] = productData['whatsappNumber'];
      request.fields['Price'] = productData['price'].toString();
      request.fields['IsLove'] = productData['isLove'].toString();
      request.fields['Details'] = productData['details'];

      // إضافة التوكن
      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );

        // الانتقال إلى شاشة السوق
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MarketScreen(),
          ),
        );
      } else {
        throw Exception('Failed to add product');
      }
    } catch (e) {
      print('Error adding product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add product')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              TextField(
                controller: _whatsappController,
                decoration: const InputDecoration(labelText: 'Whatsapp Number'),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _detailsController,
                decoration: const InputDecoration(labelText: 'Details'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _image == null
                  ? ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Pick Image'),
                    )
                  : Image.network(_image!
                      .path), // استخدام Image.network بدلاً من Image.file
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addProduct,
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
