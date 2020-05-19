import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:incognito/Models/SharedPreferenceRepo.dart';
import 'package:incognito/Models/ThemeSwitchRepo.dart';
import 'package:incognito/Screens/Profile.dart';
import 'package:incognito/widgets/ReusableWidgets.dart';
import 'package:incognito/widgets/flip_card.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({Key key}) : super(key: key);

  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      semanticLabel: "Drawer Menu",
      child: SafeArea(
        top: true,
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: FutureBuilder(
                        future: getUserName(),
                        initialData: "User Name",
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> text) {
                          return Text(text.data);
                        }),
                    currentAccountPicture: FutureBuilder(
                        future: getPhotoUrl(),
                        initialData:
                            "https://ualr.edu/studentaffairs/files/2020/01/blank-picture-holder.png",
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> text) {
                          return Offstage(
                            offstage: text.data == null,
                            child: CachedNetworkImage(
                              fit: BoxFit.contain,
                              imageUrl: text.data,
                              fadeInCurve: Curves.bounceIn,
                              fadeOutCurve: Curves.bounceOut,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          );
                        }),
                    accountEmail: FutureBuilder(
                        future: getStatus(),
                        initialData: "Status",
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> text) {
                          return Text(text.data);
                        }),
                  ),
                  // User Profile
                  DrawerListTile(
                    iconData: Icons.person,
                    title: 'My Profile',
                    onTilePressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, FadeRoute(page: Profile()));
                    },
                  ),
//                  DrawerListTile(
//                    iconData: Icons.lock,
//                    title: 'New  Secret  Chat',
//                    onTilePressed: () {},
//                  ),
//                  DrawerListTile(
//                    iconData: Icons.notifications,
//                    title: 'New Channel',
//                    onTilePressed: () {},
//                  ),
//                  DrawerListTile(
//                    iconData: Icons.contacts,
//                    title: 'Contacts',
//                    onTilePressed: () {},
//                  ),
//                  DrawerListTile(
//                    iconData: Icons.phone,
//                    title: 'Calls',
//                    onTilePressed: () {},
//                  ),
//                  DrawerListTile(
//                    iconData: Icons.bookmark_border,
//                    title: 'Saved Messages',
//                    onTilePressed: () {},
//                  ),
//                  DrawerListTile(
//                    iconData: Icons.settings,
//                    title: 'Settings',
//                    onTilePressed: () {},
//                  ),
//                  Divider(),
//                  DrawerListTile(
//                    iconData: Icons.person_add,
//                    title: 'Invite Friends',
//                    onTilePressed: () {},
//                  ),
//                  DrawerListTile(
//                    iconData: Icons.help_outline,
//                    title: 'Incognito FAQ',
//                    onTilePressed: () {},
//                  ),
                  Divider(),
                  DrawerListTile(
                    iconData: Icons.remove_circle,
                    title: 'Sign Out',
                    onTilePressed: () {
                      Navigator.pop(context);
                      reusableWidget().logoutDialog(context);
                      return Future.value(true);
                    },
                  )
                ],
              ),
              // Theme Switch
              Align(
                alignment: Alignment.topRight,
                child: ThemeSwitcher(
                  builder: (context) {
                    return IconButton(
                      iconSize: 20,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onPressed: () => switchThemeDrawerMethod(context),
                      icon: Icon(
                        Icons.brightness_3,
                        size: 25,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
