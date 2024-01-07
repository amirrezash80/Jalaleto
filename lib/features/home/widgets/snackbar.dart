import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> mySnackBar(context,String message){
  return  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      behavior: SnackBarBehavior.floating,
      content: Container(
        alignment: Alignment.center,
        child: Text(message),
      ),
    ),
  );
}
