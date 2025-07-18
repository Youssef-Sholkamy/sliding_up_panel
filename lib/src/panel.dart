/*
Name: Akshath Jain
Date: 3/18/2019 - 4/2/2020
Purpose: Defines the sliding_up_panel widget
Copyright: © 2020, Akshath Jain. All rights reserved.
Licensing: More information can be found here: https://github.com/akshathjain/sliding_up_panel/blob/master/LICENSE
*/

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/physics.dart';

enum SlideDirection {
  UP,
  DOWN,
}

enum PanelState { OPEN, CLOSED, HIDDEN }

class SlidingUpPanel extends StatefulWidget {
  /// The Widget that slides into view. When the
  /// panel is collapsed and if [collapsed] is null,
  /// then top portion of this Widget will be displayed;
  /// otherwise, [collapsed] will be displayed overtop
  /// of this Widget. If [panel] and [panelBuilder] are both non-null,
  /// [panel] will be used.
  final Widget? panel;

  /// WARNING: This feature is still in beta and is subject to change without
  /// notice. Stability is not gauranteed. Provides a [ScrollController] and
  /// [ScrollPhysics] to attach to a scrollable object in the panel that links
  /// the panel position with the scroll position. Useful for implementing an
  /// infinite scroll behavior. If [panel] and [panelBuilder] are both non-null,
  /// [panel] will be used.
  final Widget Function(ScrollController sc)? panelBuilder;

  /// The Widget displayed overtop the [panel] when collapsed.
  /// This fades out as the panel is opened.
  final Widget? collapsed;

  /// The Widget that lies underneath the sliding panel.
  /// This Widget automatically sizes itself
  /// to fill the screen.
  final Widget? body;

  /// Optional persistent widget that floats above the [panel] and attaches
  /// to the top of the [panel]. Content at the top of the panel will be covered
  /// by this widget. Add padding to the bottom of the `panel` to
  /// avoid coverage.
  final Widget? header;

  /// Optional persistent widget that floats above the [panel] and
  /// attaches to the bottom of the [panel]. Content at the bottom of the panel
  /// will be covered by this widget. Add padding to the bottom of the `panel`
  /// to avoid coverage.
  final Widget? footer;

  /// The height of the sliding panel when fully collapsed.
  final double minHeight;

  /// The height of the sliding panel when fully open.
  final double maxHeight;

  /// A point between [minHeight] and [maxHeight] that the panel snaps to
  /// while animating. A fast swipe on the panel will disregard this point
  /// and go directly to the open/close position. This value is represented as a
  /// percentage of the total animation distance ([maxHeight] - [minHeight]),
  /// so it must be between 0.0 and 1.0, exclusive.
  final double? snapPoint;

  /// A border to draw around the sliding panel sheet.
  final Border? border;

  /// If non-null, the corners of the sliding panel sheet are rounded by this [BorderRadiusGeometry].
  final BorderRadiusGeometry? borderRadius;

  /// A list of shadows cast behind the sliding panel sheet.
  final List<BoxShadow>? boxShadow;

  /// The color to fill the background of the sliding panel sheet.
  final Color color;

  /// The amount to inset the children of the sliding panel sheet.
  final EdgeInsetsGeometry? padding;

  /// Empty space surrounding the sliding panel sheet.
  final EdgeInsetsGeometry? margin;

  /// Set to false to not to render the sheet the [panel] sits upon.
  /// This means that only the [body], [collapsed], and the [panel]
  /// Widgets will be rendered.
  /// Set this to false if you want to achieve a floating effect or
  /// want more customization over how the sliding panel
  /// looks like.
  final bool renderPanelSheet;

  /// Set to false to disable the panel from snapping open or closed.
  final bool panelSnapping;

  /// If non-null, this can be used to control the state of the panel.
  final PanelController? controller;

  /// If non-null, shows a darkening shadow over the [body] as the panel slides open.
  final bool backdropEnabled;

  /// Shows a darkening shadow of this [Color] over the [body] as the panel slides open.
  final Color backdropColor;

  /// The opacity of the backdrop when the panel is fully open.
  /// This value can range from 0.0 to 1.0 where 0.0 is completely transparent
  /// and 1.0 is completely opaque.
  final double backdropOpacity;

  /// Flag that indicates whether or not tapping the
  /// backdrop closes the panel. Defaults to true.
  final bool backdropTapClosesPanel;

  /// If non-null, this callback
  /// is called as the panel slides around with the
  /// current position of the panel. The position is a double
  /// between 0.0 and 1.0 where 0.0 is fully collapsed and 1.0 is fully open.
  final void Function(double position)? onPanelSlide;

  /// If non-null, this callback is called when the
  /// panel is fully opened
  final VoidCallback? onPanelOpened;

