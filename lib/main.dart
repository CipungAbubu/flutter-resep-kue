import 'package:flutter/material.dart'; // Mengimpor paket Flutter untuk membangun antarmuka pengguna
import 'recipe_service.dart'; // Mengimpor layanan untuk mengambil data resep
import 'dart:convert'; // Mengimpor pustaka untuk mengonversi data JSON
import 'package:http/http.dart'
    as http; // Mengimpor pustaka HTTP untuk melakukan permintaan jaringan

import 'package:shared_preferences/shared_preferences.dart'; // Mengimpor pustaka untuk menyimpan data lokal
import 'package:url_launcher/url_launcher.dart'; // Mengimpor pustaka untuk membuka URL di browser

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
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(backgroundColor: Colors.deepOrange.shade900),
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false, // Menghilangkan tulisan "debug"
      home:
          const SplashScreen(), // Menampilkan halaman awal aplikasi (SplashScreen)
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 8), () {
      Navigator.pushReplacement( //// Mengganti halaman saat ini dengan HomeScreen
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()), // Rute untuk HomeScreen
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo.png',
            width: 250,
            height: 250,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState(); // Membuat state untuk HomeScreen
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>>
  _recipes; // Variabel untuk menyimpan daftar resep

  @override
  void initState() {
    super.initState();
    _recipes =
        RecipeService.fetchDesserts(); // Mengambil data resep saat inisialisasi
  }

  // Widget untuk header aplikasi
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Cakepediaa',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange.shade700,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.favorite,
              size: 28,
              color: Colors.black87,
            ),
            onPressed: () {
              // Logika untuk navigasi ke halaman favorit
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoriteRecipesPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan gambar yang di halaman home itu
  Widget _buildGridImages() {
    // Daftar gambar contoh dengan jalur dan bahan
    final sampleImages = [
      {'path': 'assets/images/kue1.jpg', 'ingredients': 'Chocolate'},
      {'path': 'assets/images/kue2.jpg', 'ingredients': 'Strawberry'},
      {'path': 'assets/images/kue3.jpg', 'ingredients': 'Matcha'},
      {'path': 'assets/images/kue4.jpg', 'ingredients': 'Cream Cheese'},
      {'path': 'assets/images/kue5.jpg', 'ingredients': 'Almond'},
      {'path': 'assets/images/kue6.jpg', 'ingredients': 'Lemon'},
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              'Populer Ingredients', // Judul bagian
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
            children:
                sampleImages
                    .map(
                      (img) => GestureDetector(
                        onTap: () {
                          // Navigasi ke halaman detail bahan
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => IngredientDetailPage(
                                    ingredient: img['ingredients']!, // Mengirimkan bahan ke halaman detail
                                  ),
                            ),
                          );
                        },
                        child: Stack(
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
                                        BlendMode.darken,
                                      ),
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
                        ),
                      ),
                    )
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
        itemCount: recipes.length.clamp(
          0,
          10,
        ), // Mengatur jumlah item yang ditampilkan
        itemBuilder: (context, index) {
          final recipe = recipes[index]; // Mengambil resep berdasarkan index
          return GestureDetector(
            onTap: () {
              Navigator.push(
                // Navigasi ke halaman detail resep saat ingin menge klik masing2 daftar resep
                context,
                MaterialPageRoute(
                  builder:
                      (context) => RecipeDetailPage(idMeal: recipe['idMeal']),
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
                  ),
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
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_rounded),
          label: 'All Recipes',
        ),
      ],
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            // Navigasi ke RecipeListPage saat ikon "all recipe" di klik
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
      bottomNavigationBar: _buildBottomNavigation(), // Menampilkan navigasi di bagian bawah
      body: SafeArea(
        child: SingleChildScrollView( // Memungkinkan konten untuk digulir
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _recipes, // Mengambil data resep dari future
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasError) {
                // Menampilkan pesan error jika terjadi kesalahan
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                // Menampilkan pesan jika tidak ada data
                return const Center(child: Text('Data kosong'));
              } else {
                final recipes = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(), // Menampilkan header aplikasi
                    _buildGridImages(), // Menampilkan gambar bahan
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text(
                        'Most Viewed Recipes', // Judul untuk resep yang paling banyak dilihat
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildFamousRecipesSlider(recipes), // Menampilkan slider resep terkenal
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

// Konstruktor untuk halaman resep favorit
class FavoriteRecipesPage extends StatelessWidget {
  const FavoriteRecipesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recipes'),
        backgroundColor: Colors.deepOrange,
      ),
      body: FutureBuilder<List<String>>(
        future: FavoriteRecipes.getFavorites(), // Mengambil daftar resep favorit
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Menampilkan indikator loading saat data sedang diambil
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Menampilkan pesan error jika terjadi kesalahan
            return Center(child: Text('Error: ${snapshot.error}'));
            // Menampilkan pesan jika tidak ada resep favorit
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No favorite recipes found.'));
          } else {
            final favorites = snapshot.data!; // Mengambil data resep favorit
            return ListView.builder(
              itemCount: favorites.length, // Jumlah item dalam daftar
              itemBuilder: (context, index) {
                final idMeal = favorites[index]; // Mengambil ID resep favorit
                return FutureBuilder<Map<String, dynamic>>(
                  future: fetchRecipeDetail(idMeal), // Ambil detail resep
                  builder: (context, recipeSnapshot) {
                    if (recipeSnapshot.connectionState ==
                        ConnectionState.waiting) {
                          // Menampilkan indikator loading saat detail resep sedang diambil
                      return const Center(child: CircularProgressIndicator());
                    } else if (recipeSnapshot.hasError) {
                      // Menampilkan pesan error jika terjadi kesalahan saat mengambil detail resep
                      return Center(
                        child: Text('Error: ${recipeSnapshot.error}'),
                      );
                    } else if (!recipeSnapshot.hasData) {
                      // Jika tidak ada data, kembalikan widget kosong
                      return const SizedBox.shrink(); 
                    } else {
                      // Jika tidak ada data, kembalikan widget kosong
                      final recipe = recipeSnapshot.data!;
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: InkWell(
                          onTap: () {
                            // Navigasi ke halaman detail resep saat kartu ditekan
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        RecipeDetailPage(idMeal: idMeal), // Rute untuk halaman detail resep
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                                child: Image.network(
                                  recipe['strMealThumb'], // Gambar resep
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 150,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  recipe['strMeal'], // Nama resep
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> fetchRecipeDetail(String idMeal) async {
     // Membuat URL endpoint dengan parameter idMeal
    final url = 'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$idMeal';

    // Melakukan HTTP GET request ke API TheMealDB
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) { // Jika request sukses (kode 200)
    // Mengubah response body dari JSON ke Map
      final data = json.decode(response.body);
      // Mengembalikan detail resep pertama dari array meals
      return data['meals'][0]; // Mengembalikan detail resep
    } else {
      throw Exception('Failed to load recipe detail');
    }
  }
}

class IngredientDetailPage extends StatelessWidget {
  final String ingredient; // Menyimpan nama bahan yang diteruskan ke halaman

  const IngredientDetailPage({Key? key, required this.ingredient})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imagePath = ''; // Variabel untuk menyimpan jalur gambar
    List<String> funFacts = []; // Daftar fakta menarik tentang bahan
    List<String> usageTips = []; // Daftar tips penggunaan bahan
    List<String> types = []; // Daftar jenis bahan
    List<String> mustTryDesserts = []; // Daftar dessert yang harus dicoba
    List<String> dessertImages = []; // Daftar gambar dessert

    // Mengisi data berdasarkan bahan yang dipilih
    switch (ingredient) {
      case 'Chocolate':
        imagePath = 'assets/images/kue1.jpg';
        funFacts = [
          'Chocolate was once used as currency by the Aztecs.',
          'Dark chocolate is rich in antioxidants.',
          'White chocolate contains no cocoa solids.',
          'The word “chocolate” comes from the Aztec word xocolatl.',
          'Switzerland has the highest per capita chocolate consumption in the world.',
        ];
        usageTips = [
          'Use bittersweet chocolate for intense flavor.',
          'Always melt chocolate slowly to avoid burning.',
          'Add coffee to enhance chocolate flavor in cakes.',
          'Chop chocolate evenly for consistent melting.',
          'Store chocolate in a cool, dry place to prevent bloom.',
        ];
        types = [
          'Dark Chocolate',
          'Milk Chocolate',
          'White Chocolate',
          'Ruby Chocolate',
        ];
        mustTryDesserts = [
          'Chocolate Lava Cake',
          'Triple Chocolate Brownies',
          'Chocolate Mousse',
        ];
        dessertImages = [
          'assets/images/chocolate1.jpg',
          'assets/images/chocolate2.jpg',
          'assets/images/chocolate3.jpg',
        ];
        break;

      case 'Strawberry':
        imagePath = 'assets/images/kue2.jpg';
        funFacts = [
          'Strawberries are the only fruit with seeds on the outside.',
          'They are members of the rose family.',
          'Strawberries have more Vitamin C than oranges.',
          'There are over 600 varieties of strawberries.',
          'Ancient Romans used strawberries for medicinal purposes.',
        ];
        usageTips = [
          'Rinse strawberries just before use to keep them fresh.',
          'Slice and layer them for decorative topping.',
          'Macerate with sugar for a juicy texture.',
          'Combine with balsamic vinegar for an elevated taste.',
          'Freeze extra strawberries for smoothies and cakes.',
        ];
        types = ['June-bearing', 'Everbearing', 'Day-neutral'];
        mustTryDesserts = [
          'Strawberry Shortcake',
          'Strawberry Cheesecake',
          'Chocolate-Dipped Strawberries',
        ];
        dessertImages = [
          'assets/images/strawberry1.jpg',
          'assets/images/strawberry2.jpg',
          'assets/images/strawberry3.jpg',
        ];
        break;

      case 'Matcha':
        imagePath = 'assets/images/kue3.jpg';
        funFacts = [
          'Matcha is finely ground powdered green tea from Japan.',
          'Its packed with antioxidants, especially EGCG.',
          'Traditionally used in Japanese tea ceremonies.',
          'Provides a calm energy boost due to L-theanine.',
          'Matcha has a vibrant green color due to shade-grown leaves.',
        ];
        usageTips = [
          'Use culinary-grade matcha for baking.',
          'Sift matcha powder to avoid clumps.',
          'Pair with white chocolate or vanilla flavors.',
          'Store in an airtight container to preserve freshness.',
          'Use a bamboo whisk for traditional preparation.',
        ];
        types = ['Ceremonial Grade', 'Culinary Grade', 'Latte Grade'];
        mustTryDesserts = [
          'Matcha Tiramisu',
          'Matcha Swiss Roll',
          'Matcha Ice Cream',
        ];
        dessertImages = [
          'assets/images/matcha1.jpg',
          'assets/images/matcha2.jpg',
          'assets/images/matcha3.jpg',
        ];
        break;

      case 'Cream Cheese':
        imagePath = 'assets/images/kue4.jpg';
        funFacts = [
          'Cream cheese was invented in New York in the 1870s.',
          'Its a staple in both sweet and savory dishes.',
          'Philadelphia is the most famous cream cheese brand.',
          'Contains at least 33% milk fat.',
          'Its commonly used in frosting and cheesecake.',
        ];
        usageTips = [
          'Soften before mixing for smooth texture.',
          'Blend with powdered sugar for icing.',
          'Use full-fat for best flavor in desserts.',
          'Pair with berries for a sweet-tart combo.',
          'Chill cheesecakes overnight for firm texture.',
        ];
        types = ['Regular', 'Whipped', 'Flavored(Garlic, Herb, Strawberry)'];
        mustTryDesserts = [
          'New York Cheesecake',
          'Red Velvet Cupcake with Cream Cheese Frosting',
          'Cream Cheese Swirl Brownies',
        ];
        dessertImages = [
          'assets/images/cream1.jpg',
          'assets/images/cream2.jpg',
          'assets/images/cream3.jpg',
        ];
        break;

      case 'Almond':
        imagePath = 'assets/images/kue5.jpg';
        funFacts = [
          'Almonds are seeds, not true nuts.',
          'California produces 80% of the worlds almonds.',
          'Almonds are high in vitamin E.',
          'They help give baked goods a nutty crunch.',
          'Almond flour is great for gluten-free baking.',
        ];
        usageTips = [
          'Toast before use for richer flavor.',
          'Slice or sliver for topping.',
          'Use almond flour for cookies.',
          'Blend into almond milk.',
          'Combine with honey for bars.',
        ];
        types = [
          'Raw Almonds',
          'Roasted Almonds',
          'Almond Flour',
          'Almond Paste',
        ];
        mustTryDesserts = [
          'Almond Tart',
          'Almond Biscotti',
          'Almond Croissant',
        ];
        dessertImages = [
          'assets/images/almond1.jpg',
          'assets/images/almond2.jpg',
          'assets/images/almond3.jpg',
        ];
        break;

      case 'Lemon':
        imagePath = 'assets/images/kue6.jpg';
        funFacts = [
          'Lemons float in water while limes sink.',
          'One lemon contains over 30mg of Vitamin C.',
          'Zest contains strong lemon oils.',
          'Used to balance sweetness in desserts.',
          'Lemon juice can prevent fruit from browning.',
        ];
        usageTips = [
          'Use zest for more flavor than juice.',
          'Balance sugar with lemon juice.',
          'Add lemon to icing for freshness.',
          'Use lemon juice in curds or glazes.',
          'Mix with berries for vibrant desserts.',
        ];
        types = ['Eureka', 'Meyer Lemon', 'Lisbon'];
        mustTryDesserts = [
          'Lemon Tart',
          'Lemon Meringue Pie',
          'Lemon Pound Cake',
        ];
        dessertImages = [
          'assets/images/lemon1.jpg',
          'assets/images/lemon2.jpg',
          'assets/images/lemon3.jpg',
        ];
        break;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gambar besar dengan tombol kembali
            Stack(
              children: [
                Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 300, // Mengatur tinggi gambar
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // Kembali ke halaman sebelumnya
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Judul
            Text(
              ingredient,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Fun Facts
            Text(
              '🍀 Fun Facts:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            ...funFacts.map((fact) => Text('• $fact')).toList(),
            const SizedBox(height: 16),
            // Usage Tips
            Text(
              '💡 Usage Tips:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            ...usageTips.map((tip) => Text('• $tip')).toList(),
            const SizedBox(height: 16),
            // Types
            Text(
              '🍫 Types of $ingredient:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: types.map((type) => Chip(label: Text(type))).toList(),
            ),
            const SizedBox(height: 16),
            // Must-Try Desserts
            Text(
              '🍰 Must-Try Desserts:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Column(
              children:
                  mustTryDesserts.asMap().entries.map((entry) {
                    int index = entry.key;
                    String dessert = entry.value;
                    return ListTile(
                      leading: Image.asset(
                        dessertImages[index],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(dessert),
                    );
                  }).toList(),
            ),
          ],
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
            return const Center(
              child: CircularProgressIndicator(),
            ); // Menampilkan indikator loading
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            ); // Menampilkan pesan error
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Tidak ada data'),
            ); // Menampilkan pesan jika tidak ada data
          } else {
            final recipes = snapshot.data!; // Mengambil data resep
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Jumlah kolom
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.65, // Rasio aspek untuk card
              ),
              padding: const EdgeInsets.all(8.0),
              itemCount: recipes.length, // Jumlah item dalam daftar
              itemBuilder: (context, index) {
                final recipe =
                    recipes[index]; // Mengambil resep berdasarkan index
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                          child: Image.network(
                            recipe['strMealThumb'], // Mengambil gambar resep dari URL
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          recipe['strMeal'], // Menampilkan nama resep
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                        ), // Padding vertikal untuk tombol
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigasi ke halaman detail resep saat tombol ditekan
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => RecipeDetailPage(
                                        idMeal: recipe['idMeal'],
                                      ),
                                ),
                              );
                            },
                            child: const Text(
                              'See Recipe',
                              style: TextStyle(fontSize: 12),
                            ), // Ukuran font tombol
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ), // Padding tombol
                              backgroundColor:
                                  Colors
                                      .deepOrange, // Warna latar belakang tombol
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
  final String idMeal;

  const RecipeDetailPage({Key? key, required this.idMeal}) : super(key: key);

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  Map<String, dynamic>? recipe; // Variabel untuk menyimpan detail resep
  bool isLoading = true; // Status loading
  bool isFavorite = false; // Deklarasi variabel

  @override
  void initState() {
    super.initState();
    fetchRecipeDetail(); // Mengambil detail resep saat inisialisasi
    checkIfFavorite();
  }

  Future<void> checkIfFavorite() async {
    List<String> favorites = await FavoriteRecipes.getFavorites();
    setState(() {
      isFavorite = favorites.contains(widget.idMeal);
    });
  }

  Future<void> toggleFavorite() async {
    if (isFavorite) {
      await FavoriteRecipes.removeFavorite(widget.idMeal);
    } else {
      await FavoriteRecipes.addFavorite(widget.idMeal);
    }
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  Future<void> fetchRecipeDetail() async {
    final url =
        'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.idMeal}'; // URL untuk mengambil detail resep
    final response = await http.get(
      Uri.parse(url),
    ); // Melakukan permintaan HTTP

    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Mengonversi data JSON
      setState(() {
        recipe = data['meals'][0]; // Menyimpan detail resep
        isLoading = false; // Mengubah status loading
      });
    } else {
      throw Exception(
        'Failed to load recipe detail',
      ); // Menangani error jika permintaan gagal
    }
  }

  // Fungsi untuk menghitung bahan berdasarkan porsi
  String calculateIngredient(String ingredient, String measure) {
    if (ingredient.isEmpty || measure.isEmpty) return '';

    // Mengambil nilai asli dari ukuran
    double originalAmount = 0.0;

    // Cek apakah measure adalah angka atau bukan
    final parts = measure.split(' ');
    if (parts.isNotEmpty && double.tryParse(parts[0]) != null) {
      originalAmount = double.parse(parts[0]);
    } else {
      return measure; // Kembalikan ukuran asli
    }

    // Hitung jumlah yang disesuaikan berdasarkan porsi
    double adjustedAmount = originalAmount; // Tidak ada penyesuaian porsi
    return '${adjustedAmount.toStringAsFixed(2)} ${parts.sublist(1).join(' ')}'; // Mengembalikan jumlah yang sudah disesuaikan dengan satuan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Menampilkan indikator loading
          : SingleChildScrollView(
              // Membungkus seluruh konten dengan SingleChildScrollView
              child: Column(
                children: [
                  // Gambar besar
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        child: Image.network(
                          recipe!['strMealThumb'], // Mengambil gambar resep dari URL
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Tombol kembali dan ikon simpan
                      Positioned(
                        top: 40,
                        left: 16,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(
                              context,
                            ); // Kembali ke halaman sebelumnya
                          },
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 16,
                        child: IconButton(
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.white,
                          ),
                          onPressed: toggleFavorite, // Panggil fungsi toggle
                        ),
                      ),
                    ],
                  ),
                  // Konten di bawah gambar
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe!['strMeal'], // Menampilkan nama resep
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A delicious cake made with love and care.', // Deskripsi singkat
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Cooking Time:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text('2 hours'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Divider(),
                        const Text(
                          'Ingredients:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...List.generate(20, (i) {
                          final ingredient =
                              recipe!['strIngredient${i + 1}']; // Mengambil bahan
                          final measure =
                              recipe!['strMeasure${i + 1}']; // Mengambil ukuran bahan
                          if (ingredient != null &&
                              ingredient.isNotEmpty &&
                              measure != null &&
                              measure.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${calculateIngredient(ingredient, measure)}', // Menghitung bahan
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    ingredient,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const SizedBox.shrink(); // Mengembalikan widget kosong jika tidak ada bahan
                          }
                        }),
                        const SizedBox(height: 16),
                        const Text(
                          'Instructions:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Menampilkan instruksi tanpa pengulangan
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            recipe!['strInstructions'] ??
                                'No instructions available.',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Menambahkan bagian Nutrisi
                        const Text(
                          'Nutritional Information:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Contoh informasi nutrisi
                        Text('Calories: 250 kcal', style: const TextStyle(fontSize: 16)),
                        Text('Protein: 5g', style: const TextStyle(fontSize: 16)),
                        Text('Fat: 10g', style: const TextStyle(fontSize: 16)),
                        Text('Carbohydrates: 35g', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        // Tombol untuk mengarahkan ke link resep
                        ElevatedButton(
                          onPressed: () {
                            final recipeLink = recipe!['strSource'] ?? ''; // Ambil link resep
                            if (recipeLink.isNotEmpty) {
                              launch(recipeLink); // Menggunakan package url_launcher untuk membuka link
                            }
                          },
                          child: const Text('View Full Recipe'),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class FavoriteRecipes {
  // Menambahkan resep ke daftar favorit
  static Future<void> addFavorite(String idMeal) async {
    final prefs = await SharedPreferences.getInstance(); // Mengambil instance SharedPreferences
    List<String> favorites = prefs.getStringList('favorites') ?? []; // Mengambil daftar favorit yang ada, atau membuat daftar kosong
    if (!favorites.contains(idMeal)) { // Memeriksa apakah idMeal sudah ada dalam daftar
      favorites.add(idMeal); // Menambahkan idMeal ke daftar favorit
      await prefs.setStringList('favorites', favorites); // Menyimpan daftar favorit yang diperbarui
    }
  }

  // Menghapus resep dari daftar favorit
  static Future<void> removeFavorite(String idMeal) async {
    final prefs = await SharedPreferences.getInstance(); // Mengambil instance SharedPreferences
    List<String> favorites = prefs.getStringList('favorites') ?? []; // Mengambil daftar favorit yang ada
    favorites.remove(idMeal); // Menghapus idMeal dari daftar favorit
    await prefs.setStringList('favorites', favorites); // Menyimpan daftar favorit yang diperbarui
  }

  // Mengambil daftar resep favorit
  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance(); // Mengambil instance SharedPreferences
    return prefs.getStringList('favorites') ?? []; // Mengembalikan daftar favorit, atau daftar kosong jika tidak ada
  }
}
