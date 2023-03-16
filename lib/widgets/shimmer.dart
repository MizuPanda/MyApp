import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';

class Shimmer extends StatelessWidget {
  const Shimmer({
    super.key,
    required this.isDarkMode,
  });

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: double.maxFinite,
      child: ListView.separated(
        itemBuilder: (_, i) {
          final delay = (i * 300);
          return Container(
            decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xff242424) : Colors.white,
                borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                FadeShimmer.round(
                  size: 80,
                  fadeTheme: isDarkMode ? FadeTheme.dark : FadeTheme.light,
                  millisecondsDelay: delay,
                ),
                const SizedBox(
                  width: 8,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeShimmer(
                      height: 11,
                      width: 150,
                      radius: 4,
                      millisecondsDelay: delay,
                      fadeTheme: isDarkMode ? FadeTheme.dark : FadeTheme.light,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    FadeShimmer(
                      height: 11,
                      millisecondsDelay: delay,
                      width: 170,
                      radius: 4,
                      fadeTheme: isDarkMode ? FadeTheme.dark : FadeTheme.light,
                    ),
                  ],
                )
              ],
            ),
          );
        },
        itemCount: 20,
        separatorBuilder: (_, __) => const SizedBox(
          height: 16,
        ),
      ),
    );
  }
}
