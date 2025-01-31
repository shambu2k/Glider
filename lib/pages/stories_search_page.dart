import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:glider/models/search_order.dart';
import 'package:glider/models/search_range.dart';
import 'package:glider/utils/animation_util.dart';
import 'package:glider/utils/color_extension.dart';
import 'package:glider/widgets/common/decorated_speed_dial.dart';
import 'package:glider/widgets/common/floating_app_bar_scroll_view.dart';
import 'package:glider/widgets/items/stories_search_body.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final AutoDisposeStateProvider<String> storySearchQueryStateProvider =
    StateProvider.autoDispose<String>(
  (AutoDisposeStateProviderRef<String> ref) => '',
);

final AutoDisposeStateProvider<SearchRange?> storySearchRangeStateProvider =
    StateProvider.autoDispose<SearchRange?>(
  (AutoDisposeStateProviderRef<SearchRange?> ref) => null,
);

final AutoDisposeStateProvider<DateTimeRange?>
    storySearchCustomDateTimeRangeStateProvider =
    StateProvider.autoDispose<DateTimeRange?>(
  (AutoDisposeStateProviderRef<DateTimeRange?> ref) => null,
);

final AutoDisposeStateProvider<SearchOrder> storySearchOrderStateProvider =
    StateProvider.autoDispose<SearchOrder>(
  (AutoDisposeStateProviderRef<SearchOrder> ref) => SearchOrder.byRelevance,
);

class StoriesSearchPage extends HookConsumerWidget {
  const StoriesSearchPage({Key? key})
      : initialSearchRange = SearchRange.pastYear,
        enableSearch = true,
        super(key: key);

  const StoriesSearchPage.catchUp({Key? key})
      : initialSearchRange = SearchRange.pastWeek,
        enableSearch = false,
        super(key: key);

  final SearchRange? initialSearchRange;
  final bool enableSearch;

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
    final StateController<String> storySearchQueryStateController =
        ref.watch(storySearchQueryStateProvider.state);
    final StateController<SearchRange?> storySearchRangeStateController =
        ref.watch(storySearchRangeStateProvider.state);
    final StateController<SearchOrder> searchStoryTypeStateController =
        ref.watch(storySearchOrderStateProvider.state);
    useMemoized(
      () => Future<void>.microtask(
        () => storySearchRangeStateController.update((_) => initialSearchRange),
      ),
    );

    final AnimationController animationController = useAnimationController(
      duration: const Duration(milliseconds: 400),
    );
    final double bottomHeightFactor = useAnimation(
      CurvedAnimation(
        parent: animationController,
        curve: AnimationUtil.defaultCurve,
      ),
    );
    useMemoized(animationController.forward);

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
          title: enableSearch
              ? TextField(
                  controller: queryController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchHint,
                  ),
                  textInputAction: TextInputAction.search,
                  autofocus: true,
                  onChanged: (String value) =>
                      storySearchQueryStateController.update((_) => value),
                )
              : Text(AppLocalizations.of(context)!.catchUp),
          actions: <Widget>[
            if (storySearchQueryStateController.state.isNotEmpty)
              IconButton(
                icon: const Icon(FluentIcons.dismiss_24_regular),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () {
                  queryController.clear();
                  storySearchQueryStateController.update((_) => '');
                },
              ),
          ],
          bottom: _buildAppBarBottom(
            context,
            storySearchRangeStateController,
            heightFactor: bottomHeightFactor,
          ),
          body: const StoriesSearchBody(),
        ),
        floatingActionButton: DecoratedSpeedDial(
          visible: speedDialVisibleState.value,
          icon: searchStoryTypeStateController.state.icon,
          children: <DecoratedSpeedDialChild>[
            for (SearchOrder searchOrder in SearchOrder.values)
              DecoratedSpeedDialChild(
                onTap: () =>
                    searchStoryTypeStateController.update((_) => searchOrder),
                label: searchOrder.title(context),
                child: Icon(searchOrder.icon),
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBarBottom(BuildContext context,
      StateController<SearchRange?> storySearchRangeStateController,
      {required double heightFactor}) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight * heightFactor),
      child: ClipRect(
        child: Align(
          heightFactor: heightFactor,
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: <Widget>[
                  for (SearchRange searchRange in SearchRange.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _SearchRangeChip(searchRange: searchRange),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchRangeChip extends HookConsumerWidget {
  const _SearchRangeChip({Key? key, required this.searchRange})
      : super(key: key);

  final SearchRange searchRange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StateController<SearchRange?> storySearchRangeStateController =
        ref.watch(storySearchRangeStateProvider.state);
    final StateController<DateTimeRange?>
        storySearchCustomDateTimeRangeStateController =
        ref.watch(storySearchCustomDateTimeRangeStateProvider.state);

    return ChoiceChip(
      label: Text(searchRange.title(
          context, storySearchCustomDateTimeRangeStateController.state)),
      selected: storySearchRangeStateController.state == searchRange,
      onSelected: (bool selected) async {
        final StateController<DateTimeRange?>
            customDateTimeRangeStateController = ref
                .read(storySearchCustomDateTimeRangeStateProvider.state)
              ..update((_) => null);

        if (searchRange == SearchRange.custom && selected) {
          final DateTimeRange? dateTimeRange = await showDateRangePicker(
            context: context,
            firstDate: DateTime.fromMillisecondsSinceEpoch(0),
            lastDate: DateTime.now(),
          );
          customDateTimeRangeStateController.update((_) => dateTimeRange);

          if (customDateTimeRangeStateController.state == null) {
            return;
          }
        }

        storySearchRangeStateController
            .update((_) => selected ? searchRange : null);
      },
    );
  }
}
