import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
    // chieu rong
    double get screenWidth => MediaQuery.sizeOf(this).width;

    // chieu cao
    double get screenHeight => MediaQuery.sizeOf(this).height;

    // check chieu rong < 360dp
    bool get isSmallPhone => screenWidth < 360;

    // check chieu rong tablet >= 600dp
    bool get isTablet => screenWidth >= 600;

    // % chieu rong 70% 
    double wp(double percent) => screenWidth * percent / 100;

    // % chieu cao 30%
    double hp(double percent) => screenHeight * percent / 100;
    
}