import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api_handler/products.dart';

class ManageProduct extends StatefulWidget {
  final String token;
  const ManageProduct({super.key, required this.token});

  @override
  State<StatefulWidget> createState() {
    return _StateManage();
  }
}

class _StateManage extends State<ManageProduct> {
  late ProductHandler _productHandler;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: '');
  final priceController = TextEditingController(text: '');
  final descriptionController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    _productHandler = ProductHandler(token: widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Produk")),
      body: 
        SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text("Nama"),
              TextFormField(
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan nama produk';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Masukkan nama produk",
                ),
              ),
              const SizedBox(height: 20),
              const Text("Harga"),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan harga produk';
                  }
                  return null;
                },
                controller: priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')), // Only allows 0-9
                ],
                decoration: InputDecoration(
                  hintText: "Masukkan harga satuan produk",
                ),
              ),
              const SizedBox(height: 20),
              const Text("Deskripsi"),
              TextFormField(
                controller: descriptionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan deskripsi produk';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Masukkan deskripsi produk",
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var messager = ScaffoldMessenger.of(
                      context,
                    ); // Capture before await
                    final navigator = Navigator.of(context);
                    final bool result = await _productHandler.createProduct(
                      nameController.text,
                      double.parse(priceController.text),
                      descriptionController.text,
                    );
                    if (result) {
                      navigator.pop("Berhasil menambahkan data");
                    } else {
                      messager.showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            'Gagal Menambahkan Product. Periksa Data Product',
                          ),
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  "Tambahkan",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ],
          ),
        ), 
      ),
    );
  }
}
