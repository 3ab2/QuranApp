/// Medinan (Madani) surah numbers per common classical classification.
/// All others are treated as Makki for UI labeling.
const Set<int> _madaniSurahNumbers = {
  2, 3, 4, 5, 8, 9, 13, 22, 24, 33, 47, 48, 49, 57, 58, 59, 60, 61, 62, 63, 64,
  65, 66, 76, 98, 99, 110, 111,
};

bool isMadaniSurah(int surahNumber) =>
    surahNumber >= 1 && surahNumber <= 114 && _madaniSurahNumbers.contains(surahNumber);
