import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../../controllers/main_controller.dart';
import '../../methods/snackbar.dart';
import '../../models/song_model.dart';
import '../../utils/botttom_sheet_widget.dart';
import '../../utils/loading.dart';

class LikedSongs extends StatelessWidget {
  final MainController con;
  const LikedSongs({
    super.key,
    required this.con,
  });

  @override
  Widget build(BuildContext context) {
    final devicePexelRatio = MediaQuery.of(context).devicePixelRatio;

    List<dynamic> data = [];
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 200,
          backgroundColor: Colors.black,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            collapseMode: CollapseMode.pin,
            background: ClipRRect(
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl:
                        'https://images.unsplash.com/photo-1578070181910-f1e514afdd08?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=933&q=80',
                    height: 200,
                    memCacheHeight:
                        (200 * MediaQuery.of(context).devicePixelRatio).round(),
                    memCacheWidth: (MediaQuery.of(context).size.width *
                            MediaQuery.of(context).devicePixelRatio)
                        .round(),
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                    ),
                  )
                ],
              ),
            ),
            title: Text(
              "Liked Songs",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ValueListenableBuilder<Box>(
              valueListenable: Hive.box('liked').listenable(),
              builder: (context, box, child) {
                if (box.isEmpty) {
                  return const SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        "You don't have any liked songs",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    final info = Hive.box('liked').getAt(i);
                    data.add(info);

                    return Dismissible(
                      key: Key(info['songname'].toString()),
                      onDismissed: (direction) {
                        box.deleteAt(i);
                        context.showSnackBar(
                            message: "Removed from liked songs.");
                      },
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        child: const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Icon(
                            CupertinoIcons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          con.playSong(con.converLocalSongToAudio(data), i);
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: CachedNetworkImage(
                              imageUrl: info['cover'],
                              width: 50,
                              height: 50,
                              memCacheHeight: (70 * devicePexelRatio).round(),
                              memCacheWidth: (70 * devicePexelRatio).round(),
                              maxHeightDiskCache:
                                  (70 * devicePexelRatio).round(),
                              maxWidthDiskCache:
                                  (70 * devicePexelRatio).round(),
                              placeholder: (context, u) => const LoadingImage(),
                              fit: BoxFit.cover),
                        ),
                        title: Text(
                          info['songname'],
                          maxLines: 1,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          info['fullname'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                                useRootNavigator: true,
                                isScrollControlled: true,
                                elevation: 100,
                                backgroundColor: Colors.black38,
                                context: context,
                                builder: (context) {
                                  return BottomSheetWidget(
                                      con: con,
                                      song: SongModel(
                                        songid: info['id'],
                                        songname: info['songname'],
                                        userid: info['username'],
                                        trackid: info['track'],
                                        duration: '',
                                        coverImageUrl: info['cover'],
                                        name: info['fullname'],
                                      ));
                                });
                          },
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: box.length,
                );
              }),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 150),
        )
      ],
    ));
  }
}
