import 'package:aptcoder/core/app_widgets/appfilledbutton.dart';
import 'package:aptcoder/core/app_widgets/apptexts.dart';
import 'package:aptcoder/core/config/const.dart';
import 'package:aptcoder/core/config/theme.dart';
import 'package:aptcoder/core/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final slides = [
    OnboardItem(
      image: 'assets/images/png/onb1.png',
      title: 'Learn From ',
      highlight: 'Anywhere',
      subtitle: 'Learn anytime from anywhere with ease.',
    ),
    OnboardItem(
      image: 'assets/images/png/onb2.png',
      title: 'Make Your ',
      highlight: 'Schedule Perfect',
      subtitle: 'Manage your time and learn at your pace.',
    ),
    OnboardItem(
      image: 'assets/images/png/onb3.png',
      title: 'Start Learning ',
      highlight: 'New Skills',
      subtitle: 'Upgrade yourself with modern skills.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            /// ---------------- PAGE VIEW ----------------
            PageView.builder(
              controller: _pageController,
              itemCount: slides.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (_, index) {
                return _OnboardPage(
                  item: slides[index],
                  active: index == _currentIndex,
                );
              },
            ),

            /// ---------------- TOP RIGHT MENU ----------------
            Positioned(
              top: 8,
              right: 8,
              child: PopupMenuButton(
                surfaceTintColor: backgroundColor,
                color: backgroundColor,
                icon: const Icon(Icons.more_vert),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    child: AppText.interMedium('Login as Admin'),
                    onTap: () {
                      Future.delayed(Duration.zero, () {
                        AuthService().signInWithGoogle('admin');
                      });
                    },
                  ),
                ],
              ),
            ),

            /// ---------------- BOTTOM AREA ----------------
            Positioned(
              left: 0,
              right: 0,
              bottom: size.height * 0.06,
              child: Column(
                children: [
                  _Indicators(count: slides.length, activeIndex: _currentIndex),
                  const SizedBox(height: 24),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentIndex == slides.length - 1
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.08,
                            ),
                            child: AppFilledButton(
                              key: const ValueKey('google'),
                              label: 'Continue with Google',
                              icon: SvgPicture.asset(
                                'assets/images/svg/google.svg',
                                height: 24,
                              ),
                              onTap: () {
                                AuthService().signInWithGoogle('student');
                              },
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.08,
                            ),
                            child: AppFilledButton(
                              key: const ValueKey('next'),
                              label: 'Next',
                              onTap: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOut,
                                );
                              },
                              icon: Icon(
                                Icons.navigate_next_sharp,
                                color: primaryColor,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final OnboardItem item;
  final bool active;

  const _OnboardPage({required this.item, required this.active});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSlide(
            duration: const Duration(milliseconds: 500),
            offset: active ? Offset.zero : const Offset(0, 0.1),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: active ? 1 : 0,
              child: Image.asset(item.image, height: size.height * 0.32),
            ),
          ),
          const SizedBox(height: 40),

          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: AppFontSize.huge,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              children: [
                TextSpan(text: item.title),
                TextSpan(
                  text: item.highlight,
                  style: const TextStyle(color: primaryColor),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          AppText.interMedium(item.subtitle),
        ],
      ),
    );
  }
}

class _Indicators extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _Indicators({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: activeIndex == index ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: activeIndex == index ? primaryColor : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}

class OnboardItem {
  final String image;
  final String title;
  final String highlight;
  final String subtitle;

  OnboardItem({
    required this.image,
    required this.title,
    required this.highlight,
    required this.subtitle,
  });
}
