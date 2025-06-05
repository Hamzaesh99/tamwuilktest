import 'package:flutter/material.dart';

class WelcomeContent extends StatelessWidget {
  final int currentPage;
  final List<String> descriptions;
  final PageController pageController;
  final Function(int) onPageChanged;
  final TextStyle textStyle;
  final List<String> imageNames;
  final double imageRadius;

  const WelcomeContent({
    super.key,
    required this.currentPage,
    required this.descriptions,
    required this.pageController,
    required this.onPageChanged,
    required this.textStyle,
    required this.imageNames,
    required this.imageRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // صورة في الزاوية العلوية اليسرى
        Positioned(
          left: 0,
          top: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Image.asset('assets/images/image.png', width: 40, height: 40),
          ),
        ),

        // تعديل موقع النص "Tamwuilk" ليكون في وسط الشاشة
        const Positioned(
          top: 20, // يمكنك تعديل هذه القيمة حسب الحاجة
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Tamwuilk',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),

        // باقي محتوى الصفحة داخل Column
        Column(
          children: [
            const SizedBox(
                height: 60), // مساحة فارغة لتجنب تداخل المحتوى مع النص العلوي

            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: onPageChanged,
                itemCount: descriptions.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(imageRadius),
                        child: Image.asset(
                          'assets/images/${imageNames[index]}',
                          height: MediaQuery.of(context).size.height * 0.25,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(8, 225, 215, 0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          descriptions[index],
                          style: textStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromRGBO(8, 225, 215, 1),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // تم إزالة مؤشرات الصفحات
            const SizedBox(height: 40),
          ],
        )
      ],
    );
  }
}
