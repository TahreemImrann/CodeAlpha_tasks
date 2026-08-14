import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LanguageLearningApp());
}

class LanguageLearningApp extends StatelessWidget {
  const LanguageLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LingoLearn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const HomeScreen(),
    );
  }
}

// ==================== MODELS ====================

enum LessonCategory { vocabulary, grammar, phrases }

class LanguageOption {
  final String code;
  final String name;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.flag,
  });
}

class LessonItem {
  final String id;
  final String word;
  final String translation;
  final String pronunciation;
  final String exampleSentence;
  final LessonCategory category;

  LessonItem({
    required this.id,
    required this.word,
    required this.translation,
    required this.pronunciation,
    required this.exampleSentence,
    required this.category,
  });
}

// ==================== HOME SCREEN ====================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _completedLessonsCount = 0;
  int _streakCount = 0;
  LessonCategory _selectedCategory = LessonCategory.vocabulary;

  // Available Languages
  final List<LanguageOption> _languages = const [
    LanguageOption(code: 'fr', name: 'French', flag: '🇫🇷'),
    LanguageOption(code: 'es', name: 'Spanish', flag: '🇪🇸'),
    LanguageOption(code: 'de', name: 'German', flag: '🇩🇪'),
    LanguageOption(code: 'ja', name: 'Japanese', flag: '🇯🇵'),
  ];

  late LanguageOption _selectedLanguage;

  // Multi-Language Content Dataset
  final Map<String, List<LessonItem>> _languageLessons = {
    'fr': [
      LessonItem(
        id: 'fr_1',
        word: 'Bonjour',
        translation: 'Hello / Good morning',
        pronunciation: '/bɔ̃.ʒuʁ/',
        exampleSentence: 'Bonjour, comment allez-vous ?',
        category: LessonCategory.vocabulary,
      ),
      LessonItem(
        id: 'fr_2',
        word: 'Merci beaucoup',
        translation: 'Thank you very much',
        pronunciation: '/mɛʁ.si bo.ku/',
        exampleSentence: 'Merci beaucoup pour votre aide !',
        category: LessonCategory.phrases,
      ),
      LessonItem(
        id: 'fr_3',
        word: 'Le Subjonctif',
        translation: 'The Subjunctive Mood',
        pronunciation: '/lə syb.ʒɔ̃k.tif/',
        exampleSentence: 'Il faut que tu fasses tes devoirs.',
        category: LessonCategory.grammar,
      ),
    ],
    'es': [
      LessonItem(
        id: 'es_1',
        word: 'Hola',
        translation: 'Hello',
        pronunciation: '/ˈo.la/',
        exampleSentence: 'Hola, ¿cómo estás?',
        category: LessonCategory.vocabulary,
      ),
      LessonItem(
        id: 'es_2',
        word: 'Muchas gracias',
        translation: 'Thank you very much',
        pronunciation: '/ˈmu.tʃas ˈɡɾa.sjas/',
        exampleSentence: 'Muchas gracias por todo.',
        category: LessonCategory.phrases,
      ),
      LessonItem(
        id: 'es_3',
        word: 'Por vs. Para',
        translation: 'Preposition Rules',
        pronunciation: '/poɾ/ - /ˈpa.ɾa/',
        exampleSentence: 'Este regalo es para ti.',
        category: LessonCategory.grammar,
      ),
    ],
    'de': [
      LessonItem(
        id: 'de_1',
        word: 'Guten Tag',
        translation: 'Good day / Hello',
        pronunciation: '/ˈɡuːtn̩ taːk/',
        exampleSentence: 'Guten Tag, wie geht es Ihnen?',
        category: LessonCategory.vocabulary,
      ),
      LessonItem(
        id: 'de_2',
        word: 'Vielen Dank',
        translation: 'Thank you very much',
        pronunciation: '/ˈfiːlən daŋk/',
        exampleSentence: 'Vielen Dank für Ihre Hilfe.',
        category: LessonCategory.phrases,
      ),
      LessonItem(
        id: 'de_3',
        word: 'Verb Placement',
        translation: 'V2 Rule in German',
        pronunciation: 'Verb at 2nd position',
        exampleSentence: 'Heute gehe ich ins Kino.',
        category: LessonCategory.grammar,
      ),
    ],
    'ja': [
      LessonItem(
        id: 'ja_1',
        word: 'こんにちは (Konnichiwa)',
        translation: 'Hello / Good afternoon',
        pronunciation: '[koɲ.ɲi.tɕi.wa]',
        exampleSentence: 'こんにちは、お元気ですか？',
        category: LessonCategory.vocabulary,
      ),
      LessonItem(
        id: 'ja_2',
        word: 'ありがとうございます',
        translation: 'Thank you very much',
        pronunciation: '[a.ʁi.ɡa.toː.go.za.i.ma.sɯ]',
        exampleSentence: '助けてくれてありがとうございます。',
        category: LessonCategory.phrases,
      ),
      LessonItem(
        id: 'ja_3',
        word: 'は (Wa) vs. が (Ga)',
        translation: 'Subject & Topic Markers',
        pronunciation: 'Topic vs. Subject Emphasis',
        exampleSentence: '猫が好きです。',
        category: LessonCategory.grammar,
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _languages.first;
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveDateStr = prefs.getString('last_active_date');
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    int streak = prefs.getInt('streak_count') ?? 0;

    if (lastActiveDateStr != null) {
      final lastActiveDate = DateTime.parse(lastActiveDateStr);
      final today = DateTime.now();
      final difference = today.difference(lastActiveDate).inDays;

      if (difference == 1) {
        // Consecutive day
      } else if (difference > 1) {
        // Streak lost
        streak = 0;
      }
    } else {
      streak = 1;
      await prefs.setString('last_active_date', todayStr);
    }

    setState(() {
      _completedLessonsCount = prefs.getInt('completed_lessons') ?? 0;
      _streakCount = streak;
    });

    await prefs.setInt('streak_count', _streakCount);
  }

  Future<void> _incrementProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final lastActiveDateStr = prefs.getString('last_active_date');

    int updatedStreak = _streakCount;
    if (lastActiveDateStr != todayStr) {
      updatedStreak += 1;
      await prefs.setString('last_active_date', todayStr);
      await prefs.setInt('streak_count', updatedStreak);
    }

    setState(() {
      _completedLessonsCount++;
      _streakCount = updatedStreak;
    });

    await prefs.setInt('completed_lessons', _completedLessonsCount);
  }

  List<LessonItem> get _activeLessons {
    final currentDeck = _languageLessons[_selectedLanguage.code] ?? [];
    return currentDeck
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: DropdownButtonHideUnderline(
          child: DropdownButton<LanguageOption>(
            value: _selectedLanguage,
            icon: const Icon(Icons.arrow_drop_down),
            items: _languages.map((lang) {
              return DropdownMenuItem<LanguageOption>(
                value: lang,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(lang.flag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      lang.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (newLang) {
              if (newLang != null) {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedLanguage = newLang;
                });
              }
            },
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Header: Progress & Streak Counter
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Learning ${_selectedLanguage.name} ${_selectedLanguage.flag}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_completedLessonsCount Cards Mastered',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Daily Streak Counter Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.orangeAccent,
                            size: 24,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_streakCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category Selector Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: LessonCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return ChoiceChip(
                    label: Text(
                      category.name.toUpperCase(),
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Lessons List
              Expanded(
                child: ListView.separated(
                  itemCount: _activeLessons.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _activeLessons[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          item.word,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                            '${item.translation} • ${item.pronunciation}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.volume_up_outlined),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Playing audio for: "${item.word}"',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FlashcardDetailScreen(
                                lesson: item,
                                onCompleted: _incrementProgress,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // Bottom Quiz Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: FilledButton.icon(
                  onPressed: () {
                    final currentDeck =
                        _languageLessons[_selectedLanguage.code] ?? [];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          lessons: currentDeck,
                          language: _selectedLanguage,
                          onQuizCompleted: _incrementProgress,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.quiz_outlined),
                  label: Text('Take ${_selectedLanguage.name} Quiz'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== FLASHCARD SCREEN ====================

class FlashcardDetailScreen extends StatefulWidget {
  final LessonItem lesson;
  final VoidCallback onCompleted;

  const FlashcardDetailScreen({
    super.key,
    required this.lesson,
    required this.onCompleted,
  });

  @override
  State<FlashcardDetailScreen> createState() => _FlashcardDetailScreenState();
}

class _FlashcardDetailScreenState extends State<FlashcardDetailScreen> {
  bool _showTranslation = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.category.name.toUpperCase())),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _showTranslation = !_showTranslation;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _showTranslation ? 'TRANSLATION' : 'TARGET WORD',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _showTranslation
                            ? widget.lesson.translation
                            : widget.lesson.word,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.lesson.pronunciation,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Example: "${widget.lesson.exampleSentence}"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                widget.onCompleted();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark as Mastered'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== QUIZ SCREEN ====================

class QuizScreen extends StatefulWidget {
  final List<LessonItem> lessons;
  final LanguageOption language;
  final VoidCallback onQuizCompleted;

  const QuizScreen({
    super.key,
    required this.lessons,
    required this.language,
    required this.onQuizCompleted,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _questionIndex = 0;
  int _score = 0;

  void _answerQuestion(String selectedAnswer) {
    if (selectedAnswer == widget.lessons[_questionIndex].translation) {
      _score++;
    }

    if (_questionIndex < widget.lessons.length - 1) {
      setState(() {
        _questionIndex++;
      });
    } else {
      widget.onQuizCompleted();
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('${widget.language.flag} Quiz Complete! 🎉'),
        content: Text('You scored $_score out of ${widget.lessons.length}!'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lessons.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No questions available.')),
      );
    }

    final currentLesson = widget.lessons[_questionIndex];
    final options = widget.lessons.map((e) => e.translation).toList()
      ..shuffle();

    return Scaffold(
      appBar: AppBar(title: Text('${widget.language.name} Practice Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_questionIndex + 1) / widget.lessons.length,
            ),
            const SizedBox(height: 24),
            Text(
              'Question ${_questionIndex + 1} of ${widget.lessons.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'What is the correct translation for "${currentLesson.word}"?',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ...options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _answerQuestion(option),
                  child: Text(option, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}