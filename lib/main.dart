import 'dart:io';
import 'dart:typed_data';
import 'package:bk_note/provider/auth_provider.dart';
import 'package:bk_note/provider/grid_provider.dart';
import 'package:bk_note/provider/sarch_provider.dart';
import 'package:bk_note/provider/storage_provider.dart';
import 'package:bk_note/screens/auth_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'package:bk_note/provider/eraser_provider.dart';
import 'package:bk_note/provider/hand_provider.dart';
import 'package:bk_note/provider/pen_provider.dart';
import 'package:bk_note/provider/shape_provider.dart';
import 'package:bk_note/provider/text_provider.dart';
import 'package:bk_note/provider/un_or_re_do_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/route_manager.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:flutter_painter_v2/flutter_painter_extensions.dart';
import 'package:flutter_painter_v2/flutter_painter_pure.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // orientation landscape mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EraserProvider()),
        ChangeNotifierProvider(create: (_) => PenProvider()),
        ChangeNotifierProvider(create: (_) => TextProvider()),
        ChangeNotifierProvider(create: (_) => ShapeProvier()),
        ChangeNotifierProvider(create: (_) => UnOrReDoProvider()),
        ChangeNotifierProvider(create: (_) => HandProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GridProvider()),
        ChangeNotifierProvider(create: (_) => StorageProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      context.read<AuthProvider>().getCurentUser();
      print(context.read<AuthProvider>().user);
    });
