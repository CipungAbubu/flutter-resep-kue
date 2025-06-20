import 'package:flutter/material.dart';
import 'recipe_service.dart'; // Mengimpor layanan untuk mengambil data resep
import 'dart:convert'; // Mengimpor pustaka untuk mengonversi data JSON
import 'package:http/http.dart' as http; // Mengimpor pustaka HTTP untuk melakukan permintaan jaringan

void main() {
  runApp(const MyApp()); // Menjalankan aplikasi
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cakepediaa', //judul aplikasi
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false, // Menghilangkan tulisan "debug"
      home: const SplashScreen(), // Menampilkan halaman awal aplikasi (SplashScreen)
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedRotation(
              turns: 1,
              duration: const Duration(seconds: 2),
              child: const Icon(
                Icons.cake_rounded,
                size: 100,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cakepediaa',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Welcome to Cakepediaa!',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 5),
            const Text(
              'Discover a variety of delicious cake recipes here~',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Navigasi ke HomeScreen saat tombol "start" di klik
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              child: const Text('Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _recipes; // Variabel untuk menyimpan daftar resep

  @override
  void initState() {
    super.initState();
    _recipes = RecipeService.fetchDesserts(); // Mengambil data resep saat inisialisasi
  }
  
  // Widget untuk header aplikasi
  Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.cake_rounded, size: 32, color: Colors.deepOrange),
            const SizedBox(width: 10),
            Text(
              'Cakepediaa',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange.shade700,
              ),
            ),
          ],
        ),
        const Icon(Icons.bookmark, size: 28, color: Colors.black87), // Ganti ikon di sini
      ],
    ),
  );
}
  
  // Widget untuk kolom pencarian
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for cake recipes...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan gambar yang di halaman home itu
  Widget _buildGridImages() {
    final sampleImages = [
      {'path': 'assets/images/kue1.jpg', 'ingredients': 'Chocolate'},
      {'path': 'assets/images/kue2.jpg', 'ingredients': 'Banana'},
      {'path': 'assets/images/kue3.jpg', 'ingredients': 'Butter'},
      {'path': 'assets/images/kue4.jpg', 'ingredients': 'Eggs'},
      {'path': 'assets/images/kue5.jpg', 'ingredients': 'Milk'},
      {'path': 'assets/images/kue6.jpg', 'ingredients': 'Flour'},
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              'Populer Ingredients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3.0,
            children: sampleImages
                .map((img) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 70,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: AssetImage(img['path']!),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.3),
                                      BlendMode.darken),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Text(
                            img['ingredients']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // Widget untuk membuat scroll slider beberapa daftar resep kue yang banyak di lihat
  Widget _buildFamousRecipesSlider(List<Map<String, dynamic>> recipes) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: recipes.length.clamp(0, 10), // Mengatur jumlah item yang ditampilkan
        itemBuilder: (context, index) {
          final recipe = recipes[index]; // Mengambil resep berdasarkan index
          return GestureDetector(
            onTap: () {
              Navigator.push( // Navigasi ke halaman detail resep saat ingin menge klik masing2 daftar resep
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailPage(idMeal: recipe['idMeal']),
                ),
              );
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      recipe['strMealThumb'], // Mengambil gambar resep dari URL
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recipe['strMeal'], // Menampilkan nama resep
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget untuk menampilkan navigasi bagian bawah
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      selectedItemColor: Colors.deepOrange,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_rounded),
          label: 'All Recipes',
        ),
      ],
      onTap: (index) {
        if (index == 1) {
          Navigator.push( // Navigasi ke RecipeListPage saat ikon "all recipe" di klik
            context,
            MaterialPageRoute(builder: (context) => const RecipeListPage()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavigation(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _recipes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: CircularProgressIndicator(),
                ));
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('Data kosong'));
              } else {
                final recipes = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildSearchBar(),
                    _buildGridImages(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text(
                        'Most Viewed Recipes',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildFamousRecipesSlider(recipes),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class RecipeListPage extends StatelessWidget {
  const RecipeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Recipes'), // Judul halaman semua resep
        backgroundColor: Colors.deepOrange, // Warna latar belakang app bar
        foregroundColor: Colors.white, // Warna teks app bar
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: RecipeService.fetchDesserts(), // Mengambil data semua resep
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Menampilkan indikator loading
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Menampilkan pesan error
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data')); // Menampilkan pesan jika tidak ada data
          } else {
            final recipes = snapshot.data!; // Mengambil data resep
            return ListView.builder(
              itemCount: recipes.length, // Jumlah item dalam daftar
              itemBuilder: (context, index) {
                final recipe = recipes[index]; // Mengambil resep berdasarkan index
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8), // Sudut melengkung gambar
                    child: Image.network(
                      recipe['strMealThumb'], // Mengambil gambar resep dari URL
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(recipe['strMeal']), // Menampilkan nama resep
                  onTap: () {
                    // Navigasi ke halaman detail resep saat item ditekan
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailPage(idMeal: recipe['idMeal']),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class RecipeDetailPage extends StatefulWidget {
  final String idMeal; // ID resep yang akan ditampilkan

  const RecipeDetailPage({super.key, required this.idMeal});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  Map<String, dynamic>? recipe; // Variabel untuk menyimpan detail resep
  bool isLoading = true; // Status loading

  @override
  void initState() {
    super.initState();
    fetchRecipeDetail(); // Mengambil detail resep saat inisialisasi
  }

  Future<void> fetchRecipeDetail() async {
    final url =
        'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.idMeal}'; // URL untuk mengambil detail resep
    final response = await http.get(Uri.parse(url)); // Melakukan permintaan HTTP

    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Mengonversi data JSON
      setState(() {
        recipe = data['meals'][0]; // Menyimpan detail resep
        isLoading = false; // Mengubah status loading
      });
    } else {
      throw Exception('Failed to load recipe detail'); // Menangani error jika permintaan gagal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe?['strMeal'] ?? 'Loading...'), // Menampilkan nama resep atau loading
        backgroundColor: Colors.deepOrange, // Warna latar belakang app bar
        foregroundColor: Colors.white, // Warna teks app bar
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Menampilkan indikator loading
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Sudut melengkung gambar
                    child: Image.network(
                      recipe!['strMealThumb'], // Mengambil gambar resep dari URL
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    recipe!['strMeal'], // Menampilkan nama resep
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ingredients:', // Judul untuk bahan
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...List.generate(20, (i) {
                    final ingredient = recipe!['strIngredient${i + 1}']; // Mengambil bahan
                    final measure = recipe!['strMeasure${i + 1}']; // Mengambil ukuran bahan
                    if (ingredient != null &&
                        ingredient.isNotEmpty &&
                        measure != null &&
                        measure.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          '- $ingredient ($measure)', // Menampilkan bahan dan ukurannya
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink(); // Mengembalikan widget kosong jika tidak ada bahan
                    }
                  }),
                  const SizedBox(height: 16),
                  const Text(
                    'Instructions:', // Judul untuk instruksi
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe!['strInstructions'] ?? 'No instructions available.', // Menampilkan instruksi atau pesan jika tidak ada
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}