import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';

class Shimmer extends StatelessWidget {
  const Shimmer({
    super.key,
    required this.isDarkMode,
  });

  final bool isDarkMode;
  static const Color baseColor = Colors.white;
  static final Color highlightColor = Colors.grey[100]!;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: ListView.separated(
          itemBuilder: (_, i) {
            final delay = (i * 300);
            return Container(
              height: 123,
              width: double.maxFinite,
              decoration: BoxDecoration(
                  color: Colors.white60,
                  border: Border.all(color: Colors.grey, width: 0.3),
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        FadeShimmer.round(
                          size: 60,
                          baseColor: baseColor,
                          highlightColor: highlightColor,
                          //fadeTheme: isDarkMode ? FadeTheme.dark : FadeTheme.light,
                          millisecondsDelay: delay,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FadeShimmer(
                                height: 16,
                                width: 100,
                                radius: 4,
                                millisecondsDelay: delay,
                                baseColor: baseColor,
                                highlightColor: highlightColor,
                                //fadeTheme: isDarkMode ? FadeTheme.dark : FadeTheme.light,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              FadeShimmer(
                                height: 14,
                                width: 75,
                                radius: 4,
                                millisecondsDelay: delay,
                                baseColor: baseColor,
                                highlightColor: highlightColor,
                                //fadeTheme: isDarkMode ? FadeTheme.dark : FadeTheme.light,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FadeShimmer(
                              height: 14,
                              width: 40,
                              radius: 4,
                              millisecondsDelay: delay,
                              baseColor: baseColor,
                              highlightColor: highlightColor,
                              //fadeTheme: isDarkMode ? FadeTheme.dark : FadeTheme.light,
                            ),
                            const Spacer(),
                            FadeShimmer(
                              height: 14,
                              width: 50,
                              radius: 4,
                              millisecondsDelay: delay,
                              baseColor: baseColor,
                              highlightColor: highlightColor,
                              //fadeTheme: isDarkMode ? FadeTheme.dark : FadeTheme.light,
                            ),
                            FadeShimmer(
                              height: 14,
                              width: 100,
                              radius: 4,
                              millisecondsDelay: delay,
                              baseColor: baseColor,
                              highlightColor: highlightColor,
                              //fadeTheme: isDarkMode ? FadeTheme.dark : FadeTheme.light,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    height: 25,
                    decoration: BoxDecoration(
                        color: Colors.white60,
                        border: Border.all(color: Colors.black, width: 0.5),
                        borderRadius: BorderRadius.circular(9)),
                    child:
                    FadeShimmer(
                      height: 25,
                      width: double.maxFinite,
                      radius: 9,
                      millisecondsDelay: delay,
                      fadeTheme: isDarkMode ? FadeTheme.dark : FadeTheme.light,
                    ),

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
      ),
    );
  }
}
