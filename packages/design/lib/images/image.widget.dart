// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FlutterImage extends StatelessWidget {
  /// 아이콘 데이터 (아이콘 폰트를 아이콘으로 쓰는 경우)
  final IconData? icon;

  /// SVG 아이콘 데이터 (SVG 이미지를 아이콘으로 쓰는 경우)
  final String? svg;

  /// 아이콘 데이터로 사용하고 싶을 경우에 쓰는 아이콘 사이즈
  double? size;

  /// SVG 아이콘 데이터로 사용하고 싶을 경우에 쓰는 아이콘 너비
  double? width;

  /// SVG 아이콘 데이터로 사용하고 싶을 경우에 쓰는 아이콘 높이
  double? height;

  /// 아이콘 색상
  Color? color;

  /// 아이콘 색상 블렌드 모드
  BlendMode? colorBlendMode;

  /// svg에서 사용할 아이콘 색상 블렌드 모드
  final BlendMode? blendMode;

  FlutterImage({
    super.key,
    this.icon,
    this.svg,
    this.size,
    this.width,
    this.height,
    this.color,
    this.blendMode,
    this.colorBlendMode,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return Icon(
        icon,
        size: size,
        color: color,
      );
    }

    if (svg?.contains('.svg') ?? false) {
      return SvgPicture.asset(
        svg!,
        width: width ?? size,
        height: height ?? size,
        color: color,
        colorBlendMode: colorBlendMode ?? BlendMode.srcIn,
      );
    }

    if (svg?.contains('.png') ?? false) {
      return Image.asset(
        svg!,
        width: width ?? size,
        height: height ?? size,
        color: color,
        colorBlendMode: colorBlendMode,
      );
    }

    if (svg?.contains('.jpg') ?? false) {
      return Image.asset(
        svg!,
        width: width ?? size,
        height: height ?? size,
        color: color,
        colorBlendMode: colorBlendMode,
      );
    }

    if (svg?.contains('.jpeg') ?? false) {
      return Image.asset(
        svg!,
        width: width ?? size,
        height: height ?? size,
        color: color,
        colorBlendMode: colorBlendMode,
      );
    }

    if (svg?.contains('.gif') ?? false) {
      return Image.asset(
        svg!,
        width: width ?? size,
        height: height ?? size,
        color: color,
        colorBlendMode: colorBlendMode,
      );
    }

    return const Placeholder();
  }
}
