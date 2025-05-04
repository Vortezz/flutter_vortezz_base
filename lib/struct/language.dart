library flutter_vortezz_base;

enum Language {
  system(0),
  en(1),
  fr(2),
  de(3),
  es(4);

  final int value;

  const Language(this.value);

  static Language getLanguageFromString(String language) {
    switch (language) {
      case "en":
        return Language.en;
      case "fr":
        return Language.fr;
      case "de":
        return Language.de;
      case "es":
        return Language.es;
      default:
        return Language.system;
    }
  }
}