  /// If non-null, this callback is called when the panel
  /// is fully collapsed.
  final VoidCallback? onPanelClosed;

  /// If non-null and true, the SlidingUpPanel exhibits a
  /// parallax effect as the panel slides up. Essentially,
  /// the body slides up as the panel slides up.
  final bool parallaxEnabled;

  /// Allows for specifying the extent of the parallax effect in terms
  /// of the percentage the panel has slid up/down. Recommended values are
  /// within 0.0 and 1.0 where 0.0 is no parallax and 1.0 mimics a
  /// one-to-one scrolling effect. Defaults to a 10% parallax.
  final double parallaxOffset;

  /// Allows toggling of the draggability of the SlidingUpPanel.
  /// Set this to false to prevent the user from being able to drag
  /// the panel up and down. Defaults to true.
  final bool isDraggable;

  /// Either SlideDirection.UP or SlideDirection.DOWN. Indicates which way
  /// the panel should slide. Defaults to UP. If set to DOWN, the panel attaches
  /// itself to the top of the screen and is fully opened when the user swipes
  /// down on the panel.
  final SlideDirection slideDirection;

  /// The default state of the panel; either PanelState.OPEN or PanelState.CLOSED.
  /// This value defaults to PanelState.CLOSED which indicates that the panel is
  /// in the closed position and must be opened. PanelState.OPEN indicates that
  /// by default the Panel is open and must be swiped closed by the user.
  final PanelState defaultPanelState;

  /// Sliding gestures are enabled if using the default value of true. When set to
  /// false the handlers [_onGestureSlide] and [_onGestureEnd] won't be called and
  /// the panel will not respond to sliding gestures
  final bool gestureSlidingEnabled;

  // CORRECTION 1: Make controller nullable to allow it to be provided externally or not.
  final ScrollController? childScrollController;

  SlidingUpPanel(
      {Key? key,
      this.panel,
      this.panelBuilder,
      this.body,
      this.collapsed,
      this.minHeight = 100.0,
      this.maxHeight = 500.0,
      this.snapPoint,
      this.border,
      this.borderRadius,
      this.boxShadow = const <BoxShadow>[
        BoxShadow(
          blurRadius: 8.0,
          color: Color.fromRGBO(0, 0, 0, 0.25),
        )
      ],
      this.color = Colors.white,
      this.padding,
      this.margin,
      this.renderPanelSheet = true,
      this.panelSnapping = true,
      this.controller,
      this.backdropEnabled = false,
      this.backdropColor = Colors.black,
      this.backdropOpacity = 0.5,
      this.backdropTapClosesPanel = true,
      this.onPanelSlide,
      this.onPanelOpened,
      this.onPanelClosed,
      this.parallaxEnabled = false,
      this.parallaxOffset = 0.1,
      this.isDraggable = true,
      this.childScrollController,
      this.slideDirection = SlideDirection.UP,
      this.defaultPanelState = PanelState.CLOSED,
      this.header,
      this.footer,
      this.gestureSlidingEnabled = true})
      : assert(panel != null || panelBuilder != null),
        assert(0 <= backdropOpacity && backdropOpacity <= 1.0),
        assert(snapPoint == null || 0 < snapPoint && snapPoint < 1.0),
        super(key: key);

  @override
  _SlidingUpPanelState createState() => _SlidingUpPanelState();
}

