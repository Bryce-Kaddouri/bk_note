import 'package:bk_note/provider/eraser_provider.dart';
import 'package:bk_note/provider/pen_provider.dart';
import 'package:bk_note/provider/shape_provider.dart';
import 'package:bk_note/provider/text_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // orientation landscape mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EraserProvider()),
        ChangeNotifierProvider(create: (_) => PenProvider()),
        ChangeNotifierProvider(create: (_) => TextProvider()),
        ChangeNotifierProvider(create: (_) => ShapeProvier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool sidebarOpen = true;
  String selectedShape = '';
  String action = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _controller.value = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: MediaQuery.of(context).size.height,
                width: sidebarOpen ? 80 : 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Visibility(
                  visible: sidebarOpen,
                  child: ListView(
                    children: [
                      const SizedBox(height: 40),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.redo,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.undo,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.save,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      // eraser icon
                      IconButton(
                        onPressed: () async {
                          context.read<EraserProvider>().setIsErasing(true);
                          context.read<PenProvider>().setIsPennig(false);
                          context.read<TextProvider>().setIsTexting(false);
                          await showModalBottomSheet(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            )),
                            constraints: BoxConstraints(
                              maxHeight: 120,
                              maxWidth: MediaQuery.of(context).size.width * 0.5,
                            ),
                            showDragHandle: true,
                            context: context,
                            builder: (context) {
                              return Container(
                                color: Colors.red,
                                width: MediaQuery.of(context).size.width * 0.5,
                                height: 100,
                                child: Row(
                                  children: [
                                    SizedBox(width: 20),
                                    Text('Stroke Width'),
                                    Expanded(
                                      child: Slider(
                                        value: context
                                            .watch<EraserProvider>()
                                            .strokeWidth,
                                        min: 1,
                                        max: 100,
                                        divisions: 5,
                                        label: context
                                            .watch<EraserProvider>()
                                            .strokeWidth
                                            .toString(),
                                        onChanged: (double value) {
                                          context
                                              .read<EraserProvider>()
                                              .setStrokeWidth(value);
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: Icon(
                          PhosphorIconsFill.eraser,
                          color: context.watch<EraserProvider>().isErasing
                              ? Colors.grey
                              : Colors.white,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          context.read<PenProvider>().setIsPennig(true);
                          context.read<EraserProvider>().setIsErasing(false);
                          context.read<TextProvider>().setIsTexting(false);
                          await showModalBottomSheet(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            )),
                            constraints: BoxConstraints(
                              maxHeight: 150,
                              maxWidth: MediaQuery.of(context).size.width * 0.5,
                            ),
                            showDragHandle: true,
                            context: context,
                            builder: (context) {
                              return Container(
                                color: Colors.blue,
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(width: 20),
                                        Text('Stroke Width'),
                                        Expanded(
                                          child: Slider(
                                            value: context
                                                .watch<PenProvider>()
                                                .strokeWidth,
                                            min: 1,
                                            max: 100,
                                            divisions: 10,
                                            label: context
                                                .watch<PenProvider>()
                                                .strokeWidth
                                                .toString(),
                                            onChanged: (double value) {
                                              context
                                                  .read<PenProvider>()
                                                  .setStrokeWidth(value);
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(width: 20),
                                        Text('Color'),
                                        Expanded(
                                          child: Slider(
                                            activeColor: context
                                                .watch<PenProvider>()
                                                .colorCalculated,
                                            thumbColor: context
                                                .watch<PenProvider>()
                                                .colorCalculated,
                                            value: context
                                                .watch<PenProvider>()
                                                .color,
                                            min: 0,
                                            max: 16777215,
                                            onChanged: (double value) {
                                              context
                                                  .read<PenProvider>()
                                                  .setColor(value);
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: Icon(
                          Icons.edit,
                          color: context.watch<PenProvider>().isPennig
                              ? Colors.grey
                              : Colors.white,
                          size: 30,
                        ),
                      ),
                      // Text icon
                      IconButton(
                        onPressed: () async {
                          context.read<TextProvider>().setIsTexting(true);
                          context.read<EraserProvider>().setIsErasing(false);
                          context.read<PenProvider>().setIsPennig(false);

                          await showModalBottomSheet(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            )),
                            constraints: BoxConstraints(
                              maxHeight: 150,
                              maxWidth: MediaQuery.of(context).size.width * 0.5,
                            ),
                            showDragHandle: true,
                            context: context,
                            builder: (context) {
                              return Container(
                                color: Colors.blue,
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(width: 20),
                                        Text('Stroke Width'),
                                        Expanded(
                                          child: Slider(
                                            value: context
                                                .watch<TextProvider>()
                                                .fontSize
                                                .toDouble(),
                                            min: 1,
                                            max: 100,
                                            divisions: 10,
                                            label: context
                                                .watch<TextProvider>()
                                                .fontSize
                                                .toString(),
                                            onChanged: (double value) {
                                              context
                                                  .read<TextProvider>()
                                                  .setFontSize(value.toInt());
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(width: 20),
                                        Text('Color'),
                                        Expanded(
                                          child: Slider(
                                            activeColor: context
                                                .watch<TextProvider>()
                                                .colorCalculated,
                                            thumbColor: context
                                                .watch<TextProvider>()
                                                .colorCalculated,
                                            value: context
                                                .watch<TextProvider>()
                                                .color,
                                            min: 0,
                                            max: 16777215,
                                            onChanged: (double value) {
                                              context
                                                  .read<TextProvider>()
                                                  .setColor(value);
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: Icon(
                          PhosphorIconsBold.textT,
                          color: context.watch<TextProvider>().isTexting
                              ? Colors.grey
                              : Colors.white,
                          size: 30,
                        ),
                      ),
                      // icon shape
                      IconButton(
                        onPressed: () async {
                          await showModalBottomSheet(
                            useSafeArea: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            )),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.5,
                              maxHeight: 400,
                            ),
                            isScrollControlled: true,
                            showDragHandle: true,
                            context: context,
                            builder: (context) {
                              return Container(
                                color: Colors.green,
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        SizedBox(width: 20),
                                        Text('Shapes'),
                                        SizedBox(width: 20),
                                        Expanded(
                                          child: Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                for (int i = 0;
                                                    i <
                                                        context
                                                            .read<
                                                                ShapeProvier>()
                                                            .shapeList
                                                            .length;
                                                    i++)
                                                  GestureDetector(
                                                    onTap: () {
                                                      context
                                                          .read<ShapeProvier>()
                                                          .setShapeIndex(i);
                                                    },
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height: 40,
                                                      width: 40,
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.rectangle,
                                                        border: Border.all(
                                                          color: context
                                                                      .watch<
                                                                          ShapeProvier>()
                                                                      .shapeIndex ==
                                                                  i
                                                              ? Colors.white
                                                              : Colors
                                                                  .transparent,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Icon(
                                                        context
                                                            .read<
                                                                ShapeProvier>()
                                                            .shapeList[i]['icon'],
                                                        color: Colors.white,
                                                        size: 30,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(width: 20),
                                        Text('Stroke Width'),
                                        Expanded(
                                          child: Slider(
                                            value: context
                                                .watch<ShapeProvier>()
                                                .strokeWidth
                                                .toDouble(),
                                            min: 1,
                                            max: 100,
                                            divisions: 10,
                                            label: context
                                                .watch<ShapeProvier>()
                                                .strokeWidth
                                                .toString(),
                                            onChanged: (double value) {
                                              context
                                                  .read<ShapeProvier>()
                                                  .setStrokeWidth(
                                                      value.toInt());
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(width: 20),
                                        Text('Color'),
                                        Expanded(
                                          child: Slider(
                                            activeColor: context
                                                .watch<ShapeProvier>()
                                                .colorCalculated,
                                            thumbColor: context
                                                .watch<ShapeProvier>()
                                                .colorCalculated,
                                            value: context
                                                .watch<ShapeProvier>()
                                                .color,
                                            min: 0,
                                            max: 16777215,
                                            onChanged: (double value) {
                                              context
                                                  .read<ShapeProvier>()
                                                  .setColor(value);
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(width: 20),
                                        Text('Fill Shape'),
                                        SizedBox(width: 20),
                                        Expanded(
                                            child: Container(
                                          alignment: Alignment.center,
                                          child: Switch(
                                            value: context
                                                .watch<ShapeProvier>()
                                                .fillShape,
                                            onChanged: (value) {
                                              context
                                                  .read<ShapeProvier>()
                                                  .setFillShape(value);
                                            },
                                          ),
                                        )),
                                        SizedBox(width: 20),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: Icon(
                          PhosphorIconsBold.shapes,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              print(_controller.value);
              // move the positioned widget
              return Transform.translate(
                  offset: Offset(_controller.value * 60, 10),
                  /* child: Positioned(
                    top: 20,
                    left: sidebarOpen ? 60 : 0,*/
                  child: GestureDetector(
                    onTap: () {
                      sidebarOpen
                          ? _controller.reverse()
                          : _controller.forward();
                      setState(() {
                        sidebarOpen = !sidebarOpen;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Transform.rotate(
                          angle: _controller.value * 3.14,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ));
            },
          ),

          /* Positioned(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sidebarOpen = !sidebarOpen;
                });
              },
              child: Container(
                padding: EdgeInsets.only(
                  left: sidebarOpen ? 8 : 4,
                ),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    sidebarOpen
                        ? Icons.arrow_back_ios
                        : Icons.arrow_forward_ios,
                    size: 20,
                  ),
                ),
              ),
            ),
            top: 20,
            left: sidebarOpen ? 60 : 0,
          ),*/
        ],
      ),
    );
  }
}
