import 'package:flutter/material.dart';
import 'package:glider/models/story_type.dart';
import 'package:glider/pages/item_page.dart';
import 'package:glider/pages/stories_page.dart';
import 'package:glider/providers/item_provider.dart';
import 'package:glider/providers/persistence_provider.dart';
import 'package:glider/widgets/common/refreshable_body.dart';
import 'package:glider/widgets/common/sliver_smooth_animated_list.dart';
import 'package:glider/widgets/common/walkthrough_item.dart';
import 'package:glider/widgets/items/item_tile.dart';
import 'package:glider/widgets/items/story_tile_loading.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StoriesBody extends HookConsumerWidget {
  const StoriesBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StateController<StoryType> storyTypeStateController =
        ref.watch(storyTypeStateProvider.state);
    final bool completedWalkthrough =
        ref.watch(completedWalkthroughProvider).asData?.value ?? true;
    final AutoDisposeStateNotifierProvider<StoryIdsNotifier,
            AsyncValue<Iterable<int>>> provider =
        storyIdsNotifierProvider(storyTypeStateController.state);

    return RefreshableBody<Iterable<int>>(
      provider: provider,
      onRefresh: () => ref.read(provider.notifier).forceLoad(),
      loadingBuilder: () => <Widget>[
        if (!completedWalkthrough)
          const SliverToBoxAdapter(
            child: WalkthoughItem(),
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const StoryTileLoading(),
          ),
        ),
      ],
      dataBuilder: (Iterable<int> ids) => <Widget>[
        if (!completedWalkthrough)
          const SliverToBoxAdapter(
            child: WalkthoughItem(),
          ),
        SliverSmoothAnimatedList<int>(
          items: ids,
          builder: (_, int id, __) => ItemTile(
            id: id,
            onTap: (BuildContext context) => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => ItemPage(id: id)),
            ),
            dense: true,
            fadeable: true,
            loading: () => const StoryTileLoading(),
            refreshProvider: provider,
          ),
        ),
      ],
    );
  }
}
