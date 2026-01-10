class ReadabilityAnalyzer {
  static Map<String, dynamic> analyzeText(String text) {
    if (text.trim().isEmpty) {
      return {
        'fleschKincaidGrade': 0.0,
        'fleschReadingEase': 0.0,
        'averageSentenceLength': 0.0,
        'averageSyllablesPerWord': 0.0,
        'wordCount': 0,
        'sentenceCount': 0,
        'syllableCount': 0,
        'readabilityLevel': 'No text',
      };
    }

    final words = _getWords(text);
    final sentences = _getSentences(text);
    final syllables = _countSyllables(words);

    final wordCount = words.length;
    final sentenceCount = sentences.length;
    final syllableCount = syllables;

    final averageSentenceLength = sentenceCount > 0 ? wordCount / sentenceCount : 0.0;
    final averageSyllablesPerWord = wordCount > 0 ? syllableCount / wordCount : 0.0;

    // Flesch Reading Ease Score
    final fleschReadingEase = sentenceCount > 0 && wordCount > 0
        ? 206.835 - (1.015 * averageSentenceLength) - (84.6 * averageSyllablesPerWord)
        : 0.0;

    // Flesch-Kincaid Grade Level
    final fleschKincaidGrade = sentenceCount > 0 && wordCount > 0
        ? (0.39 * averageSentenceLength) + (11.8 * averageSyllablesPerWord) - 15.59
        : 0.0;

    return {
      'fleschKincaidGrade': fleschKincaidGrade.clamp(0.0, 20.0),
      'fleschReadingEase': fleschReadingEase.clamp(0.0, 100.0),
      'averageSentenceLength': averageSentenceLength,
      'averageSyllablesPerWord': averageSyllablesPerWord,
      'wordCount': wordCount,
      'sentenceCount': sentenceCount,
      'syllableCount': syllableCount,
      'readabilityLevel': _getReadabilityLevel(fleschReadingEase),
    };
  }

  static List<String> _getWords(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  static List<String> _getSentences(String text) {
    return text
        .split(RegExp(r'[.!?]+'))
        .where((sentence) => sentence.trim().isNotEmpty)
        .toList();
  }

  static int _countSyllables(List<String> words) {
    int totalSyllables = 0;
    for (String word in words) {
      totalSyllables += _countSyllablesInWord(word);
    }
    return totalSyllables;
  }

  static int _countSyllablesInWord(String word) {
    if (word.isEmpty) return 0;
    
    word = word.toLowerCase();
    int syllables = 0;
    bool previousWasVowel = false;
    
    for (int i = 0; i < word.length; i++) {
      bool isVowel = 'aeiouy'.contains(word[i]);
      if (isVowel && !previousWasVowel) {
        syllables++;
      }
      previousWasVowel = isVowel;
    }
    
    // Handle silent 'e' at the end
    if (word.endsWith('e') && syllables > 1) {
      syllables--;
    }
    
    // Every word has at least one syllable
    return syllables > 0 ? syllables : 1;
  }

  static String _getReadabilityLevel(double fleschScore) {
    if (fleschScore >= 90) return 'Very Easy';
    if (fleschScore >= 80) return 'Easy';
    if (fleschScore >= 70) return 'Fairly Easy';
    if (fleschScore >= 60) return 'Standard';
    if (fleschScore >= 50) return 'Fairly Difficult';
    if (fleschScore >= 30) return 'Difficult';
    return 'Very Difficult';
  }
}

