import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/colors.dart';
import '../styles/dimens.dart';
import '../styles/text_styles.dart';

/// One destination in [AppBottomNav].
///
/// [activeIcon] is the filled counterpart of [icon]; the pair reads as one
/// mark that solidifies on selection rather than two different symbols.
class AppNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const AppNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

/// Bottom navigation from the exports (screens 07/08/09/10/11): a hairline
/// rule, then an icon over its label — green and filled when active, muted and
/// outlined when not.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavItem> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppDimens.bottomNavHeight.h,
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color tint = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Semantics(
        selected: selected,
        button: true,
        child: Center(
          // Short viewports (landscape, small tablets) leave the bar less
          // height than the icon + label want; scaling down beats clipping.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? item.activeIcon : item.icon,
                  size: 24.sp,
                  color: tint,
                ),
                SizedBox(height: AppDimens.xxs.h),
                Text(
                  item.label,
                  style: AppTextStyles.navLabel.copyWith(
                    color: tint,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
