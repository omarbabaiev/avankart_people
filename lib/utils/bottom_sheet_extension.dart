import 'package:flutter/material.dart';
import '../widgets/bottom_sheet_handle_widget.dart';
import 'package:avankart_people/utils/vibration_util.dart';

/// Bottom sheet kullanımını kolaylaştırmak için extension
extension BottomSheetExtension on BuildContext {
  /// Performansı iyileştirilmiş BottomSheet gösterme fonksiyonu
  Future<T?> showPerformantBottomSheet<T>({
    required Widget Function(BuildContext) builder,
    bool isScrollControlled = false,
    Color? backgroundColor,
    Color? barrierColor,
    double? elevation,
    ShapeBorder? shape,
    bool enableDrag = true,
    bool isDismissible = true,
    bool useRootNavigator = false,
    bool useSafeArea = false,
  }) {
    // Bottom sheet açma - haptic feedback
    VibrationUtil.lightVibrate();

    return showModalBottomSheet<T>(
      context: this,
      builder: builder,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor ?? Colors.white,
      barrierColor: barrierColor,
      elevation: elevation,
      clipBehavior: Clip.hardEdge, // Performans iyileştirmesi
      shape: shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      useRootNavigator: useRootNavigator,
      useSafeArea: useSafeArea,
    );
  }

  /// Standart bir bottom sheet handle'ı oluşturma
  Widget buildBottomSheetHandle() {
    return const BottomSheetHandleWidget();
  }
}
