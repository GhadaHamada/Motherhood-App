import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:intl/intl.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  EditProductScreen({required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color _primaryColor = Color(0xFF8D7D9D);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();

  File? _newImageFile;
  Uint8List? _imageBytes;
  String? _imageUrl;
  bool _isLoading = false;
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    _titleController.text =
        widget.product['title'] ?? widget.product['name'] ?? '';
    _descriptionController.text =
        widget.product['details'] ?? widget.product['description'] ?? '';
    _priceController.text = widget.product['price']?.toString() ?? '';
    _stateController.text = widget.product['state'] ?? '';
    _phoneController.text = widget.product['phoneNumber'] ?? '';
    _whatsappController.text = widget.product['whatsappNumber'] ?? '';

    if (widget.product['pictureUrl'] != null) {
      _imageUrl = widget.product['pictureUrl'];
    }
    _fetchImage();
  }

  Future<void> _fetchImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse(
            'https://momshood.runasp.net/api/Products/image/${widget.product['id']}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _imageUrl =
              'https://momshood.runasp.net/api/Products/image/${widget.product['id']}';
        });
      } else {
        setState(() {
          _imageUrl = widget.product['pictureUrl'];
        });
      }
    } catch (e) {
      setState(() {
        _imageUrl = widget.product['pictureUrl'];
      });
      debugPrint('Error fetching image: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _imageBytes = bytes;
            _imageUrl = html.Url.createObjectUrlFromBlob(html.Blob([bytes]));
            _imageChanged = true;
          });
        } else {
          setState(() {
            _newImageFile = File(pickedFile.path);
            _imageChanged = true;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login first')),
        );
        return;
      }

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse(
            'https://momshood.runasp.net/api/Products/${widget.product['id']}'),
      )
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Content-Type'] = 'multipart/form-data'
        ..fields['Title'] = _titleController.text
        ..fields['Details'] = _descriptionController.text
        ..fields['Description'] = _descriptionController.text
        ..fields['State'] = _stateController.text
        ..fields['PhoneNumber'] = _phoneController.text
        ..fields['WhatsappNumber'] = _whatsappController.text
        ..fields['Price'] = _priceController.text
            .replaceAll('EGP ', '')
            .replaceAll('\$', '')
            .trim()
        ..fields['IsLove'] = 'true';

      if (_imageChanged) {
        if (kIsWeb && _imageBytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'ImageFile',
            _imageBytes!,
            filename: 'product_${DateTime.now().millisecondsSinceEpoch}.png',
          ));
        } else if (!kIsWeb && _newImageFile != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'ImageFile',
            _newImageFile!.path,
          ));
        }
      } else {
        if (_imageUrl != null) {
          final oldImageResponse = await http.get(Uri.parse(_imageUrl!));
          if (oldImageResponse.statusCode == 200) {
            final oldImageBytes = oldImageResponse.bodyBytes;
            request.files.add(http.MultipartFile.fromBytes(
              'ImageFile',
              oldImageBytes,
              filename: 'existing_image.png',
            ));
          } else {
            print('فشل تحميل الصورة القديمة: ${oldImageResponse.statusCode}');
            throw Exception('فشل تحميل الصورة القديمة');
          }
        }
      }

      debugPrint('Request Fields: ${request.fields}');
      debugPrint('Request Files: ${request.files.map((f) => f.filename)}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint(
          'Update Product Response: Status ${response.statusCode}, Body: $responseBody');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product updated successfully!')),
        );
        Navigator.pop(context, true);
      } else {
        final errorData = jsonDecode(responseBody);
        final errorMsg = errorData['message'] ?? 'Failed to update product';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMsg (${response.statusCode})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      debugPrint('Error details: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon:
              Image.asset('assets/images/back (1).png', width: 30, height: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/images/Rectangle 26.png', height: 150),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildTextField('Product Title', 'Enter product title',
                          _titleController),
                      _buildTextField(
                          'State', 'Enter product state', _stateController),
                      _buildTextField('Price', 'Enter price', _priceController,
                          keyboardType: TextInputType.number),
                      _buildTextField(
                          'Phone', 'Enter phone number', _phoneController,
                          keyboardType: TextInputType.phone),
                      _buildTextField('WhatsApp', 'Enter WhatsApp number',
                          _whatsappController,
                          keyboardType: TextInputType.phone),
                      _buildTextField('Details', 'Enter product details',
                          _descriptionController,
                          maxLines: 5),
                      SizedBox(height: 20),
                      if (_imageUrl != null)
                        Container(
                          margin: EdgeInsets.only(bottom: 15),
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: _primaryColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: kIsWeb
                                ? Image.network(_imageUrl!, fit: BoxFit.cover)
                                : _newImageFile != null
                                    ? Image.file(_newImageFile!,
                                        fit: BoxFit.cover)
                                    : Image.network(_imageUrl!,
                                        fit: BoxFit.cover),
                          ),
                        ),
                      Container(
                        width: double.infinity,
                        child: _buildButton(
                          _imageChanged ? 'Image Selected' : 'Edit Image',
                          _primaryColor,
                          Colors.white,
                          _pickImage,
                        ),
                      ),
                      SizedBox(height: 25),
                      if (_isLoading)
                        CircularProgressIndicator(color: _primaryColor),
                      if (!_isLoading)
                        Row(
                          children: [
                            Expanded(
                              child: _buildButton('Save', _primaryColor,
                                  Colors.white, _updateProduct),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: _buildButton(
                                  'Cancel', _primaryColor, Colors.white, () {
                                Navigator.pop(context);
                              }),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController controller,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _primaryColor, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        minimumSize: Size(200, 60),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stateController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }
}

/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  EditProductScreen({required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _whatsappNumberController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // تعيين القيم الأولية للحقول من بيانات المنتج
    _titleController.text = widget.product['title'];
    _descriptionController.text = widget.product['description'];
    _priceController.text = widget.product['price'].toString();
    _stateController.text = widget.product['state'];
    _phoneNumberController.text = widget.product['phoneNumber'];
    _whatsappNumberController.text = widget.product['whatsappNumber'];
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
        );
        return;
      }

      final url = Uri.parse(
          'https://localhost:7054/api/Products/${widget.product['id']}');

      final request = http.MultipartRequest('PUT', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['Title'] = _titleController.text
        ..fields['State'] = _stateController.text
        ..fields['PhoneNumber'] = _phoneNumberController.text
        ..fields['WhatsappNumber'] = _whatsappNumberController.text
        ..fields['Price'] = _priceController.text
        ..fields['Details'] = _descriptionController.text
        ..fields['IsLove'] = 'true'; // يمكن تعديله حسب الحاجة

      try {
        final response = await request.send();

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تحديث المنتج بنجاح')),
          );
          Navigator.pop(
              context, true); // العودة للصفحة السابقة مع تحديث البيانات
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('فشل في تحديث المنتج: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a title';
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a description';
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a price';
                  return null;
                },
              ),
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(labelText: 'State'),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a state';
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a phone number';
                  return null;
                },
              ),
              TextFormField(
                controller: _whatsappNumberController,
                decoration: InputDecoration(labelText: 'WhatsApp Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a WhatsApp number';
                  return null;
                },
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _updateProduct,
                      child: Text('Update Product'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
