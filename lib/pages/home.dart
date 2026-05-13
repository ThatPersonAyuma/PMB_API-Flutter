import 'package:flutter/material.dart';
import 'package:pbm_api/api_handler/login.dart';
import 'package:pbm_api/api_handler/products.dart';
import 'package:pbm_api/api_handler/submit.dart';
import 'package:pbm_api/pages/login.dart';
import 'components/swipable_content.dart';
import 'manage_product.dart';

class HomePage extends StatelessWidget {
  final String name;
  final String token;
  final GlobalKey<_HomeState> homeKey = GlobalKey<_HomeState>();
  HomePage({super.key, required this.name, required this.token});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Selamat Datang $name')));
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: TextStyle(), overflow: TextOverflow.ellipsis),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: Column(
          // Important: Remove any padding from the ListView.
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(''),
            ),
            Expanded(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Submit Tugas'),
                    trailing: const Icon(Icons.assignment_turned_in),
                    onTap: () async {
                      String res = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          SubmitHandler handler = SubmitHandler();
                          return AlertDialog(
                            title: Text("Pengumpulan Tugas"),
                            content: Text(
                              "Apakah anda yakin ingin mengumpulkan tugas ini?\nDetail:\n1. Nama Pengguna: $name\n2. Nama Produk: ${handler.name}\n3. Harga: ${handler.price}\n4. Deskripsi: ${handler.description}\n5. Link GutHub: ${handler.githubUrl}\nPastikan Data sudah benar.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                    'Pengumpulan tugas dibatalkan',
                                  );
                                },
                                child: Text("Batalkan"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  bool res = await handler.submitTask(token);
                                  if (!context.mounted) {
                                    return;
                                  }
                                  if (res == true) {
                                    Navigator.pop(
                                      context,
                                      'Berhasil mengumpulkan tugas',
                                    );
                                  }
                                },
                                child: Text("Submit"),
                              ),
                            ],
                          );
                        },
                      );
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(res)));
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Log Out'),
              onTap: () async {
                await AuthHandler().logOut();
                if (!context.mounted) {
                  return;
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              trailing: const Icon(Icons.logout),
            ),
          ],
        ),
      ),
      body: HomeBody(key: homeKey, token: this.token),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManageProduct(token: token),
            ),
          );
          await homeKey.currentState?.refreshProducts();
          if (!context.mounted) {
            return;
          }
          if (result != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(result)));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class HomeBody extends StatefulWidget {
  final String token;
  const HomeBody({super.key, required this.token});
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomeBody> {
  late ProductHandler _productHandler;
  List<Product> products = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _productHandler = ProductHandler(token: widget.token);
    _loadProducts();
  }

  Future<void> refreshProducts() async {
    setState(() {
      _isLoading = true;
    });

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    List<Product>? products = await _productHandler.getDataProducts();
    if (!mounted) return;
    setState(() {
      this.products = products ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : (products.isNotEmpty
              ? buildProductsView()
              : const EmptyProduct());
  }

  Widget buildProductsView() {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return SlideMenu(
          menuItems: <Widget>[
            Container(
              color: Colors.black12,
              child: IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () {
                  print("Please Implement detail page");
                },
              ),
            ),
            Container(
              color: Colors.red,
              child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.delete),
                onPressed: () {
                  print("Please Implement delete method");
                },
              ),
            ),
          ],
          child: ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: Icon(Icons.shopping_cart, size: 36),
            title: Text(product.name),
            subtitle: Text(
              "Harga: ${product.price}\n${product.description}",
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            contentPadding: const EdgeInsets.only(left: 20),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}

class EmptyProduct extends StatelessWidget {
  const EmptyProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20,
      children: [
        Icon(Icons.do_not_disturb_alt_sharp, size: 100,),
        Text(
          "Belum Ada Produk\nCoba tambahkan produk dengan menekan tombol plus (+)",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
