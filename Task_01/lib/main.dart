import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const FlashcardApp());
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Flashcards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const FlashcardHome(),
    );
  }
}

class Flashcard {
  final String id;
  String topic;
  String question;
  String answer;
  bool? isMastered; // null = unreviewed, true = mastered, false = needs practice

  Flashcard({
    required this.id,
    required this.topic,
    required this.question,
    required this.answer,
    this.isMastered,
  });
}

class FlashcardHome extends StatefulWidget {
  const FlashcardHome({super.key});

  @override
  State<FlashcardHome> createState() => _FlashcardHomeState();
}

class _FlashcardHomeState extends State<FlashcardHome> {
  final List<Flashcard> _allCards = [
    Flashcard(
      id: '1',
      topic: "Rendering Architecture",
      question:
          "What is the key difference between Element and Widget trees in Flutter, and why are Elements reused?",
      answer:
          "Widgets are lightweight, immutable configurations. Elements are mutable structural nodes managing the lifecycle. Elements are reused via keys/types to avoid costly rebuilds of the RenderObject tree.",
    ),
    Flashcard(
      id: '2',
      topic: "State Management",
      question:
          "How does InheritedWidget propagate changes down the tree, and how do you prevent unnecessary child rebuilds?",
      answer:
          "It uses updateShouldNotify() to check for changes. Child rebuilds are prevented by extracting child widgets into constant constructors (const) or passing them pre-built via a 'child' parameter.",
    ),
    Flashcard(
      id: '3',
      topic: "Asynchronous Dart",
      question:
          "Explain the difference between Microtask Queue and Event Queue in Dart's Event Loop execution priority.",
      answer:
          "The Microtask Queue has absolute priority over the Event Queue. Microtasks run to completion before the Event Loop picks the next item from the Event Queue (Futures, Timers, I/O).",
    ),
    Flashcard(
      id: '4',
      topic: "Layout & Rendering",
      question:
          "What causes 'Unbounded Height' layout errors in Flutter, and how does Constraints Go Down, Sizes Go Up resolve it?",
      answer:
          "It occurs when a parent provides infinite max-height constraints. Parents pass constraints down, children pick a size within them, and parents position the children.",
    ),
    Flashcard(
      id: '5',
      topic: "Performance & Memory",
      question:
          "Why is using RepaintBoundary beneficial in complex or animated widget trees?",
      answer:
          "It creates a separate display layer for its subtree. When the subtree updates, Flutter only repaints that isolated layer without repainting the entire parent tree.",
    ),
    Flashcard(
      id: '6',
      topic: "Custom Painting",
      question:
          "When implementing CustomPainter, why is the shouldRepaint method critical for performance?",
      answer:
          "shouldRepaint determines whether paint() needs to execute again when state updates. Returning false skips expensive canvas operations.",
    ),
    Flashcard(
      id: '7',
      topic: "Keys & State Persistence",
      question:
          "Why do you need a GlobalKey versus a ValueKey when modifying stateful items in a reorderable list?",
      answer:
          "ValueKey preserves state when elements move within the same parent. GlobalKey allows widgets to change parent trees altogether or be accessed across different subtrees without losing state.",
    ),
    Flashcard(
      id: '8',
      topic: "Engine & Platform Interop",
      question:
          "What is the difference between Platform Channels (MethodChannel) and Dart FFI?",
      answer:
          "MethodChannel uses asynchronous IPC message passing to call native iOS/Android APIs. Dart FFI enables direct synchronous memory/pointer calls to native C/C++ libraries without channel overhead.",
    ),
    Flashcard(
      id: '9',
      topic: "Build Lifecycle",
      question:
          "Why is calling setState inside initState problematic without post-frame callbacks?",
      answer:
          "initState runs while the element tree is assembling. Triggering setState immediately schedules a rebuild before the initial frame layout has finalized.",
    ),
    Flashcard(
      id: '10',
      topic: "Advanced Navigation",
      question:
          "How does Navigator 2.0 (Router API) differ fundamentally from Navigator 1.0?",
      answer:
          "Navigator 1.0 is imperative using a stack (push/pop). Navigator 2.0 is declarative—the app state dictates the navigation stack configuration via Page objects.",
    ),
  ];

  String _selectedTopic = 'All';
  int _currentIndex = 0;
  bool _showAnswer = false;

  // Derive unique topics
  List<String> get _topics {
    final set = <String>{'All'};
    for (var card in _allCards) {
      set.add(card.topic);
    }
    return set.toList();
  }

  // Filtered card deck based on selected topic
  List<Flashcard> get _filteredCards {
    if (_selectedTopic == 'All') return _allCards;
    return _allCards.where((card) => card.topic == _selectedTopic).toList();
  }

  void _handleSwipe(DismissDirection direction) {
    if (_filteredCards.isEmpty) return;

    final currentCard = _filteredCards[_currentIndex];
    HapticFeedback.mediumImpact();

    setState(() {
  if (direction == DismissDirection.startToEnd) {
    // Swiped Right -> Mastered
    currentCard.isMastered = true;
  } else if (direction == DismissDirection.endToStart) {
    // Swiped Left -> Needs Practice
    currentCard.isMastered = false;
  }

  _showAnswer = false;

  // Move to the next card
  if (_currentIndex < _filteredCards.length - 1) {
    _currentIndex++;
  } else {
    _currentIndex = 0;
  }
});
  }

  void _toggleAnswer() {
    HapticFeedback.selectionClick();
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }
  void _nextCard() {
  if (_filteredCards.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
     if (_currentIndex < _filteredCards.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }

    _showAnswer = false;
  });
}