class _SlidingUpPanelState extends State<SlidingUpPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late ScrollController _childScrollController;

  bool _scrollingEnabled = false;
  bool _onPanelOpenedFired = false;
  final VelocityTracker _vt = VelocityTracker.withKind(PointerDeviceKind.touch);

  late bool _isPanelVisible;

  @override
  void initState() {
    super.initState();

    _isPanelVisible =
        widget.defaultPanelState == PanelState.HIDDEN ? false : true;

    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.defaultPanelState == PanelState.CLOSED ? 0.0 : 1.0,
    )..addListener(() {
        if (widget.onPanelSlide != null) widget.onPanelSlide!(_ac.value);

        // Ensure onPanelOpened is only called once per full open
        if (!_onPanelOpenedFired && _ac.value == 1.0) {
          _onPanelOpenedFired = true;

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await Future.delayed(const Duration(milliseconds: 20));
            if (mounted && widget.onPanelOpened != null) {
              widget.onPanelOpened!();
            }
          });
        }

        // Reset when panel is fully closed
        if (_ac.value == 0.0) {
          _onPanelOpenedFired = false;
          if (widget.onPanelClosed != null && !_ac.isAnimating) {
            widget.onPanelClosed!();
          }
        }
      });

    _childScrollController =
        widget.childScrollController ?? ScrollController();
    _childScrollController.addListener(() {
      if (widget.isDraggable && !_scrollingEnabled) {
        _childScrollController.jumpTo(0);
      }
    });

    widget.controller?._addState(this);
  }

  @override
  void dispose() {
    _ac.dispose();
    if (widget.childScrollController == null) {
      _childScrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: widget.slideDirection == SlideDirection.UP
          ? Alignment.bottomCenter
          : Alignment.topCenter,
      children: <Widget>[
        widget.body != null
            ? AnimatedBuilder(
                animation: _ac,
                builder: (context, child) {
                  return Positioned(
                    top: widget.parallaxEnabled ? _getParallax() : 0.0,
                    child: child ?? const SizedBox(),
                  );
                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: widget.body,
                ),
              )
            : Container(),
        !widget.backdropEnabled
            ? Container()
            : GestureDetector(
                onVerticalDragEnd: widget.backdropTapClosesPanel
                    ? (dets) {
                        if ((widget.slideDirection == SlideDirection.UP
                                ? 1
                                : -1) *
                            dets.velocity.pixelsPerSecond.dy >
                            0) _close();
                      }
                    : null,
                onTap: widget.backdropTapClosesPanel ? () => _close() : null,
                child: AnimatedBuilder(
                    animation: _ac,
                    builder: (context, _) {
                      return Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: _ac.value == 0.0
                            ? null
                            : widget.backdropColor.withOpacity(
                                widget.backdropOpacity * _ac.value),
                      );
                    }),
              ),
        !_isPanelVisible
            ? Container()
            : _gestureHandler(
                child: AnimatedBuilder(
                  animation: _ac,
                  builder: (context, child) {
                    return Container(
                      height:
                          _ac.value * (widget.maxHeight - widget.minHeight) +
                              widget.minHeight,
                      margin: widget.margin,
                      padding: widget.padding,
                      decoration: widget.renderPanelSheet
                          ? BoxDecoration(
                              border: widget.border,
                              borderRadius: widget.borderRadius,
                              boxShadow: widget.boxShadow,
                              color: widget.color,
                            )
                          : null,
                      child: child,
                    );
                  },
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        top: widget.slideDirection == SlideDirection.UP
                            ? 0.0
                            : null,
                        bottom: widget.slideDirection == SlideDirection.DOWN
                            ? 0.0
                            : null,
                        width: MediaQuery.of(context).size.width -
                            (widget.margin?.horizontal ?? 0) -
                            (widget.padding?.horizontal ?? 0),
                        child: SizedBox(
                          height: widget.maxHeight,
                          child: widget.panel != null
                              ? widget.panel
                              : widget.panelBuilder!(_childScrollController),
                        ),
                      ),
                      if (widget.header != null)
                        Positioned(
                          top: widget.slideDirection == SlideDirection.UP
                              ? 0.0
                              : null,
                          bottom: widget.slideDirection == SlideDirection.DOWN
                              ? 0.0
                              : null,
                          child: widget.header!,
                        ),
                      if (widget.footer != null)
                        Positioned(
                          top: widget.slideDirection == SlideDirection.UP
                              ? null
                              : 0.0,
                          bottom: widget.slideDirection == SlideDirection.DOWN
                              ? null
                              : 0.0,
                          child: widget.footer!,
                        ),
                      Positioned(
                        top: widget.slideDirection == SlideDirection.UP
                            ? 0.0
                            : null,
                        bottom: widget.slideDirection == SlideDirection.DOWN
                            ? 0.0
                            : null,
                        width: MediaQuery.of(context).size.width -
                            (widget.margin?.horizontal ?? 0) -
                            (widget.padding?.horizontal ?? 0),
                        child: SizedBox(
                          height: widget.minHeight,
                          child: widget.collapsed == null
                              ? Container()
                              : FadeTransition(
                                  opacity:
                                      Tween(begin: 1.0, end: 0.0).animate(_ac),
                                  child: IgnorePointer(
                                    ignoring: _isPanelOpen,
                                    child: widget.collapsed,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _gestureHandler({required Widget child}) {
    if (!widget.isDraggable) return child;

    if (widget.panel != null) {
      return GestureDetector(
        onVerticalDragUpdate: (dets) {
          if (widget.gestureSlidingEnabled) _onGestureSlide(dets.delta.dy);
        },
        onVerticalDragEnd: (dets) {
          if (widget.gestureSlidingEnabled) _onGestureEnd(dets.velocity);
        },
        child: child,
      );
    }

    return Listener(
      onPointerDown: (PointerDownEvent p) {
        if (widget.gestureSlidingEnabled) {
          _vt.addPosition(p.timeStamp, p.position);
        }
      },
      onPointerMove: (PointerMoveEvent p) {
        if (widget.gestureSlidingEnabled) {
          _vt.addPosition(p.timeStamp, p.position);
          _onGestureSlide(p.delta.dy);
        }
      },
      onPointerUp: (PointerUpEvent p) {
        if (widget.gestureSlidingEnabled) {
          _onGestureEnd(_vt.getVelocity());
        }
      },
      child: child,
    );
  }

  void _onGestureSlide(double dy) {
    if (!_scrollingEnabled) {
      if (widget.slideDirection == SlideDirection.UP)
        _ac.value -= dy / (widget.maxHeight - widget.minHeight);
      else
        _ac.value += dy / (widget.maxHeight - widget.minHeight);
    }

    if (_isPanelOpen &&
        _childScrollController.hasClients &&
        _childScrollController.offset <= 0) {
      setState(() {
        _scrollingEnabled = dy < 0;
      });
    }
  }

  void _onGestureEnd(Velocity v) {
    double minFlingVelocity = 365.0;
    double kSnap = 8;

    if (_ac.isAnimating || (_isPanelOpen && _scrollingEnabled)) return;

    double visualVelocity =
        -v.pixelsPerSecond.dy / (widget.maxHeight - widget.minHeight);

    if (widget.slideDirection == SlideDirection.DOWN)
      visualVelocity = -visualVelocity;

    double d2Close = _ac.value;
    double d2Open = 1 - _ac.value;
    double d2Snap = ((widget.snapPoint ?? 3) - _ac.value).abs();
    double minDistance = min(d2Close, min(d2Snap, d2Open));

    if (v.pixelsPerSecond.dy.abs() >= minFlingVelocity) {
      if (widget.panelSnapping && widget.snapPoint != null) {
        if (v.pixelsPerSecond.dy.abs() >= kSnap * minFlingVelocity ||
            minDistance == d2Snap) {
          _ac.fling(velocity: visualVelocity);
        } else {
          if (visualVelocity < 0 && minDistance == d2Close) {
            _close();
          } else {
            _flingPanelToPosition(widget.snapPoint!, visualVelocity);
          }
        }
      } else if (widget.panelSnapping) {
        _ac.fling(velocity: visualVelocity);
      } else {
        _ac.animateTo(0.0);
      }
    } else {
      if (widget.panelSnapping && widget.snapPoint != null) {
        if (minDistance == d2Snap) {
          _flingPanelToPosition(widget.snapPoint!, visualVelocity);
        } else if (minDistance == d2Close) {
          _close();
        } else {
          _open();
        }
      } else if (widget.panelSnapping) {
        if (_ac.value > 0.5)
          _open();
        else
          _close();
      }
    }
  }

  double _getParallax() {
    if (widget.parallaxOffset < 0.0 || widget.parallaxOffset > 1.0) {
      throw ("parallaxOffset must be between 0.0 and 1.0");
    }

    return -_ac.value *
        (widget.maxHeight - widget.minHeight) *
        widget.parallaxOffset;
  }

  void _flingPanelToPosition(double value, double velocity) {
    _ac.fling(
      velocity: velocity < 0 ? -1.0 : 1.0,
    ).then((_) => _ac.animateTo(value));
  }

  bool get _isPanelOpen => _ac.value >= 1.0;

  void _close() => _ac.fling(velocity: -1.0);
  void _open() => _ac.fling(velocity: 1.0);

  void hide() => setState(() => _isPanelVisible = false);
  void show() => setState(() => _isPanelVisible = true);
}

class PanelController {
  _SlidingUpPanelState? _panelState;

  void _addState(_SlidingUpPanelState panelState) {
    this._panelState = panelState;
  }

  bool get isAttached => _panelState != null;

  Future<void> close() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._close();
  }

  Future<void> open() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._open();
  }

  Future<void> hide() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._hide();
  }

  Future<void> show() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._show();
  }

  Future<void> animatePanelToPosition(double value,
      {Duration? duration, Curve curve = Curves.linear}) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(0.0 <= value && value <= 1.0);
    return _panelState!
        ._animatePanelToPosition(value, duration: duration, curve: curve);
  }

  Future<void> animatePanelToSnapPoint(
      {Duration? duration, Curve curve = Curves.linear}) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(_panelState!.widget.snapPoint != null,
        "SlidingUpPanel snapPoint property must not be null");
    return _panelState!
        ._animatePanelToSnapPoint(duration: duration, curve: curve);
  }

  set panelPosition(double value) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(0.0 <= value && value <= 1.0);
    _panelState!._panelPosition = value;
  }

  double get panelPosition {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._panelPosition;
  }

  bool get isPanelAnimating {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelAnimating;
  }

  bool get isPanelOpen {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelOpen;
  }

  bool get isPanelClosed {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelClosed;
  }

  bool get isPanelShown {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelShown;
  }
}