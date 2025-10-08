class WelcomePage {
  final String title;
  final String description;
  final String imagePath;
  final bool isLastPage;

  WelcomePage({
    required this.title,
    required this.description,
    required this.imagePath,
    this.isLastPage = false,
  });
}

final List<WelcomePage> welcomePages = [
  WelcomePage(
    title: 'Welcome to PBP Housy',
    description: 'Experience the thrill of playing Housy with friends and family in real-time!',
    imagePath: 'assets/images/welcome1.png', // Replace with your actual image path
  ),
  WelcomePage(
    title: 'Play Anytime, Anywhere',
    description: 'Join rooms, get your tickets, and start playing in just a few taps!',
    imagePath: 'assets/images/welcome2.png', // Replace with your actual image path
  ),
  WelcomePage(
    title: 'Win Exciting Prizes',
    description: 'Be the first to complete patterns and win amazing rewards!',
    imagePath: 'assets/images/welcome3.png', // Replace with your actual image path
    isLastPage: true,
  ),
];
