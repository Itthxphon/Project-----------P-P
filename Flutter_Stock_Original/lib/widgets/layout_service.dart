import 'package:flutter/material.dart';

class LayoutService {
  static bool isPhoneOrPortrait(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  static Size getSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static bool isLandscape(BuildContext context) {
    return LayoutService.getOrientation(context) == Orientation.landscape;
  }

  static bool isPortrait(BuildContext context) {
    return LayoutService.getOrientation(context) == Orientation.portrait;
  }

  static BoxDecoration getBorderTopRadius(BuildContext context) {
    bool tabletMode = MediaQuery.of(context).size.width > 600;
    if (tabletMode) {
      return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)));
    }
    return BoxDecoration(color: Colors.white);
  }

  static BoxDecoration getBorderBottomRadius(BuildContext context) {
    bool tabletMode = MediaQuery.of(context).size.width > 600;
    if (tabletMode) {
      return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)));
    }
    return BoxDecoration(color: Colors.white);
  }

  static BoxDecoration getBorderAllRadius(BuildContext context) {
    bool tabletMode = MediaQuery.of(context).size.width > 600;
    if (tabletMode) {
      return BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10));
    }
    return BoxDecoration(color: Colors.white);
  }
}
