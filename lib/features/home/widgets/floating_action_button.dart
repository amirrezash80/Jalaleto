import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:roozdan/features/home/presentation/screens/create_event_screen.dart';
import 'package:roozdan/features/groups/create_group_screen.dart';



class myFloatingActionButton extends StatelessWidget {
  var _key;

  myFloatingActionButton(this._key);

  void showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child:
      const Directionality(textDirection: TextDirection.rtl, child: Text("باشه")),
      onPressed: () {
        Navigator.of(context).pop(); // Close the dialog
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      key: _key,
      pos: ExpandableFabPos.right,
      // duration: const Duration(milliseconds: 500),
      // distance: 200.0,
      // type: ExpandableFabType.up,
      // pos: ExpandableFabPos.left,
      // childrenOffset: const Offset(0, 20),
      // fanAngle: 40,
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        child: const Icon(Icons.add),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey[700]!,
        // shape: const CircleBorder(),
        // angle: 3.14 * 2,
      ),
      // closeButtonBuilder: FloatingActionButtonBuilder(
      //   size: 56,
      //   builder: (BuildContext context, void Function()? onPressed,
      //       Animation<double> progress) {
      //     return IconButton(
      //       onPressed: onPressed,
      //       icon: const Icon(
      //         Icons.check_circle_outline,
      //         size: 40,
      //       ),
      //     );
      //   },
      // ),
      overlayStyle: ExpandableFabOverlayStyle(
         // color: Colors.black.withOpacity(0.5),
        blur: 5,
      ),
      onOpen: () {},
      afterOpen: () {},
      onClose: () {},
      afterClose: () {},
      children: [
        ElevatedButton(
          // shape: const CircleBorder(),
          // heroTag: null,
          child: const Column(
            children: [
              Icon(Icons.group_add),
              Text("ایجاد گروه جدید"),
            ],
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CreateGroupDialog(); // Show the dialog
              },
            );
          },
        ),
        ElevatedButton(
          // shape: const CircleBorder(),
          // heroTag: null,
          child: const Column(
            children: [
              Icon(Icons.add),
              Text("ساخت رویداد جدید"),
            ],
          ),
          onPressed: () {
            Navigator.pushNamed(context, CreateEventForm.routeName);

          },
        ),
        // ElevatedButton(
        //   // shape: const CircleBorder(),
        //   // heroTag: null,
        //   child: Column(
        //     children: [
        //       const Icon(Icons.share),
        //       Text("data")
        //     ],
        //   ),
        //   onPressed: () {
        //     final state = _key.currentState;
        //     if (state != null) {
        //       debugPrint('isOpen:${state.isOpen}');
        //       state.toggle();
        //     }
        //   },
        // ),
      ],
    );
  }
}
