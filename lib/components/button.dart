library flutter_vortezz_base;

import 'package:flutter/material.dart';
import 'package:flutter_vortezz_base/components/text.dart';
import 'package:flutter_vortezz_base/struct/client.dart';

class Button extends StatelessWidget {
  const Button({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.client,
    this.isBlack = true,
    this.isDisabled = false,
  }) : super(key: key);

  final String text;
  final Function() onPressed;
  final Client client;
  final bool isBlack;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.only(
        top: 10,
      ),
      height: 80,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isBlack ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10,
            ),
          ),
        ),
        child: CustomText(
          text: text,
          client: client,
          color: isBlack
              ? Colors.white
              : (isDisabled
                  ? client.darkTheme
                      ? Colors.white
                      : Colors.black
                  : Colors.black),
          textType: TextType.emphasis,
        ),
      ),
    );
  }
}
