import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


void main() {
  runApp(const QuoteGeneratorApp());
}

class QuoteGeneratorApp extends StatelessWidget {
  const QuoteGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Quote Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo accent
          brightness: Brightness.dark,
        ),
      ),
      home: const QuoteHomeScreen(),
    );
  }
}

// ==================== MODELS ====================

enum QuoteCategory { all, tech, leadership, mindset }

class Quote {
  final String id;
  final String text;
  final String author;
  final QuoteCategory category;
  final String bgImageUrl;

  const Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    required this.bgImageUrl,
  });
}

// ==================== MAIN HOME SCREEN ====================

class QuoteHomeScreen extends StatefulWidget {
  const QuoteHomeScreen({super.key});

  @override
  State<QuoteHomeScreen> createState() => _QuoteHomeScreenState();
}

class _QuoteHomeScreenState extends State<QuoteHomeScreen> {
  final List<Quote> _allQuotes = const [
    Quote(
      id: 'q1',
      text: "The only way to do great work is to love what you do.",
      author: "Steve Jobs",
      category: QuoteCategory.leadership,
      bgImageUrl: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1000",
    ),
    Quote(
      id: 'q2',
      text: "Talk is cheap. Show me the code.",
      author: "Linus Torvalds",
      category: QuoteCategory.tech,
      bgImageUrl: "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?q=80&w=1000",
    ),
    Quote(
      id: 'q3',
      text: "Strive not to be a success, but rather to be of value.",
      author: "Albert Einstein",
      category: QuoteCategory.mindset,
      bgImageUrl: "https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=1000",
    ),
    Quote(
      id: 'q4',
      text: "Code is like humor. When you have to explain it, it’s bad.",
      author: "Cory House",
      category: QuoteCategory.tech,
      bgImageUrl: "https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=1000",
    ),
    Quote(
      id: 'q5',
      text: "It always seems impossible until it's done.",
      author: "Nelson Mandela",
      category: QuoteCategory.mindset,
      bgImageUrl: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1000",
    ),
    Quote(
      id: 'q6',
      text: "Innovation distinguishes between a leader and a follower.",
      author: "Steve Jobs",
      category: QuoteCategory.leadership,
      bgImageUrl: "https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=1000",
    ),
    Quote(
      id: 'q7',
      text: "First, solve the problem. Then, write the code.",
      author: "John Johnson",
      category: QuoteCategory.tech,
      bgImageUrl: "https://images.unsplash.com/photo-1555066931-4365d14bab8c?q=80&w=1000",
    ),
  ];

  late Quote _currentQuote;
  final Random _random = Random();
  QuoteCategory _selectedCategory = QuoteCategory.all;
  final Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _currentQuote = _allQuotes[_random.nextInt(_allQuotes.length)];
  }

  List<Quote> get _filteredQuotes {
    if (_selectedCategory == QuoteCategory.all) return _allQuotes;
    return _allQuotes
        .where((q) => q.category == _selectedCategory)
        .toList();
  }
  Future<void> _fetchRandomQuote() async {
  try {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/quotes/random'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final apiQuote = Quote(
        id: 'api_${DateTime.now().millisecondsSinceEpoch}',
        text: data['quote'] ?? 'Stay positive and keep learning.',
        author: data['author'] ?? 'Unknown',
        category: QuoteCategory.mindset,
        bgImageUrl: _currentQuote.bgImageUrl,
      );

      if (!mounted) return;

      setState(() {
        _currentQuote = apiQuote;
      });
    } else {
      _showQuoteError();
    }
  } catch (e) {
    _showQuoteError();
  }
}

void _showQuoteError() {
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Unable to fetch a new quote. Showing a local quote instead.',
      ),
    ),
  );

  _getRandomQuote();
}
  
  void _getRandomQuote() {
    final available = _filteredQuotes;
    if (available.isEmpty) return;

    setState(() {
      int newIndex;
      do {
        newIndex = _random.nextInt(available.length);
      } while (
          available.length > 1 && available[newIndex].id == _currentQuote.id);

      _currentQuote = available[newIndex];
    });
  }

  void _toggleFavorite(Quote quote) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_favoriteIds.contains(quote.id)) {
        _favoriteIds.remove(quote.id);
      } else {
        _favoriteIds.add(quote.id);
      }
    });
  }

  void _showFavoritesSheet() {
    final favList =
        _allQuotes.where((q) => _favoriteIds.contains(q.id)).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saved Quotes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Colors.white24),
              favList.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text(
                          'No saved quotes yet!',
                          style: TextStyle(color: Colors.white60),
                        ),
                      ),
                    )
                  : Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: favList.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = favList[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.white12),
                            ),
                            title: Text(
                              '"${item.text}"',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              '— ${item.author}',
                              style: const TextStyle(
                                color: Color(0xFFA5B4FC),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              onPressed: () {
                                _toggleFavorite(item);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFav = _favoriteIds.contains(_currentQuote.id);

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Dynamic High-Res Background Image + Gradient Overlay
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            child: Container(
              key: ValueKey<String>(_currentQuote.bgImageUrl),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(_currentQuote.bgImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.5),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // App Bar Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              color: Color(0xFFA5B4FC), size: 22),
                          SizedBox(width: 8),
                          Text(
                            'QUOTIFY',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _showFavoritesSheet,
                        icon: Badge(
                          label: Text('${_favoriteIds.length}'),
                          isLabelVisible: _favoriteIds.isNotEmpty,
                          child: const Icon(Icons.bookmark_border_rounded,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Category Selector Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: QuoteCategory.values.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            showCheckmark: false,
                            label: Text(
                              cat.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                            selectedColor: const Color(0xFFA5B4FC),
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = cat;
                                  _getRandomQuote();
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const Spacer(),

                  // Quote Glassmorphic Card Container
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: animation.drive(
                            Tween<double>(begin: 0.95, end: 1.0),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      key: ValueKey<String>(_currentQuote.id),
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.format_quote_rounded,
                            size: 44,
                            color: Color(0xFFA5B4FC),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '"${_currentQuote.text}"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: 32,
                            height: 2,
                            color: const Color(0xFFA5B4FC),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _currentQuote.author.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFA5B4FC),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Controls Layout
                  Row(
                    children: [
                      // Favorite Toggle
                      IconButton.filledTonal(
                        onPressed: () => _toggleFavorite(_currentQuote),
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.redAccent : Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Copy Button
                      IconButton.filledTonal(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Clipboard.setData(
                            ClipboardData(
                              text:
                                  '"${_currentQuote.text}" — ${_currentQuote.author}',
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Quote copied to clipboard!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Main Action Button ("New Quote")
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                           HapticFeedback.mediumImpact();
                          _fetchRandomQuote();
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 22),
                          label: const Text('New Quote'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}