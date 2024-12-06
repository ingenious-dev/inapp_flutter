import 'package:flutter/material.dart';
import '../../../core/platform/color_palette.dart';

class BootstrapButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData? icon;
  final String text;
  bool isLoading;
  bool isDisabled;
  final String? type;

  BootstrapButton({
    Key? key,
    required this.onPressed,
    this.icon,
    required this.text,
    this.isLoading = false,
    this.isDisabled = false,
    this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    Color? textColor;
    if(isLoading || isDisabled) {
      bgColor = ColorPalette.bgLight;
      textColor = Colors.grey.withOpacity(0.2);
    } else {
      switch (type) {
        case "success":
          bgColor = ColorPalette.green;
          textColor = Colors.white;
          break;
        case "danger":
          bgColor = ColorPalette.red;
          textColor = Colors.white;
          break;

        case "light":
          bgColor = ColorPalette.bgLight;
          textColor = Colors.grey;
          break;
        case "primary-light":
          bgColor = ColorPalette.bgBlue;
          textColor = ColorPalette.blue;
          break;
        default:
          bgColor = ColorPalette.blue;
          textColor = Colors.white;
      }
    }

    final style = ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          // if (states.contains(MaterialState.pressed)) {
          //   return Theme.of(context).colorScheme.primary.withOpacity(0.5);
          // }
          return textColor; // Use the component's default.
        },
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return Theme.of(context).colorScheme.primary.withOpacity(0.5);
          }
          return bgColor; // Use the component's default.
        },
      ),
      elevation: MaterialStateProperty.resolveWith<double?>(
        (Set<MaterialState> states) {
          return 0;
        },
      ),
      // TODO https://stackoverflow.com/questions/49991444/create-a-rounded-button-button-with-border-radius-in-flutter/57482106#57482106
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // side: BorderSide(color: Colors.red)
        )
      )
    );
    
    return isLoading || icon != null
    ? DecoratedBox(
        decoration: BoxDecoration(
          // gradient:
          //     LinearGradient(colors: [Colors.blue.shade900, Colors.lightBlue]),
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        // TODO https://www.kindacode.com/article/flutter-create-a-button-with-a-loading-indicator-inside/
        child: TextButton.icon(
          icon: isLoading
              ? const CircularProgressIndicator()
              : Icon(icon),
          // label: Text(
          //   isLoading ? 'Loading...' : 'Start',
          //   style: const TextStyle(fontSize: 30),
          // ),
          label: Text(text),
          onPressed: isLoading || isDisabled ? null : onPressed,
          style: style
        )
      )
    : ElevatedButton(
        style: style,
        onPressed: isLoading || isDisabled ? null : onPressed,
        child: Text(text),
      );
  }
}