/*
    context.read<AuthProvider>().getCurentUser();
*/
  }

  bool isDone = false;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: context.watch<AuthProvider>().user == null
          ? AuthScreen()
          : MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
  AnimationController? _controllerAnimationUpload;
  late PageController pageController;
  SearchController searchController = SearchController();

  @override
  void initState() {
    super.initState();

    context
        .read<StorageProvider>()
        .getAllImage(context.read<AuthProvider>().user!.uid);

    _controllerAnimationUpload = AnimationController(
        duration: Duration(milliseconds: 3000), vsync: this);

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
    int nbPage = context.read<StorageProvider>().lstImages.length;
    if (nbPage != 0 || context.watch<StorageProvider>().isCharged == true) {
      print('nbPage test');
      print(nbPage);
      pageController = PageController(
        initialPage: nbPage + 1,
        viewportFraction: 1,
      );

      pageController.addListener(() {
        print('pageController.page');
        print(pageController.page);
        context
            .read<StorageProvider>()
            .setSelectedPage(pageController.page!.toInt());
      });
    }
    print('nbPage');
    print(nbPage);
    return Scaffold(
      extendBodyBehindAppBar: true,
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
                ),
                child: Visibility(
                  visible: sidebarOpen,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: ListView(
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.dialog(
                              AlertDialog(
                                title: Text('Are you sure?'),
                                content: Text('Do you want to logout?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.read<AuthProvider>().logout();
                                      Get.back();
                                    },
                                    child: Text('Logout'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        /*IconButton(
                          onPressed: () {
                            context.read<SearchProvider>().setSearch(
                                !context.read<SearchProvider>().isSearch);
                            // display sarch modal in fill screen
                          },
                          icon: Icon(
                            Icons.search,
                            color: context.read<SearchProvider>().isSearch
                                ? Colors.grey
                                : Colors.white,
                            size: 30,
                          ),
                        ),*/
                        SearchAnchor(
                          searchController: searchController,
                          builder: (context, anchor) {
                            return IconButton(
                              icon: Icon(
                                Icons.search,
                                color: context.read<SearchProvider>().isSearch
                                    ? Colors.grey
                                    : Colors.white,
                                size: 30,
                              ),
                              onPressed: () {
                                searchController.openView();
                              },
                            );
                            /*  Container(
                            margin: EdgeInsets.only(
                              top: 5,
                              left: 40,
                              right: 40,
                            ),
                            height: 50,
                            width: MediaQuery.of(context).size.width - 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: Colors.grey,
                              ),
                            ),
                          );*/
                          },
                          suggestionsBuilder: (context, searchController) {
                            print('searchController');
                            print(searchController.text);
                            List data = [];
                            if (searchController.text.isEmpty) {
                              data = context.read<StorageProvider>().lstImages;
                            } else {
                              data = context
                                  .read<StorageProvider>()
                                  .lstImages
                                  .where((element) => element['keywords']
                                      .toString()
                                      .toLowerCase()
                                      .contains(
                                          searchController.text.toLowerCase()))
                                  .toList();
                            }
                            print('data');
                            print(data);
                            return List.generate(
                                data.isEmpty
                                    ? 1
                                    : ((data.length / 2).floor() +
                                        data.length % 2), (index) {
                              return data.isEmpty
                                  ? ListTile(
                                      title: Text('No data found'),
                                    )
                                  : LayoutBuilder(
                                      builder: (context, constraint) {
                                      return Row(
                                        children: [
                                          SizedBox(width: 20),
                                          for (int i = 0; i < 2; i++)
                                            if (index * 2 + i < data.length)
                                              Expanded(
                                                child: Container(
                                                  margin: EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    border: Border.all(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  height: 300,
                                                  child: InkWell(
                                                    hoverColor:
                                                        Colors.transparent,
                                                    onTap: () {
                                                      searchController
                                                          .closeView(
                                                              searchController
                                                                  .text);
                                                      int indexSelected = context
                                                          .read<
                                                              StorageProvider>()
                                                          .lstImages
                                                          .indexWhere(
                                                              (element) =>
                                                                  element[
                                                                      'url'] ==
                                                                  data[index *
                                                                          2 +
                                                                      i]['url']);
                                                      print('indexSelected');
                                                      print(indexSelected);
                                                      pageController
                                                          .animateToPage(
                                                              indexSelected,
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      500),
                                                              curve: Curves
                                                                  .easeInOut);
                                                      context
                                                          .read<
                                                              StorageProvider>()
                                                          .setSelectedPage(
                                                              indexSelected);
                                                    },
                                                    child: Column(
                                                      children: [
                                                        SizedBox(height: 10),
                                                        Text(
                                                          data[index * 2 + i]
                                                                  ['keywords']
                                                              .join(', '),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          height: 250,
                                                          width:
                                                              double.infinity,
                                                          child: Image.network(
                                                            data[index * 2 + i]
                                                                ['url'],
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        SizedBox(height: 10),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            else
                                              Expanded(
                                                child: Container(
                                                  margin: EdgeInsets.all(20),
                                                  height: 300,
                                                  width: double.infinity,
                                                  color: Colors.transparent,
                                                ),
                                              ),
                                          SizedBox(width: 20),
                                        ],
                                      );
                                    });
                            });
                          },
                          isFullScreen: true,
                        ),
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
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.5,
                              ),
                              showDragHandle: true,
                              context: context,
                              builder: (context) {
                                return Container(
                                  color: Theme.of(context).colorScheme.primary,
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
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
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.5,
                              ),
                              showDragHandle: true,
                              context: context,
                              builder: (context) {
                                return Container(
                                  color: Colors.blue,
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
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
                            setTextFontSize(context
                                .read<TextProvider>()
                                .fontSize
                                .toDouble());
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
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.5,
                              ),
                              showDragHandle: true,
                              context: context,
                              builder: (context) {
                                return Container(
                                  color: Colors.blue,
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
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
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.5,
                                maxHeight: 400,
                              ),
                              isScrollControlled: true,
                              showDragHandle: true,
                              context: context,
                              builder: (context) {
                                return Container(
                                  color: Colors.green,
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
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
                                                    MainAxisAlignment
                                                        .spaceEvenly,
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
                                                            .read<
                                                                ShapeProvier>()
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
                                                            .read<
                                                                ShapeProvier>()
                                                            .setShapeIndex(i);
                                                      },
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        height: 40,
                                                        width: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape: BoxShape
                                                              .rectangle,
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
                        IconButton(
                          onPressed: () {
                            context
                                .read<GridProvider>()
                                .setGrid(!context.read<GridProvider>().isGrid);
                          },
                          icon: Icon(
                            Icons.grid_3x3_sharp,
                            color: context.watch<GridProvider>().isGrid
                                ? Colors.grey
                                : Colors.white,
                            size: 30,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height - 50,
                    width: MediaQuery.of(context).size.width - 80,
                    child: context
                                .watch<StorageProvider>()
                                .lstImages
                                .isNotEmpty ||
                            context.watch<StorageProvider>().isCharged == true
                        ? PageView(
                            physics:
                                context.watch<StorageProvider>().selectedPage ==
                                        context
                                            .watch<StorageProvider>()
                                            .lstImages
                                            .length
                                    ? NeverScrollableScrollPhysics()
                                    : AlwaysScrollableScrollPhysics(),
                            controller: pageController,
                            children: [
                              for (var image
                                  in context.watch<StorageProvider>().lstImages)
                                Container(
                                  child: Image.network(
                                    image['url'],
                                    fit: BoxFit.cover,
                                  ),
                                ),

                              // start canvas
                              Container(
                                child: Stack(
                                  children: [
                                    Visibility(
                                      visible:
                                          context.watch<GridProvider>().isGrid,
                                      child: Positioned(
                                        child: Container(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              80,
                                          child: Column(
                                            children: [
                                              for (int i = 50;
                                                  i <
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width;
                                                  i += 50)
                                                Line(
                                                  y: i,
                                                  x: -MediaQuery.of(context)
                                                          .size
                                                          .height
                                                          .toInt() +
                                                      30,
                                                  isSideBarOpen: sidebarOpen,
                                                ),
                                            ],
                                          ),
                                        ),
                                        left: 0,
                                        top: 0,
                                      ),
                                    ),
                                    FlutterPainter(
                                      controller: controller,
                                    ),
                                  ],
                                ),
                              ),
                              // end cqanva
                            ],
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          ),

                    // end of the canvas
                  ),
                  Container(
                    height: 50,
                    width: sidebarOpen
                        ? MediaQuery.of(context).size.width - 80
                        : MediaQuery.of(context).size.width,
                    color: Theme.of(context).colorScheme.primary,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(30, 30),
                            shape: CircleBorder(),
                            backgroundColor:
                                context.watch<StorageProvider>().selectedPage ==
                                        0
                                    ? Colors.grey
                                    : Colors.white,
                            foregroundColor:
                                context.watch<StorageProvider>().selectedPage ==
                                        0
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            if (context.read<StorageProvider>().selectedPage ==
                                0) {
                              return;
                            }
                            pageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                          },
                          child: Icon(Icons.arrow_back_ios),
                        ),
                        SizedBox(width: 5),
                        TextButton(
                          onPressed: () {
                            print('pressed');
                            ScrollController scrollController =
                                ScrollController();

                            Get.dialog(
                              AlertDialog(
                                scrollable: false,
                                alignment: Alignment.center,
                                actionsAlignment: MainAxisAlignment.center,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                titleTextStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                title: Text(
                                  'Choose a page',
                                  textAlign: TextAlign.center,
                                ),
                                content: Container(
                                  height: 225,
                                  width: 300,
                                  child: ListView.builder(
                                      itemCount: context
                                              .read<StorageProvider>()
                                              .lstImages
                                              .length +
                                          1,
                                      controller: scrollController,
                                      itemBuilder: (context, index) {
                                        scrollController.animateTo(
                                            context
                                                    .read<StorageProvider>()
                                                    .selectedPage
                                                    .toDouble() *
                                                50,
                                            duration:
                                                Duration(milliseconds: 300),
                                            curve: Curves.easeIn);

                                        return InkWell(
                                          onTap: () {
                                            context
                                                .read<StorageProvider>()
                                                .setSelectedPage(index);
                                            pageController.jumpToPage(index);
                                            Get.back();
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: context
                                                            .read<
                                                                StorageProvider>()
                                                            .selectedPage ==
                                                        index
                                                    ? Colors.white
                                                    : Colors.transparent,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            height: 50,
                                            child: Text(
                                              'Page ${index + 1}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                                actionsOverflowButtonSpacing: 20,
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.read<AuthProvider>().logout();
                                      Get.back();
                                    },
                                    child: Text('Go to page',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                              barrierDismissible: false,
                            );
                          },
                          child: Text(
                            '${context.watch<StorageProvider>().selectedPage + 1}/${context.watch<StorageProvider>().lstImages.length + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(30, 30),
                            shape: CircleBorder(),
                            backgroundColor:
                                context.watch<StorageProvider>().selectedPage ==
                                        context
                                            .watch<StorageProvider>()
                                            .lstImages
                                            .length
                                    ? Colors.grey
                                    : Colors.white,
                            foregroundColor:
                                context.watch<StorageProvider>().selectedPage ==
                                        context
                                            .watch<StorageProvider>()
                                            .lstImages
                                            .length
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            if (context.read<StorageProvider>().selectedPage ==
                                context
                                    .read<StorageProvider>()
                                    .lstImages
                                    .length) {
                              return;
                            }
                            pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                          },
                          child: Icon(Icons.arrow_forward_ios),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
    List<String> keywords = [];
    List<TextEditingController> controllers = [TextEditingController()];
    Stream<int> getNbController() async* {
      yield controllers.length;
    }

    Widget input = Row(
      children: [
        Expanded(
          child: TextField(
            controller: controllers[0],
            decoration: InputDecoration(
              hintText: 'Enter keyword',
            ),
          ),
        ),
      ],
    );
    Get.dialog(
        AlertDialog(
          title: Text('Choose keywords'),
          content: Container(
            child: Column(children: [
              SizedBox(height: 10),
              StreamBuilder(
                  builder: (context, snapshot) {
                    int nb = snapshot.data ?? 0;
                    print('nb');
                    print(nb);
                    print('snapshot');
                    print(snapshot.data);
                    if (snapshot.hasData) {
                      return Container(
                          height: 300,
                          width: 300,
                          child: ListView.builder(
                              itemCount: nb,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: controllers[index],
                                        decoration: InputDecoration(
                                          hintText: 'Enter keyword',
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        controllers.removeAt(index);
                                      },
                                      icon: Icon(Icons.delete),
                                    ),
                                  ],
                                );
                              }));
                    } else {
                      return Container();
                    }
                  },
                  stream: Stream.periodic(
                      Duration(milliseconds: 1000), (x) => controllers.length)),
              IconButton(
                onPressed: () {
                  controllers.add(TextEditingController());
                },
                icon: Icon(Icons.add),
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                ui.Image img = await controller.renderImage(
                  Size(1920, 1080),
                );
                // final file = File('${(await getTemporaryDirectory()).path}/img.png');
                // await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
                Uint8List? bytes = await img.pngBytes;

                final file =
                    File('${(await getTemporaryDirectory()).path}/img.png');
                await file.writeAsBytes(bytes!);
                String userId = context.read<AuthProvider>().user!.uid;

                Get.snackbar(
                  'Uploading',
                  '',
                  margin: EdgeInsets.all(10),
                  borderRadius: 10,
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                  shouldIconPulse: true,
                  showProgressIndicator: false,
                  isDismissible: false,
                  messageText: null,
                  titleText: StreamBuilder(
                      stream: context
                          .read<StorageProvider>()
                          .uploadImage(file, userId),
                      builder: (context, snapshot) {
                        List<String> lstWords = List.generate(
                            controllers.length,
                            (index) => controllers[index].text.trim());
                        if (snapshot.hasData) {
                          print(snapshot.data!.bytesTransferred);
                          double progress = (snapshot.data!.bytesTransferred /
                                  snapshot.data!.totalBytes) *
                              100;

                          if (snapshot.data!.state == TaskState.success) {
                            // get url and save to firestore

                            print(snapshot.data!.ref.name);
                            snapshot.data!.ref.getDownloadURL().then((value) {
                              print(value);
                              context.read<StorageProvider>().addImageUrl(
                                    value,
                                    context.read<AuthProvider>().user!.uid,
                                    snapshot.data!.ref.name,
                                    lstWords,
                                  );
                            });

                            Get.back();
                          }

                          print('progress');
                          print(progress);
                          if (progress == 100) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '100%',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${progress.toInt()}%',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(width: 10),
                                CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                  value: progress / 100,
                                  color: Colors.red,
                                ),
                              ],
                            );
                          }
                        } else {
                          return Row(
                            children: [
                              Text(
                                '0%',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              CircularProgressIndicator(
                                value: 0,
                                color: Colors.white,
                              ),
                            ],
                          );
                        }
                      }),
                );
                controller.clearDrawables();

                print(file.path);

                print(file.length());
              },
              child: Text('Upload'),
            ),
          ],
        ),
        barrierDismissible: false);
  }
}

class Line extends StatefulWidget {
  int y;
  int x;
  bool isSideBarOpen;

  Line({
    required this.y,
    required this.x,
    required this.isSideBarOpen,
  });

  @override
  State<StatefulWidget> createState() => _LineState();
}

class _LineState extends State<Line> with TickerProviderStateMixin {
  double _progress = 0.0;
  late Animation<double> animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      double widthScreen = MediaQuery.of(context).size.width.toDouble() - 100;
      double halfWidth = widthScreen / 2;
      print('half width: $halfWidth');
      print(
          'resolution : ${MediaQuery.of(context).size.width} x ${MediaQuery.of(context).size.height}');

      animation = Tween(begin: 0.0, end: halfWidth).animate(_controller)
        ..addListener(() {
          print(animation.value);
          setState(() {
            _progress = animation.value;
          });
        });

      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: LinePainter(
            _progress,
            widget.y,
            widget.isSideBarOpen
                ? (((MediaQuery.of(context).size.width - 100) / 2) * -1).toInt()
                : (((MediaQuery.of(context).size.width - 100) / 2) * -1)
                    .toInt(),
            widget.isSideBarOpen));
  }
}

class LinePainter extends CustomPainter {
  late Paint _paint;
  double _progress;
  int y;
  int x;
  bool isSideBarOpen;

  LinePainter(this._progress, this.y, this.x, this.isSideBarOpen) {
    _paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    print('y: $y');
    print('x: $x');
    print('size: ${size.width}');
    canvas.drawLine(
        Offset(x.toDouble(), y.toDouble()),
        Offset(isSideBarOpen ? _progress : _progress + 60, y.toDouble()),
        _paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate._progress != _progress;
  }
}
