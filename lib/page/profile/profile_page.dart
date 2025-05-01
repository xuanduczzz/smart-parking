import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? avatarUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final doc = await FirebaseFirestore.instance
        .collection('user_customer')
        .doc(user.uid)
        .get();
    final data = doc.data();
    if (data != null) {
      nameController.text = data['name'] ?? '';
      phoneController.text = data['phone'] ?? '';
      emailController.text = data['email'] ?? '';
      avatarUrl = data['avatar'];
      setState(() {});
    }
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    final cloudName = 'dqnbclzi5';
    final uploadPreset = 'avatar_img';

    final url =
    Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    if (res.statusCode == 200) {
      final responseData = json.decode(res.body);
      return responseData['secure_url'];
    } else {
      print('Upload failed: ${res.body}');
      return null;
    }
  }

  Future<void> pickAndUploadImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => isLoading = true);
      final url = await uploadImageToCloudinary(File(pickedFile.path));
      if (url != null) {
        avatarUrl = url;
        setState(() {});
      }
      setState(() => isLoading = false);
    }
  }

  Future<void> updateProfile() async {
    setState(() => isLoading = true);

    await FirebaseFirestore.instance
        .collection('user_customer')
        .doc(user.uid)
        .set({
      'email': emailController.text.trim(),
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      if (avatarUrl != null) 'avatar': avatarUrl!,
    }, SetOptions(merge: true));

    setState(() => isLoading = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Cập nhật thành công!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thông tin cá nhân')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: pickAndUploadImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null
                      ? Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Tên hiển thị'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateProfile,
                child: Text('Lưu thay đổi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
