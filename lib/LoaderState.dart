import 'package:flutter/material.dart';

import 'package:gif/gif.dart';

class LoaderState extends StatefulWidget {
  const LoaderState({super.key});

  @override
  State<LoaderState> createState() => _LoaderStateState();
}

class _LoaderStateState extends State<LoaderState>
    with TickerProviderStateMixin {
  late final GifController controller1;

  @override
  void initState() {
    // TODO: implement initState
    controller1 = GifController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    controller1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        elevation: 20,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
            // color: Color(0XFF0000FFFF),
            width: 110,
            height: 110,
            decoration: BoxDecoration(
                color: const Color(0xff0000ffff),
                borderRadius: BorderRadius.circular(8.0)),
            child: Container(
              margin: const EdgeInsets.only(right: 20.0),
              child: Gif(
                image: const AssetImage("assets/images/dentskanload.gif"),
                controller:
                    controller1, // if duration and fps is null, original gif fps will be used.
                autostart: Autostart.loop,
                onFetchCompleted: () {
                  controller1.reset();
                  controller1.forward();
                },
              ),
            )));
  }
}