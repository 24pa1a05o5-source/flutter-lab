import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Journey',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        late final Widget page;

        switch (settings.name) {
          case '/':
            page = const OnboardingScreen();
            break;
          case '/home':
            page = const HomeScreen();
            break;
          case '/profile':
            page = const ProfileScreen();
            break;
          case '/settings':
            page = const SettingsScreen();
            break;
          default:
            page = const HomeScreen();
        }

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(curvedAnimation);

            return FadeTransition(
              opacity: curvedAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
        );
      },
    );
  }
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

const List<OnboardingItem> onboardingItems = [
  OnboardingItem(
    icon: Icons.explore_rounded,
    title: 'Discover More',
    description:
        'Explore new possibilities with a simple and beautiful experience.',
    color: Colors.indigo,
  ),
  OnboardingItem(
    icon: Icons.bolt_rounded,
    title: 'Stay Productive',
    description:
        'Organize your day, focus on your goals, and make every moment count.',
    color: Colors.deepPurple,
  ),
  OnboardingItem(
    icon: Icons.rocket_launch_rounded,
    title: 'Ready to Begin?',
    description:
        'Your journey starts here. Let’s make something amazing together.',
    color: Colors.teal,
  ),
];

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  size: 100,
                  color: item.color,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == onboardingItems.length - 1;

  void _nextPage() {
    if (_isLastPage) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _skip,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: onboardingItems.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _controller,
                      child: OnboardingPage(item: onboardingItems[index]),
                      builder: (context, child) {
                        double page = _currentPage.toDouble();

                        if (_controller.hasClients &&
                            _controller.position.hasContentDimensions) {
                          page = _controller.page ?? _currentPage.toDouble();
                        }

                        final difference = (page - index).abs();
                        final opacity =
                            (1.0 - difference).clamp(0.0, 1.0).toDouble();

                        return Opacity(
                          opacity: opacity,
                          child: Transform.translate(
                            offset: Offset((index - page) * 45, 0),
                            child: child,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingItems.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 26 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.indigo
                          : Colors.indigo.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  if (_currentPage > 0)
                    OutlinedButton(
                      onPressed: _previousPage,
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox(width: 72),
                  const Spacer(),
                  FilledButton(
                    onPressed: _nextPage,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 15,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_isLastPage ? 'Get Started' : 'Next'),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    _HomeTab(),
    _ProfileTab(),
    _SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Journey',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Open profile',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hello there! 👋',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What would you like to explore today?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.indigo, Colors.deepPurple],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.waving_hand_rounded,
                  color: Colors.white,
                  size: 38,
                ),
                SizedBox(height: 18),
                Text(
                  'A fresh start',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Small steps lead to great things.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Quick access',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _QuickCard(
            icon: Icons.person_rounded,
            title: 'My Profile',
            subtitle: 'View your profile page',
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          _QuickCard(
            icon: Icons.settings_rounded,
            title: 'Settings',
            subtitle: 'Customize your preferences',
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          _QuickCard(
            icon: Icons.explore_rounded,
            title: 'Explore',
            subtitle: 'Start your journey',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Welcome! Happy exploring.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.withValues(alpha: 0.1),
          child: Icon(icon, color: Colors.indigo),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen();
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 55,
                backgroundColor: Color(0xFFE8EAF6),
                child: Icon(
                  Icons.person_rounded,
                  size: 65,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome, User!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your profile page is ready.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            subtitle: const Text('Enable app notifications'),
            value: _notifications,
            onChanged: (value) {
              setState(() => _notifications = value);
            },
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark mode preference'),
            subtitle: const Text('Toggle your display preference'),
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('My Journey app'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'My Journey',
                applicationVersion: '1.0.0',
                applicationLegalese: 'Built with Flutter',
              );
            },
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Settings are currently stored only while the app is running.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
