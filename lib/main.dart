import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import 'package:bk_note/provider/eraser_provider.dart';
import 'package:bk_note/provider/hand_provider.dart';
import 'package:bk_note/provider/pen_provider.dart';
import 'package:bk_note/provider/shape_provider.dart';
import 'package:bk_note/provider/text_provider.dart';
import 'package:bk_note/provider/un_or_re_do_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:flutter_painter_v2/flutter_painter_extensions.dart';
import 'package:flutter_painter_v2/flutter_painter_pure.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

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
        ChangeNotifierProvider(create: (_) => UnOrReDoProvider()),
        ChangeNotifierProvider(create: (_) => HandProvider()),
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
  double _progress = 0.0;
  late Animation<double> animation;
  bool sidebarOpen = true;
  String selectedShape = '';
  String action = '';
  FocusNode textFocusNode = FocusNode();
  late PainterController controller;
  static const Color red = Color(0xFFFF0000);
  Paint shapePaint = Paint()
    ..strokeWidth = 5
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void initState() {
    super.initState();

    var controllerAnimationLine = AnimationController(
        duration: Duration(milliseconds: 3000), vsync: this);

    animation = Tween(begin: 1.0, end: 0.0).animate(controllerAnimationLine)
      ..addListener(() {
        setState(() {
          _progress = animation.value;
        });
      });

    controllerAnimationLine.forward();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _controller.value = 1;

    controller = PainterController(
        settings: PainterSettings(
            text: TextSettings(
              focusNode: textFocusNode,
              textStyle: const TextStyle(
                  fontWeight: FontWeight.bold, color: red, fontSize: 18),
            ),
            freeStyle: const FreeStyleSettings(
              color: red,
              strokeWidth: 10,
            ),
            shape: ShapeSettings(
              paint: shapePaint,
              drawOnce: false,
            ),
            scale: const ScaleSettings(
              enabled: true,
              minScale: 1,
              maxScale: 5,
            )));
    // Listen to focus events of the text field
    textFocusNode.addListener(onFocus);

    controller.addListener(() {
      context.read<UnOrReDoProvider>().setCanRedo(controller.canRedo);
      context.read<UnOrReDoProvider>().setCanUndo(controller.canUndo);

      print('controller can redo');

      print(controller.canRedo);
      print('controller can undo');
      print(controller.canUndo);
      if (controller.shapePaint == null) {
        context.read<ShapeProvier>().setShapeIndex(-1);
      }
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      controller.freeStyleColor = context.read<PenProvider>().colorCalculated;
      controller.freeStyleStrokeWidth = context.read<PenProvider>().strokeWidth;
      controller.textStyle = controller.textStyle.copyWith(
          color: context.read<TextProvider>().colorCalculated,
          fontSize: context.read<TextProvider>().fontSize.toDouble());
      controller.shapePaint = controller.shapePaint?.copyWith(
        color: context.read<ShapeProvier>().colorCalculated,
        strokeWidth: context.read<ShapeProvier>().strokeWidth.toDouble(),
        style: context.read<ShapeProvier>().fillShape
            ? PaintingStyle.fill
            : PaintingStyle.stroke,
      );
    });
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
                        onPressed: () {
                          if (controller.canRedo) {
                            redo();
                          } else {
                            return;
                          }
                        },
                        icon: Icon(
                          Icons.redo,
                          color: context.watch<UnOrReDoProvider>().canRedo
                              ? Colors.white
                              : Colors.grey,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (controller.canUndo) {
                            undo();
                          } else {
                            return;
                          }
                        },
                        icon: Icon(
                          Icons.undo,
                          color: context.watch<UnOrReDoProvider>().canUndo
                              ? Colors.white
                              : Colors.grey,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          removeSelectedDrawable();
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          renderImage();
                        },
                        icon: Icon(
                          Icons.save,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          useHand();
                          context.read<HandProvider>().setIsHanding(true);
                          context.read<EraserProvider>().setIsErasing(false);
                          context.read<PenProvider>().setIsPennig(false);
                          context.read<TextProvider>().setIsTexting(false);
                          context.read<ShapeProvier>().setIsShaping(false);
                        },
                        icon: Icon(
                          // icon to move the canvas
                          PhosphorIconsFill.hand,
                          color: context.watch<HandProvider>().isHanding
                              ? Colors.grey
                              : Colors.white,
                          size: 30,
                        ),
                      ),

                      // eraser icon
                      IconButton(
                        onPressed: () async {
                          toggleFreeStyleErase();
                          context.read<EraserProvider>().setIsErasing(true);
                          context.read<PenProvider>().setIsPennig(false);
                          context.read<TextProvider>().setIsTexting(false);
                          context.read<ShapeProvier>().setIsShaping(false);
                          context.read<HandProvider>().setIsHanding(false);

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
                                          setFreeStyleStrokeWidth(value);
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
                          toggleFreeStyleDraw();
                          context.read<PenProvider>().setIsPennig(true);
                          context.read<EraserProvider>().setIsErasing(false);
                          context.read<TextProvider>().setIsTexting(false);
                          context.read<ShapeProvier>().setIsShaping(false);
                          context.read<HandProvider>().setIsHanding(false);

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
                                              setFreeStyleStrokeWidth(value);
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
                                              setFreeStyleColor(context
                                                  .read<PenProvider>()
                                                  .colorCalculated);
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
                          addText();
                          setTextFontSize(
                              context.read<TextProvider>().fontSize.toDouble());
                          setTextColor();
                          context.read<TextProvider>().setIsTexting(true);
                          context.read<EraserProvider>().setIsErasing(false);
                          context.read<PenProvider>().setIsPennig(false);
                          context.read<ShapeProvier>().setIsShaping(false);
                          context.read<HandProvider>().setIsHanding(false);

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
                                        Text('Font Size'),
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
                                              setTextFontSize(value);
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
                                              setTextColor();
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
                          context.read<ShapeProvier>().setIsShaping(true);
                          context.read<EraserProvider>().setIsErasing(false);
                          context.read<PenProvider>().setIsPennig(false);
                          context.read<TextProvider>().setIsTexting(false);
                          context.read<HandProvider>().setIsHanding(false);

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
                                                      Map map = context
                                                          .read<ShapeProvier>()
                                                          .shapeList[i];
                                                      // map to list
                                                      List list =
                                                          map.values.toList();
                                                      print(list);
                                                      // get the factory
                                                      final factory = list[0];
                                                      print(factory);
                                                      selectShape(
                                                          factory.toString());
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
                                              setShapeFactoryPaint(
                                                  (controller.shapePaint ??
                                                          shapePaint)
                                                      .copyWith(
                                                strokeWidth: value,
                                              ));
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
                                              setShapeFactoryPaint(
                                                  (controller.shapePaint ??
                                                          shapePaint)
                                                      .copyWith(
                                                color: context
                                                    .read<ShapeProvier>()
                                                    .colorCalculated,
                                              ));
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
                                              setShapeFactoryPaint(
                                                  (controller.shapePaint ??
                                                          shapePaint)
                                                      .copyWith(
                                                style: value
                                                    ? PaintingStyle.fill
                                                    : PaintingStyle.stroke,
                                              ));
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
                          color: context.watch<ShapeProvier>().isShaping
                              ? Colors.grey
                              : Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                  child: Container(
                child: Stack(
                  children: [
                    Positioned(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width - 80,
                        child: Column(
                          children: [
                            for (int i = 50;
                                i < MediaQuery.of(context).size.width;
                                i += 50)
                              Line(
                                  y: i,
                                  x: -MediaQuery.of(context)
                                          .size
                                          .height
                                          .toInt() +
                                      30),
                          ],
                        ),
                      ),
                      left: 0,
                      top: 0,
                    ),
                    FlutterPainter(
                      controller: controller,
                    ),
                  ],
                ),
              )),
            ],
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              print(_controller.value);
              // move the positioned widget
              return Transform.translate(
                offset: Offset(_controller.value * 60, 10),
                child: GestureDetector(
                  onTap: () {
                    sidebarOpen ? _controller.reverse() : _controller.forward();
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Updates UI when the focus changes
  void onFocus() {
    setState(() {});
  }

  void undo() {
    controller.undo();
  }

  void redo() {
    controller.redo();
  }

  void toggleFreeStyleDraw() {
    // stop using shape
    controller.shapeFactory = null;
    controller.freeStyleMode = FreeStyleMode.draw;
  }

  void toggleFreeStyleErase() {
    controller.shapeFactory = null;

    controller.freeStyleMode = FreeStyleMode.erase;
  }

  void addText() {
    controller.shapeFactory = null;

    if (controller.freeStyleMode != FreeStyleMode.none) {
      controller.freeStyleMode = FreeStyleMode.none;
    }
    controller.addText();
  }

  void setFreeStyleStrokeWidth(double value) {
    controller.freeStyleStrokeWidth = value;
  }

  void setFreeStyleColor(Color color) {
    controller.freeStyleColor = color;
  }

  void setTextFontSize(double size) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.textSettings = controller.textSettings.copyWith(
          textStyle:
              controller.textSettings.textStyle.copyWith(fontSize: size));
    });
  }

  void setTextColor() {
    controller.textStyle = controller.textStyle
        .copyWith(color: context.read<TextProvider>().colorCalculated);
  }

  void selectShape(String shape) {
    ShapeFactory? factory;
    if (shape == "Line") {
      factory = LineFactory();
    } else if (shape == "Arrow") {
      factory = ArrowFactory();
    } else if (shape == "Double Arrow") {
      factory = DoubleArrowFactory();
    } else if (shape == "Rectangle") {
      factory = RectangleFactory();
    } else if (shape == "Oval") {
      factory = OvalFactory();
    } else {
      factory = LineFactory();
    }
    controller.shapeFactory = factory;
  }

  void setShapeFactoryPaint(Paint paint) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.shapePaint = paint;
    });
  }

  void removeSelectedDrawable() {
    final selectedDrawable = controller.selectedObjectDrawable;
    if (selectedDrawable != null) controller.removeDrawable(selectedDrawable);
  }

  void useHand() {
    controller.shapeFactory = null;
    controller.freeStyleMode = FreeStyleMode.none;
  }

  void renderImage() async {
    ui.Image img = await controller.renderImage(
      Size(1080, 1080),
    );
    // final file = File('${(await getTemporaryDirectory()).path}/img.png');
    // await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    Uint8List? bytes = await img.pngBytes;

    final file = File('${(await getTemporaryDirectory()).path}/img.png');
    await file.writeAsBytes(bytes!);

    print(file.path);

    print(file.length());

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Container(
                height: 100,
                width: 100,
                child: Image.memory(bytes!),
              ),
            ));
  }
}

class Line extends StatefulWidget {
  int y;
  int x;

  Line({
    required this.y,
    required this.x,
  });

  @override
  State<StatefulWidget> createState() => _LineState();
}

class _LineState extends State<Line> with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    var controller =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      double widthScreen = MediaQuery.of(context).size.height.toDouble() - 30;

      animation = Tween(begin: 0.0, end: widthScreen).animate(controller)
        ..addListener(() {
          print(animation.value);
          setState(() {
            _progress = animation.value;
          });
        });

      controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: LinePainter(_progress, widget.y, widget.x));
  }
}

class LinePainter extends CustomPainter {
  late Paint _paint;
  double _progress;
  int y;
  int x;

  LinePainter(this._progress, this.y, this.x) {
    _paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    print('y: $y');
    print('x: $x');
    canvas.drawLine(Offset(x.toDouble(), y.toDouble()),
        Offset(_progress, y.toDouble()), _paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate._progress != _progress;
  }
}
