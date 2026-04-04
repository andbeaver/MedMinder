import 'package:flutter/material.dart';
import 'package:medminder/theme/app_styles.dart';

class GradientBody extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const GradientBody({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppGradients.scaffoldBackground(context),
      child: Container(
        decoration: AppGradients.leftGlow(AppColors.primary),
        child: Container(
          decoration: AppGradients.rightGlow(AppColors.primary),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: padding,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: child,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}