void _previousCard() {
  if (_filteredCards.isEmpty) return;

  HapticFeedback.selectionClick();

  setState(() {
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = _filteredCards.length - 1;
    }

    _showAnswer = false;
  });
}

  void _showCardDialog({Flashcard? existingCard}) {
    final topicController =
        TextEditingController(text: existingCard?.topic ?? '');
    final questionController =
        TextEditingController(text: existingCard?.question ?? '');
    final answerController =
        TextEditingController(text: existingCard?.answer ?? '');
    final isEditing = existingCard != null;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            isEditing ? 'Edit Flashcard' : 'Add Flashcard',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: topicController,
                    decoration: InputDecoration(
                      labelText: 'Topic / Category',
                      hintText: 'e.g., State Management',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Required field'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: questionController,
                    decoration: InputDecoration(
                      labelText: 'Question',
                      hintText: 'Enter question text',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Required field'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: answerController,
                    decoration: InputDecoration(
                      labelText: 'Answer',
                      hintText: 'Enter detailed answer',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Required field'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final t = topicController.text.trim();
                final q = questionController.text.trim();
                final a = answerController.text.trim();

                setState(() {
                  if (isEditing) {
                    existingCard.topic = t;
                    existingCard.question = q;
                    existingCard.answer = a;
                  } else {
                    _allCards.add(
                      Flashcard(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        topic: t,
                        question: q,
                        answer: a,
                      ),
                    );
                    _currentIndex = _filteredCards.length - 1;
                  }
                  _showAnswer = false;
                });
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Save' : 'Add Card'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCurrentCard() {
    if (_filteredCards.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Flashcard?'),
        content: const Text('Are you sure you want to delete this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              setState(() {
                final cardToDelete = _filteredCards[_currentIndex];
                _allCards.removeWhere((c) => c.id == cardToDelete.id);
                if (_currentIndex >= _filteredCards.length &&
                    _filteredCards.isNotEmpty) {
                  _currentIndex = _filteredCards.length - 1;
                }
                _showAnswer = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cards = _filteredCards;
    final hasCards = cards.isNotEmpty;

    // Safety check for index out of bounds on filter changes
    if (_currentIndex >= cards.length && cards.isNotEmpty) {
      _currentIndex = 0;
    }

    final currentCard = hasCards ? cards[_currentIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter Flashcards',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ----- 1. Topic Filter Chips -----
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _topics.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final topic = _topics[index];
                  final isSelected = topic == _selectedTopic;
                  return FilterChip(
                    label: Text(topic),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (selected) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedTopic = topic;
                        _currentIndex = 0;
                        _showAnswer = false;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Progress Header
            if (hasCards)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CARD ${_currentIndex + 1} OF ${cards.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  _showCardDialog(existingCard: currentCard),
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              tooltip: 'Edit Card',
                            ),
                            IconButton(
                              onPressed: _deleteCurrentCard,
                              icon: Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: theme.colorScheme.error,
                              ),
                              tooltip: 'Delete Card',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / cards.length,
                        minHeight: 6,
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // ----- 2. Swipeable Card Area -----
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: hasCards
                    ? Dismissible(
                        key: ValueKey('${currentCard!.id}_$_showAnswer'),
                        onDismissed: (direction) => _handleSwipe(direction),
                        background: _buildSwipeBackground(
                          alignment: Alignment.centerLeft,
                          color: Colors.green.shade600,
                          icon: Icons.check_circle_outline,
                          label: 'MASTERED',
                        ),
                        secondaryBackground: _buildSwipeBackground(
                          alignment: Alignment.centerRight,
                          color: Colors.orange.shade800,
                          icon: Icons.replay,
                          label: 'NEED PRACTICE',
                        ),
                        child: GestureDetector(
                          onTap: _toggleAnswer,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: _showAnswer
                                    ? theme.colorScheme.primary
                                        .withValues(alpha: 0.3)
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Status Pill & Topic Badge
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color:
                                            theme.colorScheme.primaryContainer,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        currentCard.topic.toUpperCase(),
                                        style: TextStyle(
                                          color: theme
                                              .colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.1,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    if (currentCard.isMastered != null) ...[
                                      const SizedBox(width: 8),
                                      Icon(
                                        currentCard.isMastered!
                                            ? Icons.check_circle
                                            : Icons.refresh,
                                        size: 18,
                                        color: currentCard.isMastered!
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ]
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _showAnswer
                                        ? Colors.green.shade50
                                        : theme.colorScheme
                                            .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _showAnswer ? 'ANSWER' : 'QUESTION',
                                    style: TextStyle(
                                      color: _showAnswer
                                          ? Colors.green.shade800
                                          : theme
                                              .colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                SingleChildScrollView(
                                  child: Text(
                                    _showAnswer
                                        ? currentCard.answer
                                        : currentCard.question,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: _showAnswer ? 16 : 20,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.swipe,
                                      size: 16,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.4),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Swipe left/right or tap to flip',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.4),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.style_outlined,
                              size: 64,
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No cards in this topic',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Controls
            if (hasCards)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    FilledButton.icon(
                      onPressed: _toggleAnswer,
                      icon: Icon(_showAnswer
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      label: Text(_showAnswer ? 'Hide Answer' : 'Show Answer'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

Row(
  children: [
    Expanded(
      child: OutlinedButton.icon(
        onPressed: _previousCard,
        icon: const Icon(Icons.arrow_back),
        label: const Text('Previous'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: OutlinedButton.icon(
        onPressed: _nextCard,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Next'),
        iconAlignment: IconAlignment.end,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    ),
  ],
),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _handleSwipe(DismissDirection.endToStart);
                            },
                            icon: const Icon(Icons.close, color: Colors.orange),
                            label: const Text('Need Practice'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _handleSwipe(DismissDirection.startToEnd);
                            },
                            icon: const Icon(Icons.check, color: Colors.green),
                            label: const Text('Mastered'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCardDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}