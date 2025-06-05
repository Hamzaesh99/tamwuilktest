import 'package:flutter/material.dart';

/// ãßæä ÞÇÈá ááÓÍÈ íãßä ÇÓÊÎÏÇãå Ýí Ãí ãßÇä Ýí ÇáÊØÈíÞ
class DraggableItemWidget<T extends Object> extends StatelessWidget {
  final T data;
  final Widget child;
  final Widget? feedback;
  final Widget? childWhenDragging;
  final DragAnchorStrategy? dragAnchorStrategy;
  final Axis? axis;
  final Function(DraggableDetails)? onDragEnd;
  final Function()? onDragStarted;
  final DraggableCanceledCallback? onDraggableCanceled;
  final Function(DragUpdateDetails)? onDragUpdate;

  const DraggableItemWidget({
    super.key,
    required this.data,
    required this.child,
    this.feedback,
    this.childWhenDragging,
    this.dragAnchorStrategy,
    this.axis,
    this.onDragEnd,
    this.onDragStarted,
    this.onDraggableCanceled,
    this.onDragUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<T>(
      data: data,
      feedback:
          feedback ??
          Material(
            elevation: 4.0,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).primaryColor.withAlpha(204), // 0.8 opacity = 204 alpha
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: child,
            ),
          ),
      childWhenDragging:
          childWhenDragging ?? Opacity(opacity: 0.5, child: child),
      // Fix: Use correct DragAnchorStrategy class
      dragAnchorStrategy: dragAnchorStrategy ?? childDragAnchorStrategy,
      axis: axis,
      onDragEnd: onDragEnd,
      onDragStarted: onDragStarted,
      // Fix: Add null check before calling the callback
      onDraggableCanceled:
          onDraggableCanceled != null
              ? (velocity, offset) => onDraggableCanceled!(velocity, offset)
              : null,
      onDragUpdate: onDragUpdate,
      child: child,
    );
  }
}

/// ãäØÞÉ ÅÝáÇÊ ÊÞÈá äæÚÇð ãÍÏÏÇð ãä ÇáÈíÇäÇÊ
class DropTargetWidget<T extends Object> extends StatefulWidget {
  final Widget child;
  final List<T>? acceptedDataTypes;
  final Function(T)? onAccept;
  final bool Function(T)? onWillAccept;
  final Function(DragTargetDetails<T>)? onAcceptWithDetails;
  final Function(T?)? onLeave;
  final DragTargetMove<T>? onMove;
  final bool Function(DragTargetDetails<T>)? onWillAcceptWithDetails;
  final Color? highlightColor;

  const DropTargetWidget({
    super.key,
    required this.child,
    this.acceptedDataTypes,
    this.onAccept,
    this.onWillAccept,
    this.onAcceptWithDetails,
    this.onLeave,
    this.onMove,
    this.onWillAcceptWithDetails,
    this.highlightColor,
  });

  @override
  State<DropTargetWidget<T>> createState() => _DropTargetWidgetState<T>();
}

class _DropTargetWidgetState<T extends Object>
    extends State<DropTargetWidget<T>> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<T>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            border:
                _isHovering
                    ? Border.all(
                      color:
                          widget.highlightColor ??
                          Theme.of(context).primaryColor,
                      width: 2.0,
                    )
                    : null,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: widget.child,
        );
      },
      // Fix: Replace deprecated onWillAccept with onWillAcceptWithDetails
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        // Remove unnecessary null check since data can't be null here

        bool willAccept = true;

        if (widget.acceptedDataTypes != null) {
          willAccept = widget.acceptedDataTypes!.contains(data);
        }

        if (widget.onWillAccept != null) {
          willAccept = widget.onWillAccept!(data) && willAccept;
        }

        if (widget.onWillAcceptWithDetails != null) {
          willAccept = widget.onWillAcceptWithDetails!(details) && willAccept;
        }

        setState(() {
          _isHovering = willAccept;
        });

        return willAccept;
      },
      // Fix: Replace deprecated onAccept with onAcceptWithDetails
      onAcceptWithDetails: (details) {
        setState(() {
          _isHovering = false;
        });

        if (widget.onAccept != null) {
          widget.onAccept!(details.data);
        }

        if (widget.onAcceptWithDetails != null) {
          widget.onAcceptWithDetails!(details);
        }
      },
      onLeave: (data) {
        setState(() {
          _isHovering = false;
        });

        if (widget.onLeave != null) {
          widget.onLeave!(data);
        }
      },
      onMove: widget.onMove,
    );
  }
}

