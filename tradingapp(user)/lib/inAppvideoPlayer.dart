// import 'package:flutter/material.dart';
// import 'package:chewie/chewie.dart';
// import 'package:video_player/video_player.dart';
//
// class InAppVideoPlayer extends StatefulWidget {
//   final String videoUrl;
//   const InAppVideoPlayer({Key? key, required this.videoUrl}) : super(key: key);
//
//   @override
//   State<InAppVideoPlayer> createState() => _InAppVideoPlayerState();
// }
//
// class _InAppVideoPlayerState extends State<InAppVideoPlayer> {
//   late VideoPlayerController _videoController;
//   ChewieController? _chewieController;
//
//   @override
//   void initState() {
//     super.initState();
//     _videoController = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         _chewieController = ChewieController(
//           videoPlayerController: _videoController,
//           autoPlay: true,
//           looping: false,
//           allowFullScreen: true,
//           allowMuting: true,
//           showControls: true,
//         );
//         setState(() {}); // rebuild after ChewieController is ready
//       });
//   }
//
//   @override
//   void dispose() {
//     _videoController.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Center(
//         child: _chewieController != null
//             ? Chewie(controller: _chewieController!)
//             : const CircularProgressIndicator(),
//       ),
//     );
//   }
// }

