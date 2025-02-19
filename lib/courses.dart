import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'video_player.dart';

class CoursesPage extends StatefulWidget {
  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  List<Map<String, String>> allVideos = [
    {"title": "Flutter Basics", "url": "https://youtu.be/VPvVD8t02U8", "section": "Beginner"},
    {"title": "Dart Programming", "url": "https://youtu.be/lHhRhPV--G0", "section": "Beginner"},
    {"title": "State Management", "url": "https://youtu.be/D4nhaszNW4o", "section": "Advanced"},
    {"title": "Firebase Integration", "url": "https://youtu.be/vl_AaCgudcY", "section": "Advanced"},
  ];

  List<Map<String, String>> filteredVideos = [];
  Map<String, int> progressData = {};
  String selectedSection = "All";
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    filteredVideos = allVideos;
    _loadProgress();
  }

  /// 🔹 Load saved watch progress from SharedPreferences
  Future<void> _loadProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, int> tempProgress = {};
    for (var video in allVideos) {
      String? videoId = YoutubePlayer.convertUrlToId(video["url"]!);
      if (videoId != null) {
        tempProgress[videoId] = prefs.getInt(videoId) ?? 0;
      }
    }
    setState(() {
      progressData = tempProgress;
    });
  }

  /// 🔹 Convert Minutes to `1 hr 5 min` format
  String formatWatchTime(int minutes) {
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;

    if (hours > 0 && remainingMinutes > 0) {
      return "$hours hr $remainingMinutes min";
    } else if (hours > 0) {
      return "$hours hr";
    } else {
      return "$remainingMinutes min";
    }
  }

  /// 🔹 Filter videos based on selected section & search query
  void filterVideos() {
    setState(() {
      filteredVideos = allVideos
          .where((video) =>
      (selectedSection == "All" || video["section"] == selectedSection) &&
          (searchQuery.isEmpty || video["title"]!.toLowerCase().contains(searchQuery.toLowerCase())))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Courses")),
      body: Column(
        children: [
          /// 🔹 Search Bar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Videos",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                searchQuery = value;
                filterVideos();
              },
            ),
          ),

          /// 🔹 Dropdown Filter (Beginner, Advanced)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButton<String>(
              value: selectedSection,
              isExpanded: true,
              items: ["All", "Beginner", "Advanced"]
                  .map((section) => DropdownMenuItem(value: section, child: Text(section)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedSection = value!;
                  filterVideos();
                });
              },
            ),
          ),

          /// 🔹 Video List in YouTube-style View
          Expanded(
            child: ListView.builder(
              itemCount: filteredVideos.length,
              itemBuilder: (context, index) {
                final video = filteredVideos[index];
                String? videoId = YoutubePlayer.convertUrlToId(video["url"]!);
                int lastWatched = progressData[videoId] ?? 0;
                String progressText = lastWatched > 0
                    ? "Last watched: ${formatWatchTime(Duration(seconds: lastWatched).inMinutes)}"
                    : "Not started";

                return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerPage(videoUrl: video["url"]!),
                        ),
                      );
                      await _loadProgress(); // 🔹 Reload progress after returning
                    },
                    child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 🔹 Video Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                          child: Image.network(
                            "https://img.youtube.com/vi/$videoId/0.jpg",
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),

                        /// 🔹 Video Title & Progress
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video["title"]!,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Section: ${video["section"]}",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 5),
                              Text(
                                progressText,
                                style: TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
