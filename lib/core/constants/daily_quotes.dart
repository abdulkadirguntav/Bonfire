/// Edit this list to change the text used by the in-app and home-screen widget.
const dailyQuotes = <String>[
  'Dünya senin acılarını umursamıyor. Kalk ve yürü.',
  'Kusursuzluk bir yalan. Sadece dünden daha iyi ol.',
];

String quoteForDate(DateTime date) =>
    dailyQuotes[DateTime(date.year, date.month, date.day)
            .difference(DateTime(2026))
            .inDays
            .abs() %
        dailyQuotes.length];
