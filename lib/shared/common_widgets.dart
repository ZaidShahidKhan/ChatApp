import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/helpers.dart';

/// Collection of reusable widgets that are used throughout the app
class CommonWidgets {
  /// Creates a standard app bar with consistent styling
  static AppBar appBar({
    required String title,
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
    Widget? leading,
    PreferredSizeWidget? bottom,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      bottom: bottom,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
  }

  /// Creates a primary button with standardized styling
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 12),
    IconData? icon,
  }) {
    final buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 10),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
        else if (icon != null)
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Icon(icon, size: 20),
          ),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    return Padding(
      padding: padding,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          minimumSize: isFullWidth ? const Size(double.infinity, 48) : null,
        ),
        child: buttonChild,
      ),
    );
  }

  /// Creates a secondary button with standardized styling
  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 12),
    IconData? icon,
  }) {
    final buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 10),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        else if (icon != null)
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Icon(icon, size: 20),
          ),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    return Padding(
      padding: padding,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          minimumSize: isFullWidth ? const Size(double.infinity, 48) : null,
        ),
        child: buttonChild,
      ),
    );
  }

  /// Creates a text field with standardized styling
  static Widget textField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool enabled = true,
    VoidCallback? onTap,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    int? maxLines = 1,
    int? maxLength,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 8),
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    List<TextInputFormatter>? inputFormatters,
    FocusNode? focusNode,
  }) {
    return Padding(
      padding: padding,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        enabled: enabled,
        onTap: onTap,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        maxLines: maxLines,
        maxLength: maxLength,
        autovalidateMode: autovalidateMode,
        inputFormatters: inputFormatters,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  /// Creates a search field with standardized styling
  static Widget searchField({
    required TextEditingController controller,
    required String hintText,
    void Function(String)? onChanged,
    VoidCallback? onClear,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    FocusNode? focusNode,
  }) {
    return Padding(
      padding: padding,
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller.clear();
              if (onClear != null) onClear();
              if (onChanged != null) onChanged('');
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        ),
      ),
    );
  }

  /// Creates a user avatar with initial fallback
  // static Widget userAvatar({
  //   required String userId,
  //   required String? imageUrl,
  //   required String displayName,
  //   double size = 40,
  //   void Function()? onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: CircleAvatar(
  //       radius: size / 2,
  //       backgroundColor: AppHelpers.getAvatarColor(userId),
  //       foregroundImage: imageUrl != null && imageUrl.isNotEmpty
  //           ? CachedNetworkImageProvider(imageUrl) as ImageProvider
  //           : null,
  //       child: imageUrl == null || imageUrl.isEmpty
  //           ? Text(
  //         AppHelpers.getInitials(displayName),
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontWeight: FontWeight.w600,
  //           fontSize: size * 0.4,
  //         ),
  //       )
  //           : null,
  //     ),
  //   );
  // }

  /// Creates a badge with a count
  static Widget badge({
    required int count,
    Color? color,
    double size = 20,
  }) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(4),
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      decoration: BoxDecoration(
        color: color ?? Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  //
  // /// Creates a time chip showing message or activity time
  // static Widget timeChip(DateTime time) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: Colors.black.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Text(
  //       AppHelpers.formatMessageTime(time),
  //       style: const TextStyle(
  //         fontSize: 12,
  //         fontWeight: FontWeight.w500,
  //       ),
  //     ),
  //   );
  // }

  /// Creates a divider with label
  static Widget labeledDivider(
      String label, {
        Color? color,
        double thickness = 1,
        double indent = 20,
        double endIndent = 20,
      }) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: color,
            thickness: thickness,
            indent: indent,
            endIndent: 10,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color ?? Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Divider(
            color: color,
            thickness: thickness,
            indent: 10,
            endIndent: endIndent,
          ),
        ),
      ],
    );
  }

  /// Creates an empty state widget
  static Widget emptyState({
    required String message,
    IconData icon = Icons.inbox,
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            if (onActionPressed != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Creates a loading indicator
  static Widget loadingIndicator({String? message}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Creates an online status indicator
  static Widget onlineStatusIndicator(bool isOnline, {double size = 12}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOnline ? Colors.green : Colors.grey,
        border: Border.all(
          color: Colors.white,
          width: size / 6,
        ),
      ),
    );
  }

  /// Creates a setting item
  static Widget settingItem({
    required String title,
    required IconData icon,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}