/// ãßæä ãÊßÇãá ááÓÍÈ æÇáÅÝáÇÊ ãÚ ÅãßÇäíÉ ÅÚÇÏÉ ÇáÊÑÊíÈ
class ReorderableListWidget<T extends Object> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item, int index) itemBuilder;
  final Function(List<T> newItems)? onReorder;
  final Axis direction;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ReorderableListWidget({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onReorder,
    this.direction = Axis.vertical,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<ReorderableListWidget<T>> createState() =>
      _ReorderableListWidgetState<T>();
}

class _ReorderableListWidgetState<T extends Object>
    extends State<ReorderableListWidget<T>> {
  late List<T> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  void didUpdateWidget(ReorderableListWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _items = List.from(widget.items);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: true,
      scrollDirection: widget.direction,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return KeyedSubtree(
          key: ValueKey(_items[index]),
          child: widget.itemBuilder(_items[index], index),
        );
      },
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final T item = _items.removeAt(oldIndex);
          _items.insert(newIndex, item);
        });

        if (widget.onReorder != null) {
          widget.onReorder!(_items);
        }
      },
    );
  }
}

/// ãßæä áæÍÉ ÇáÓÍÈ æÇáÅÝáÇÊ ÇáãÊÞÏãÉ
class DragDropBoard<T extends Object> extends StatefulWidget {
  final List<List<T>> boardData;
  final Widget Function(T item, int columnIndex, int itemIndex) itemBuilder;
  final Widget Function(int columnIndex, List<T> columnItems) columnBuilder;
  final Function(
    T item,
    int oldColumnIndex,
    int oldItemIndex,
    int newColumnIndex,
    int newItemIndex,
  )?
  onItemMoved;
  final double? width;
  final double? height;

  const DragDropBoard({
    super.key,
    required this.boardData,
    required this.itemBuilder,
    required this.columnBuilder,
    this.onItemMoved,
    this.width,
    this.height,
  });

  @override
  State<DragDropBoard<T>> createState() => _DragDropBoardState<T>();
}

class _DragDropBoardState<T extends Object> extends State<DragDropBoard<T>> {
  late List<List<T>> _boardData;

  @override
  void initState() {
    super.initState();
    _boardData = List.from(
      widget.boardData.map((column) => List<T>.from(column)),
    );
  }

  @override
  void didUpdateWidget(DragDropBoard<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.boardData != widget.boardData) {
      _boardData = List.from(
        widget.boardData.map((column) => List<T>.from(column)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fix: Replace Container with SizedBox for whitespace
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(_boardData.length, (columnIndex) {
            return _buildColumn(columnIndex);
          }),
        ),
      ),
    );
  }

  Widget _buildColumn(int columnIndex) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropTargetWidget<Map<String, dynamic>>(
        onAccept: (data) {
          if (data['type'] == 'item' &&
              data['columnIndex'] != null &&
              data['itemIndex'] != null) {
            final int oldColumnIndex = data['columnIndex'];
            final int oldItemIndex = data['itemIndex'];

            if (oldColumnIndex != columnIndex) {
              setState(() {
                final T item = _boardData[oldColumnIndex].removeAt(
                  oldItemIndex,
                );
                _boardData[columnIndex].add(item);
              });

              if (widget.onItemMoved != null) {
                widget.onItemMoved!(
                  _boardData[columnIndex].last,
                  oldColumnIndex,
                  oldItemIndex,
                  columnIndex,
                  _boardData[columnIndex].length - 1,
                );
              }
            }
          }
        },
        child: widget.columnBuilder(columnIndex, _boardData[columnIndex]),
      ),
    );
  }
}