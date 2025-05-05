import 'context.dart';

/// Related gesture events for marking elements
abstract class MarkupEvent {
  MarkupEvent(this.tag, [this.data]);

  /// 发出该事件的标签
  String tag;

  /// 数据
  Object? data;

  /// 转换[data]的类型
  T asData<T>() => data as T;

  @override
  String toString() {
    return '$runtimeType{tag: $tag, data: $data}';
  }
}

/// 点击事件
class MarkupTapEvent extends MarkupEvent {
  MarkupTapEvent(super.tag, super.data);

  MarkupTapEvent.from(MarkupContext context)
    : super(context.tag, context.attrs);
}

/// 长按事件
class MarkupLongPressEvent extends MarkupEvent {
  MarkupLongPressEvent(super.tag, super.data);

  MarkupLongPressEvent.from(MarkupContext context)
    : super(context.tag, context.attrs);
}
