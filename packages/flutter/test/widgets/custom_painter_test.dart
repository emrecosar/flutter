// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'semantics_tester.dart';

void main() {
  group(CustomPainter, () {
    setUp(() {
      debugResetSemanticsIdCounter();
      _PainterWithSemantics.shouldRebuildSemanticsCallCount = 0;
      _PainterWithSemantics.buildSemanticsCallCount = 0;
      _PainterWithSemantics.semanticsBuilderCallCount = 0;
    });

    _defineTests();
  });
}

void _defineTests() {
  testWidgets('builds no semantics by default', (WidgetTester tester) async {
    final SemanticsTester semanticsTester = new SemanticsTester(tester);

    await tester.pumpWidget(new CustomPaint(
      painter: new _PainterWithoutSemantics(),
    ));

    expect(semanticsTester, hasSemantics(
      new TestSemantics.root(
        children: const <TestSemantics>[],
      ),
    ));

    semanticsTester.dispose();
  });

  testWidgets('provides foreground semantics', (WidgetTester tester) async {
    final SemanticsTester semanticsTester = new SemanticsTester(tester);

    await tester.pumpWidget(new CustomPaint(
      foregroundPainter: new _PainterWithSemantics(
        semantics: new CustomPainterSemantics(
          rect: new Rect.fromLTRB(1.0, 1.0, 2.0, 2.0),
          properties: const SemanticsProperties(
            label: 'foreground',
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    ));

    expect(semanticsTester, hasSemantics(
      new TestSemantics.root(
        children: <TestSemantics>[
          new TestSemantics.rootChild(
            id: 1,
            rect: TestSemantics.fullScreen,
            children: <TestSemantics>[
              new TestSemantics(
                id: 2,
                label: 'foreground',
                rect: new Rect.fromLTRB(1.0, 1.0, 2.0, 2.0),
              ),
            ],
          ),
        ],
      ),
    ));

    semanticsTester.dispose();
  });

  testWidgets('provides background semantics', (WidgetTester tester) async {
    final SemanticsTester semanticsTester = new SemanticsTester(tester);

    await tester.pumpWidget(new CustomPaint(
      painter: new _PainterWithSemantics(
        semantics: new CustomPainterSemantics(
          rect: new Rect.fromLTRB(1.0, 1.0, 2.0, 2.0),
          properties: const SemanticsProperties(
            label: 'background',
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    ));

    expect(semanticsTester, hasSemantics(
      new TestSemantics.root(
        children: <TestSemantics>[
          new TestSemantics.rootChild(
            id: 1,
            rect: TestSemantics.fullScreen,
            children: <TestSemantics>[
              new TestSemantics(
                id: 2,
                label: 'background',
                rect: new Rect.fromLTRB(1.0, 1.0, 2.0, 2.0),
              ),
            ],
          ),
        ],
      ),
    ));

    semanticsTester.dispose();
  });

  testWidgets('combines background, child and foreground semantics', (WidgetTester tester) async {
    final SemanticsTester semanticsTester = new SemanticsTester(tester);

    await tester.pumpWidget(new CustomPaint(
      painter: new _PainterWithSemantics(
        semantics: new CustomPainterSemantics(
          rect: new Rect.fromLTRB(1.0, 1.0, 2.0, 2.0),
          properties: const SemanticsProperties(
            label: 'background',
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
      child: new Semantics(
        container: true,
        child: const Text('Hello', textDirection: TextDirection.ltr),
      ),
      foregroundPainter: new _PainterWithSemantics(
        semantics: new CustomPainterSemantics(
          rect: new Rect.fromLTRB(1.0, 1.0, 2.0, 2.0),
          properties: const SemanticsProperties(
            label: 'foreground',
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    ));

    expect(semanticsTester, hasSemantics(
      new TestSemantics.root(
        children: <TestSemantics>[
          new TestSemantics.rootChild(
            id: 1,
            rect: TestSemantics.fullScreen,
            children: <TestSemantics>[
              new TestSemantics(
                id: 3,
                label: 'background',
                rect: new Rect.fromLTRB(1.0, 1.0, 2.0, 2.0),
              ),
              new TestSemantics(
                id: 2,
                label: 'Hello',
                rect: new Rect.fromLTRB(0.0, 0.0, 800.0, 600.0),
              ),
              new TestSemantics(
                id: 4,
                label: 'foreground',
                rect: new Rect.fromLTRB(1.0, 1.0, 2.0, 2.0),
              ),
            ],
          ),
        ],
      ),
    ));

    semanticsTester.dispose();
  });

  testWidgets('applies $SemanticsProperties', (WidgetTester tester) async {
    final SemanticsTester semanticsTester = new SemanticsTester(tester);

    await tester.pumpWidget(new CustomPaint(
      painter: new _PainterWithSemantics(
        semantics: new CustomPainterSemantics(
          key: const ValueKey<int>(1),
          rect: new Rect.fromLTRB(1.0, 2.0, 3.0, 4.0),
          properties: const SemanticsProperties(
            checked: false,
            selected: false,
            button: false,
            label: 'label-before',
            value: 'value-before',
            increasedValue: 'increase-before',
            decreasedValue: 'decrease-before',
            hint: 'hint-before',
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    ));

    expect(semanticsTester, hasSemantics(
      new TestSemantics.root(
        children: <TestSemantics>[
          new TestSemantics.rootChild(
            id: 1,
            rect: TestSemantics.fullScreen,
            children: <TestSemantics>[
              new TestSemantics(
                rect: new Rect.fromLTRB(1.0, 2.0, 3.0, 4.0),
                id: 2,
                flags: 1,
                label: 'label-before',
                value: 'value-before',
                increasedValue: 'increase-before',
                decreasedValue: 'decrease-before',
                hint: 'hint-before',
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
    ));

    await tester.pumpWidget(new CustomPaint(
      painter: new _PainterWithSemantics(
        semantics: new CustomPainterSemantics(
          key: const ValueKey<int>(1),
          rect: new Rect.fromLTRB(5.0, 6.0, 7.0, 8.0),
          properties: new SemanticsProperties(
            checked: true,
            selected: true,
            button: true,
            label: 'label-after',
            value: 'value-after',
            increasedValue: 'increase-after',
            decreasedValue: 'decrease-after',
            hint: 'hint-after',
            textDirection: TextDirection.ltr,
            onScrollDown: () {},
            onLongPress: () {},
            onDecrease: () {},
            onIncrease: () {},
            onScrollLeft: () {},
            onScrollRight: () {},
            onScrollUp: () {},
            onTap: () {},
          ),
        ),
      ),
    ));

    expect(semanticsTester, hasSemantics(
      new TestSemantics.root(
        children: <TestSemantics>[
          new TestSemantics.rootChild(
            id: 1,
            rect: TestSemantics.fullScreen,
            children: <TestSemantics>[
              new TestSemantics(
                rect: new Rect.fromLTRB(5.0, 6.0, 7.0, 8.0),
                actions: 255,
                id: 2,
                flags: 15,
                label: 'label-after',
                value: 'value-after',
                increasedValue: 'increase-after',
                decreasedValue: 'decrease-after',
                hint: 'hint-after',
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ],
      ),
    ));

    semanticsTester.dispose();
  });

  testWidgets('Can toggle semantics on, off, on without crash', (WidgetTester tester) async {
    await tester.pumpWidget(new CustomPaint(
      painter: new _PainterWithSemantics(
        semantics: new CustomPainterSemantics(
          key: const ValueKey<int>(1),
          rect: new Rect.fromLTRB(1.0, 2.0, 3.0, 4.0),
          properties: const SemanticsProperties(
            checked: false,
            selected: false,
            button: false,
            label: 'label-before',
            value: 'value-before',
            increasedValue: 'increase-before',
            decreasedValue: 'decrease-before',
            hint: 'hint-before',
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    ));

    // Start with semantics off.
    expect(tester.binding.pipelineOwner.semanticsOwner, isNull);

    // Semantics on
    SemanticsTester semantics = new SemanticsTester(tester);
    await tester.pumpAndSettle();
    expect(tester.binding.pipelineOwner.semanticsOwner, isNotNull);

    // Semantics off
    semantics.dispose();
    await tester.pumpAndSettle();
    expect(tester.binding.pipelineOwner.semanticsOwner, isNull);

    // Semantics on
    semantics = new SemanticsTester(tester);
    await tester.pumpAndSettle();
    expect(tester.binding.pipelineOwner.semanticsOwner, isNotNull);

    semantics.dispose();
  });

  testWidgets('Supports all actions', (WidgetTester tester) async {
    final SemanticsTester semantics = new SemanticsTester(tester);
    final List<SemanticsAction> performedActions = <SemanticsAction>[];

    await tester.pumpWidget(new CustomPaint(
      painter: new _PainterWithSemantics(
        semantics: new CustomPainterSemantics(
          key: const ValueKey<int>(1),
          rect: new Rect.fromLTRB(1.0, 2.0, 3.0, 4.0),
          properties: new SemanticsProperties(
            onTap: () => performedActions.add(SemanticsAction.tap),
            onLongPress: () => performedActions.add(SemanticsAction.longPress),
            onScrollLeft: () => performedActions.add(SemanticsAction.scrollLeft),
            onScrollRight: () => performedActions.add(SemanticsAction.scrollRight),
            onScrollUp: () => performedActions.add(SemanticsAction.scrollUp),
            onScrollDown: () => performedActions.add(SemanticsAction.scrollDown),
            onIncrease: () => performedActions.add(SemanticsAction.increase),
            onDecrease: () => performedActions.add(SemanticsAction.decrease),
            onCopy: () => performedActions.add(SemanticsAction.copy),
            onCut: () => performedActions.add(SemanticsAction.cut),
            onPaste: () => performedActions.add(SemanticsAction.paste),
            onMoveCursorForwardByCharacter: (bool _) => performedActions.add(SemanticsAction.moveCursorForwardByCharacter),
            onMoveCursorBackwardByCharacter: (bool _) => performedActions.add(SemanticsAction.moveCursorBackwardByCharacter),
            onSetSelection: (TextSelection _) => performedActions.add(SemanticsAction.setSelection),
            onDidGainAccessibilityFocus: () => performedActions.add(SemanticsAction.didGainAccessibilityFocus),
            onDidLoseAccessibilityFocus: () => performedActions.add(SemanticsAction.didLoseAccessibilityFocus),
          ),
        ),
      ),
    ));

    final Set<SemanticsAction> allActions = SemanticsAction.values.values.toSet()
      ..remove(SemanticsAction.showOnScreen); // showOnScreen is non user-exposed.

    const int expectedId = 2;
    final TestSemantics expectedSemantics = new TestSemantics.root(
      children: <TestSemantics>[
        new TestSemantics.rootChild(
          id: 1,
          previousNodeId: -1,
          nextNodeId: expectedId,
          children: <TestSemantics>[
            new TestSemantics.rootChild(
              id: expectedId,
              rect: TestSemantics.fullScreen,
              actions: allActions.fold(0, (int previous, SemanticsAction action) => previous | action.index),
              previousNodeId: 1,
              nextNodeId: -1,
            ),
          ]
        ),
      ],
    );
    expect(semantics, hasSemantics(expectedSemantics, ignoreRect: true, ignoreTransform: true));

    // Do the actions work?
    final SemanticsOwner semanticsOwner = tester.binding.pipelineOwner.semanticsOwner;
    int expectedLength = 1;
    for (SemanticsAction action in allActions) {
      switch (action) {
        case SemanticsAction.moveCursorBackwardByCharacter:
        case SemanticsAction.moveCursorForwardByCharacter:
          semanticsOwner.performAction(expectedId, action, true);
          break;
        case SemanticsAction.setSelection:
          semanticsOwner.performAction(expectedId, action, <String, int>{
            'base': 4,
            'extent': 5,
          });
          break;
        default:
          semanticsOwner.performAction(expectedId, action);
      }
      expect(performedActions.length, expectedLength);
      expect(performedActions.last, action);
      expectedLength += 1;
    }

    semantics.dispose();
  });

  group('diffing', () {
    testWidgets('complains about duplicate keys', (WidgetTester tester) async {
      final SemanticsTester semanticsTester = new SemanticsTester(tester);
      await tester.pumpWidget(new CustomPaint(
        painter: new _SemanticsDiffTest(<String>[
          'a-k',
          'a-k',
        ]),
      ));
      expect(tester.takeException(), isFlutterError);
      semanticsTester.dispose();
    });

    testDiff('adds one item to an empty list', (_DiffTester tester) async {
      await tester.diff(
        from: <String>[],
        to: <String>['a'],
      );
    });

    testDiff('removes the last item from the list', (_DiffTester tester) async {
      await tester.diff(
        from: <String>['a'],
        to: <String>[],
      );
    });

    testDiff('appends one item at the end of a non-empty list', (_DiffTester tester) async {
      await tester.diff(
        from: <String>['a'],
        to: <String>['a', 'b'],
      );
    });

    testDiff('prepends one item at the beginning of a non-empty list', (_DiffTester tester) async {
      await tester.diff(
        from: <String>['b'],
        to: <String>['a', 'b'],
      );
    });

    testDiff('inserts one item in the middle of a list', (_DiffTester tester) async {
      await tester.diff(
        from: <String>[
          'a-k',
          'c-k',
        ],
        to: <String>[
          'a-k',
          'b-k',
          'c-k',
        ],
      );
    });

    testDiff('removes one item from the middle of a list', (_DiffTester tester) async {
      await tester.diff(
        from: <String>[
          'a-k',
          'b-k',
          'c-k',
        ],
        to: <String>[
          'a-k',
          'c-k',
        ],
      );
    });

    testDiff('swaps two items', (_DiffTester tester) async {
      await tester.diff(
        from: <String>[
          'a-k',
          'b-k',
        ],
        to: <String>[
          'b-k',
          'a-k',
        ],
      );
    });

    testDiff('finds and moved one keyed item', (_DiffTester tester) async {
      await tester.diff(
        from: <String>[
          'a-k',
          'b',
          'c',
        ],
        to: <String>[
          'b',
          'c',
          'a-k',
        ],
      );
    });
  });

  testWidgets('rebuilds semantics upon resize', (WidgetTester tester) async {
    final SemanticsTester semanticsTester = new SemanticsTester(tester);

    final _PainterWithSemantics painter = new _PainterWithSemantics(
      semantics: new CustomPainterSemantics(
        rect: new Rect.fromLTRB(1.0, 1.0, 2.0, 2.0),
        properties: const SemanticsProperties(
          label: 'background',
          textDirection: TextDirection.rtl,
        ),
      ),
    );

    final CustomPaint paint = new CustomPaint(painter: painter);

    await tester.pumpWidget(new SizedBox(
      height: 20.0,
      width: 20.0,
      child: paint,
    ));
    expect(_PainterWithSemantics.shouldRebuildSemanticsCallCount, 0);
    expect(_PainterWithSemantics.buildSemanticsCallCount, 1);
    expect(_PainterWithSemantics.semanticsBuilderCallCount, 4);

    await tester.pumpWidget(new SizedBox(
      height: 20.0,
      width: 20.0,
      child: paint,
    ));
    expect(_PainterWithSemantics.shouldRebuildSemanticsCallCount, 0);
    expect(_PainterWithSemantics.buildSemanticsCallCount, 1);
    expect(_PainterWithSemantics.semanticsBuilderCallCount, 4);

    await tester.pumpWidget(new SizedBox(
      height: 40.0,
      width: 40.0,
      child: paint,
    ));
    expect(_PainterWithSemantics.shouldRebuildSemanticsCallCount, 0);
    expect(_PainterWithSemantics.buildSemanticsCallCount, 2);
    expect(_PainterWithSemantics.semanticsBuilderCallCount, 4);

    semanticsTester.dispose();
  });

  testWidgets('does not rebuild when shouldRebuildSemantics is false', (WidgetTester tester) async {
    final SemanticsTester semanticsTester = new SemanticsTester(tester);

    final CustomPainterSemantics testSemantics = new CustomPainterSemantics(
      rect: new Rect.fromLTRB(1.0, 1.0, 2.0, 2.0),
      properties: const SemanticsProperties(
        label: 'background',
        textDirection: TextDirection.rtl,
      ),
    );

    await tester.pumpWidget(new CustomPaint(painter: new _PainterWithSemantics(
      semantics: testSemantics,
    )));
    expect(_PainterWithSemantics.shouldRebuildSemanticsCallCount, 0);
    expect(_PainterWithSemantics.buildSemanticsCallCount, 1);
    expect(_PainterWithSemantics.semanticsBuilderCallCount, 4);

    await tester.pumpWidget(new CustomPaint(painter: new _PainterWithSemantics(
      semantics: testSemantics,
    )));
    expect(_PainterWithSemantics.shouldRebuildSemanticsCallCount, 1);
    expect(_PainterWithSemantics.buildSemanticsCallCount, 1);
    expect(_PainterWithSemantics.semanticsBuilderCallCount, 4);

    final CustomPainterSemantics testSemantics2 = new CustomPainterSemantics(
      rect: new Rect.fromLTRB(1.0, 1.0, 2.0, 2.0),
      properties: const SemanticsProperties(
        label: 'background',
        textDirection: TextDirection.rtl,
      ),
    );

    await tester.pumpWidget(new CustomPaint(painter: new _PainterWithSemantics(
      semantics: testSemantics2,
    )));
    expect(_PainterWithSemantics.shouldRebuildSemanticsCallCount, 2);
    expect(_PainterWithSemantics.buildSemanticsCallCount, 2);
    expect(_PainterWithSemantics.semanticsBuilderCallCount, 5);

    semanticsTester.dispose();
  });
}

void testDiff(String description, Future<Null> Function(_DiffTester tester) testFunction) {
  testWidgets(description, (WidgetTester tester) async {
    await testFunction(new _DiffTester(tester));
  });
}

class _DiffTester {
  _DiffTester(this.tester);

  final WidgetTester tester;

  /// Creates an initial semantics list using the `from` list, then updates the
  /// list to the `to` list. This causes [RenderCustomPaint] to diff the two
  /// lists and apply the changes. This method asserts the the changes were
  /// applied correctly, specifically:
  ///
  /// - checks that initial and final configurations are in the desired states.
  /// - checks that keyed nodes have stable IDs.
  Future<Null> diff({List<String> from, List<String> to}) async {
    final SemanticsTester semanticsTester = new SemanticsTester(tester);

    TestSemantics createExpectations(List<String> labels) {
      final List<TestSemantics> children = <TestSemantics>[];
      for (String label in labels) {
        children.add(
          new TestSemantics(
            rect: new Rect.fromLTRB(1.0, 1.0, 2.0, 2.0),
            label: label,
          ),
        );
      }

      return new TestSemantics.root(
        children: <TestSemantics>[
          new TestSemantics.rootChild(
            rect: TestSemantics.fullScreen,
            children: children,
          ),
        ],
      );
    }

    await tester.pumpWidget(new CustomPaint(
      painter: new _SemanticsDiffTest(from),
    ));
    expect(semanticsTester, hasSemantics(createExpectations(from), ignoreId: true));

    SemanticsNode root = RendererBinding.instance?.renderView?.debugSemantics;
    final Map<Key, int> idAssignments = <Key, int>{};
    root.visitChildren((SemanticsNode firstChild) {
      firstChild.visitChildren((SemanticsNode node) {
        if (node.key != null) {
          idAssignments[node.key] = node.id;
        }
        return true;
      });
      return true;
    });

    await tester.pumpWidget(new CustomPaint(
      painter: new _SemanticsDiffTest(to),
    ));
    await tester.pumpAndSettle();
    expect(semanticsTester, hasSemantics(createExpectations(to), ignoreId: true));

    root = RendererBinding.instance?.renderView?.debugSemantics;
    root.visitChildren((SemanticsNode firstChild) {
      firstChild.visitChildren((SemanticsNode node) {
        if (node.key != null && idAssignments[node.key] != null) {
          expect(idAssignments[node.key], node.id, reason:
            'Node with key ${node.key} was previously assigned ID ${idAssignments[node.key]}. '
            'After diffing the child list, its ID changed to ${node.id}. IDs must be stable.'
          );
        }
        return true;
      });
      return true;
    });

    semanticsTester.dispose();
  }
}

class _SemanticsDiffTest extends CustomPainter {
  _SemanticsDiffTest(this.data);

  final List<String> data;

  @override
  void paint(Canvas canvas, Size size) {
    // We don't test painting.
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder => buildSemantics;

  List<CustomPainterSemantics> buildSemantics(Size size) {
    final List<CustomPainterSemantics> semantics = <CustomPainterSemantics>[];
    for (String label in data) {
      Key key;
      if (label.endsWith('-k')) {
        key = new ValueKey<String>(label);
      }
      semantics.add(
        new CustomPainterSemantics(
          rect: new Rect.fromLTRB(1.0, 1.0, 2.0, 2.0),
          key: key,
          properties: new SemanticsProperties(
            label: label,
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    }
    return semantics;
  }

  @override
  bool shouldRepaint(_SemanticsDiffTest oldPainter) => true;
}

class _PainterWithSemantics extends CustomPainter {
  _PainterWithSemantics({ this.semantics });

  final CustomPainterSemantics semantics;

  static int semanticsBuilderCallCount = 0;
  static int buildSemanticsCallCount = 0;
  static int shouldRebuildSemanticsCallCount = 0;

  @override
  void paint(Canvas canvas, Size size) {
    // We don't test painting.
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    semanticsBuilderCallCount += 1;
    return buildSemantics;
  }

  List<CustomPainterSemantics> buildSemantics(Size size) {
    buildSemanticsCallCount += 1;
    return <CustomPainterSemantics>[semantics];
  }

  @override
  bool shouldRepaint(_PainterWithSemantics oldPainter) {
    return true;
  }

  @override
  bool shouldRebuildSemantics(_PainterWithSemantics oldPainter) {
    shouldRebuildSemanticsCallCount += 1;
    return !identical(oldPainter.semantics, semantics);
  }
}

class _PainterWithoutSemantics extends CustomPainter {
  _PainterWithoutSemantics();

  @override
  void paint(Canvas canvas, Size size) {
    // We don't test painting.
  }

  @override
  bool shouldRepaint(_PainterWithSemantics oldPainter) => true;
}
