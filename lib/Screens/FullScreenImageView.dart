import 'package:flutter/material.dart';
import 'package:incognito/widgets/ReusableWidgets.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImageView extends StatelessWidget {
  final String url;

  const FullScreenImageView({Key key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PhotoView(
            loadingChild: reusableWidget().indicator(context),
            initialScale: PhotoViewComputedScale.contained,
            imageProvider: NetworkImage(url),
            gaplessPlayback: false,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered,
            heroAttributes: PhotoViewHeroAttributes(
              tag: url,
              transitionOnUserGestures: false,
            ),
          ),
          Positioned(
            child: IconButton(
              tooltip: "Back",
              splashColor: Theme.of(context).splashColor,
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            left: MediaQuery.of(context).size.width * 0.01,
            top: MediaQuery.of(context).size.height * 0.039,
          ),
        ],
      ),
    );
  }
}
