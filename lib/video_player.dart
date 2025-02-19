import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerPage({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  SharedPreferences? _prefs;
  String? _videoId;
  int _lastPosition = 0;
  bool _isSeeking = false;
  bool _showVideo = false;
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (_videoId == null) {
      print("Invalid YouTube URL");
      return;
    }
    _loadLastPosition();
  }

  Future<void> _loadLastPosition() async {
    _prefs = await SharedPreferences.getInstance();
    _lastPosition = _prefs?.getInt(_videoId!) ?? 0;
  }

  void _initializePlayer() {
    if (_controller != null) return;

    _controller = YoutubePlayerController(
      initialVideoId: _videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    )..addListener(_trackProgress);

    _controller!.addListener(() {
      if (_controller!.value.isReady && !_isSeeking) {
        _isSeeking = true;
        _controller!.seekTo(Duration(seconds: _lastPosition));
      }
    });

    setState(() {});
  }

  void _trackProgress() {
    if (_controller != null && _controller!.value.isPlaying) {
      _lastPosition = _controller!.value.position.inSeconds;
      _prefs?.setInt(_videoId!, _lastPosition);
    }
  }

  void _saveFinalProgress() {
    if (_controller != null) {
      _lastPosition = _controller!.value.position.inSeconds;
      _prefs?.setInt(_videoId!, _lastPosition);
    }
  }

  void _watchOnYouTube() async {
    Uri url = Uri.parse(widget.videoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open YouTube';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _saveFinalProgress();
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("YouTube Video Player"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _saveFinalProgress();
              Navigator.pop(context);
            },
          ),
        ),
        body: OrientationBuilder(
          builder: (context, orientation) {
            bool isFullscreen = orientation == Orientation.landscape;
            double screenWidth = MediaQuery.of(context).size.width;
            double screenHeight = MediaQuery.of(context).size.height;

            return Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(isFullscreen ? 0 : 10),
                        child: ColorFiltered(
                          colorFilter: _showVideo
                              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                              : const ColorFilter.mode(Colors.black54, BlendMode.saturation),
                          child: _showVideo
                              ? SizedBox(
                            width: screenWidth,
                            height: isFullscreen ? screenHeight : screenHeight * 0.4,
                            child: YoutubePlayer(
                              controller: _controller!,
                              showVideoProgressIndicator: true,
                              progressIndicatorColor: Colors.red,
                              progressColors: const ProgressBarColors(
                                playedColor: Colors.red,
                                handleColor: Colors.redAccent,
                              ),
                            ),
                          )
                              : Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                      if (!_showVideo)
                        Positioned(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showVideo = true;
                                _initializePlayer();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                            ),
                            child: const Text("Watch Here"),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isFullscreen) ...[
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _watchOnYouTube,
                    icon: const Icon(Icons.open_in_new),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                    ),
                    label: const Text("Watch on YouTube"),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _saveFinalProgress();
    _controller?.removeListener(_trackProgress);
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }
}