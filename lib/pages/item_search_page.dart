import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:glider/models/search_order.dart';
import 'package:glider/utils/color_extension.dart';
import 'package:glider/widgets/common/decorated_speed_dial.dart';
import 'package:glider/widgets/common/floating_app_bar_scroll_view.dart';
import 'package:glider/widgets/items/item_search_body.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final AutoDisposeStateProvider<String> itemSearchQueryStateProvider =
    StateProvider.autoDispose<String>(
  (AutoDisposeStateProviderRef<String> ref) => '',
);

final AutoDisposeStateProvider<SearchOrder> itemSearchOrderStateProvider =
    StateProvider.autoDispose<SearchOrder>(
  (AutoDisposeStateProviderRef<SearchOrder> ref) => SearchOrder.byRelevance,
);

class ItemSearchPage extends HookConsumerWidget {
  const ItemSearchPage({Key? key, required this.storyId}) : super(key: key);

  final int storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.colorScheme.brightness.isDark;

    final ValueNotifier<bool> speedDialVisibleState = useState(true);
    final ScrollController scrollController = useScrollController();
    useEffect(
      () {
        void onScrollForwardListener() => speedDialVisibleState.value =
            scrollController.position.userScrollDirection ==
                ScrollDirection.forward;
        scrollController.addListener(onScrollForwardListener);
        return () => scrollController.removeListener(onScrollForwardListener);
      },
      <Object>[scrollController],
    );

    final TextEditingController queryController = useTextEditingController();
    final StateController<String> itemSearchQueryStateController =
        ref.watch(itemSearchQueryStateProvider.state);
    final StateController<SearchOrder> itemStoryTypeStateController =
        ref.watch(itemSearchOrderStateProvider.state);

    return Theme(
      data: theme.copyWith(
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: isDark ? null : theme.scaffoldBackgroundColor,
          iconTheme: theme.iconTheme,
          titleTextStyle: theme.textTheme.headline6,
        ),
        inputDecorationTheme:
            theme.inputDecorationTheme.copyWith(border: InputBorder.none),
      ),
      child: Scaffold(
        body: FloatingAppBarScrollView(
          controller: scrollController,
          title: TextField(
            controller: queryController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchHint,
            ),
            textInputAction: TextInputAction.search,
            autofocus: true,
            onChanged: (String value) =>
                itemSearchQueryStateController.update((_) => value),
          ),
          actions: <Widget>[
            if (itemSearchQueryStateController.state.isNotEmpty)
              IconButton(
                icon: const Icon(FluentIcons.dismiss_24_regular),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () {
                  queryController.clear();
                  itemSearchQueryStateController.update((_) => '');
                },
              ),
          ],
          body: ItemSearchBody(storyId: storyId),
        ),
        floatingActionButton: DecoratedSpeedDial(
          visible: speedDialVisibleState.value,
          icon: itemStoryTypeStateController.state.icon,
          children: <DecoratedSpeedDialChild>[
            for (SearchOrder searchOrder in SearchOrder.values)
              DecoratedSpeedDialChild(
                onTap: () =>
                    itemStoryTypeStateController.update((_) => searchOrder),
                label: searchOrder.title(context),
                child: Icon(searchOrder.icon),
              ),
          ],
        ),
      ),
    );
  }
}
