class IntroItem {
  IntroItem({
    this.title,
    this.category,
    this.imageUrl,
  });

  final String title;
  final String category;
  final String imageUrl;
}

final sampleItems = <IntroItem>[
  new IntroItem(title: 'Ending your Dilemma!', category: 'PREDICT', imageUrl: 'images/whathow.jpg',),
  new IntroItem(title: 'Preplanning is always good', category: 'LEARN', imageUrl: 'images/career2.jpg',),
  new IntroItem(title: 'Preventing extra expenses.', category: 'PREVENT', imageUrl: 'images/final2.png',),
];