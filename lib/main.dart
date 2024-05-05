import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Downloader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VideoDownloader(),
    );
  }
}

class VideoDownloader extends StatefulWidget {
  const VideoDownloader({super.key});

  @override
  _VideoDownloaderState createState() => _VideoDownloaderState();
}

class _VideoDownloaderState extends State<VideoDownloader> {
  final TextEditingController _playlistController = TextEditingController();
  final List<String> _downloadedMessages = [];
  bool _isDownloading = false;

  Future<void> _downloadVideos() async {
    if (_playlistController.text.isEmpty) {
      _showModal('Please enter a playlist URL.');
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      final playlistUrl = _playlistController.text;
      const apiUrl = 'http://localhost:8000/download-playlist/';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'urls': [playlistUrl],
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _downloadedMessages.add('Videos downloaded successfully!');
        });
      } else {
        throw Exception('Failed to download videos. Please try again later.');
      }
    } on http.ClientException {
      _showModal(
          'Failed to connect to the server. Please check your internet connection.');
    } catch (e) {
      _showModal('Error: $e');
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  void _showModal(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Downloader'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _playlistController,
              decoration: const InputDecoration(
                labelText: 'Enter Playlist URL',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isDownloading ? null : _downloadVideos,
              child: _isDownloading
                  ? const CircularProgressIndicator()
                  : const Text('Download Videos'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _downloadedMessages.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(_downloadedMessages[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
