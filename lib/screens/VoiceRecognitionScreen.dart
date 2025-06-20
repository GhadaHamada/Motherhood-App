import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:html' as html;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            backgroundColor: const Color(0xFF8A2BE2),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const VoiceRecognitionScreen(),
    );
  }
}

class VoiceRecognitionScreen extends StatefulWidget {
  const VoiceRecognitionScreen({super.key});

  @override
  _VoiceRecognitionScreenState createState() => _VoiceRecognitionScreenState();
}

class _VoiceRecognitionScreenState extends State<VoiceRecognitionScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _records = [];
  bool _isLoading = false;
  bool _isRecording = false;
  bool _showScrollToBottom = false;
  bool _isDeleting = false;
  Map<String, dynamic>? _deleteProps;
  String? _token;
  int _currentPlayingIndex = -1;
  Map<int, String> _durationCache = {};

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _loadTokenAndRecords();
    _scrollController.addListener(_handleScroll);
  }

  Future<void> _initializeRecorder() async {
    await _audioRecorder.openRecorder();
    _audioPlayer.durationStream.listen((Duration? d) {
      if (_currentPlayingIndex != -1 && d != null) {
        setState(() {
          _durationCache[_currentPlayingIndex] = _formatDuration(d);
        });
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _loadTokenAndRecords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
      print('Loaded token: ${_token?.substring(0, 20)}...');
    });
    if (_token != null) {
      await _fetchRecords();
    }
  }

  void _handleScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    setState(() {
      _showScrollToBottom = (maxScroll - currentScroll > 100);
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _pickAndUploadAudio() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null && result.files.isNotEmpty) {
        setState(() => _isLoading = true);
        var file = result.files.single;
        if (kIsWeb) {
          Uint8List fileBytes = file.bytes!;
          await _uploadAudioFileFromBytes(fileBytes, file.name);
        } else {
          File audioFile = File(file.path!);
          String mp3Path = await _convertToMp3(audioFile);
          await _uploadAudioFile(File(mp3Path));
        }
      }
    } catch (e) {
      _showMessage('Error selecting file: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _convertToMp3(File inputFile) async {
    final tempDir = await getTemporaryDirectory();
    final mp3Path =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp3';
    final result = await _flutterFFmpeg
        .execute('-i ${inputFile.path} -c:a mp3 -b:a 192k $mp3Path');
    if (result != 0) {
      throw Exception('FFmpeg conversion failed with code $result');
    }
    print('Converted to MP3: $mp3Path');
    return mp3Path;
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.isEncoderSupported(Codec.opusWebM)) {
        Directory tempDir = await getTemporaryDirectory();
        String path =
            '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.webm';
        await _audioRecorder.startRecorder(toFile: path, codec: Codec.opusWebM);
        setState(() {
          _isRecording = true;
        });
      } else {
        _showMessage('WebM codec not supported');
      }
    } catch (e) {
      _showMessage('Recording error: $e');
    }
  }

  Future<void> _stopRecordingAndUpload() async {
    try {
      String? path = await _audioRecorder.stopRecorder();
      if (path != null) {
        setState(() => _isLoading = true);
        File audioFile = File(path);
        String mp3Path = await _convertToMp3(audioFile);
        await _uploadAudioFile(File(mp3Path));
      }
    } catch (e) {
      _showMessage('Recording stop error: $e');
    } finally {
      setState(() {
        _isRecording = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadAudioFile(File audioFile) async {
    if (_token == null) {
      _showMessage('Authentication required');
      return;
    }
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://localhost:7054/api/BabyRecord/Upload'),
      );
      request.headers
          .addAll({'Authorization': 'Bearer $_token', 'accept': '*/*'});
      request.files.add(await http.MultipartFile.fromPath(
        'File',
        audioFile.path,
        contentType: MediaType('audio', 'mpeg'),
        filename: 'audio.mp3',
      ));
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('Upload response: ${response.statusCode} - $responseBody');
      if (response.statusCode == 200) {
        _showMessage('Analysis completed!');
        await _fetchRecords();
        _scrollToBottom();
      } else {
        throw Exception(
            'Upload failed: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      _showMessage('Upload error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadAudioFileFromBytes(
      Uint8List fileBytes, String fileName) async {
    if (_token == null) {
      _showMessage('Authentication required');
      return;
    }
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://localhost:7054/api/BabyRecord/Upload'),
      );
      request.headers
          .addAll({'Authorization': 'Bearer $_token', 'accept': '*/*'});
      request.files.add(http.MultipartFile.fromBytes(
        'File',
        fileBytes,
        filename: fileName.endsWith('.mp3') ? fileName : 'audio.mp3',
        contentType: MediaType('audio', 'mpeg'),
      ));
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('Upload bytes response: ${response.statusCode} - $responseBody');
      if (response.statusCode == 200) {
        _showMessage('Analysis completed!');
        await _fetchRecords();
        _scrollToBottom();
      } else {
        throw Exception(
            'Upload failed: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      _showMessage('Upload error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchRecords() async {
    if (_token == null) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://localhost:7054/api/BabyRecord/records'),
        headers: {'Authorization': 'Bearer $_token', 'accept': '*/*'},
      );
      print(
          'Fetch records response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _records = data
              .map((record) => {
                    'id': record['id'].toString(),
                    'prediction': record['prediction'] ??
                        'Failed to recognize this voice.',
                    'date': record['uploadedAt'],
                    'audioUrl': record['fileUrl'] ??
                        'https://localhost:7054/uploads/${record['fileName']}',
                  })
              .toList();
          print('Records fetched: $_records');
        });
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      } else {
        throw Exception(
            'Fetch failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _showMessage('Fetch error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRecord(String id, String type) async {
    if (_token == null) return;
    try {
      final url = type == 'ONE'
          ? 'https://localhost:7054/api/BabyRecord/DeleteVoiceWithPrediction/$id'
          : 'https://localhost:7054/api/BabyRecord/DeleteUserRecords/$id';
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $_token', 'accept': '*/*'},
      );
      print(
          'Delete response: ${response.statusCode} - ${response.reasonPhrase}');
      if (response.statusCode == 200) {
        _showMessage('Deleted successfully');
        await _fetchRecords();
      } else {
        throw Exception(
            'Delete failed: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      _showMessage('Delete error: $e');
    } finally {
      setState(() {
        _isDeleting = false;
        _deleteProps = null;
      });
    }
  }

  Future<void> _playAudio(String url, int index) async {
    try {
      print('Attempting to play audio: $url');

      if (_currentPlayingIndex == index) {
        print('Pausing audio: $url');
        await _audioPlayer.pause();
        setState(() => _currentPlayingIndex = -1);
        return;
      }

      print('Stopping previous playback');
      await _audioPlayer.stop();
      setState(() => _currentPlayingIndex = -1);

      if (url == null || url.isEmpty) {
        _showMessage('Invalid audio URL');
        return;
      }

      await _playAudioFromFile(url, index);
    } catch (e) {
      print('Playback error: $e');
      _showMessage('Playback error: $e');
    }
  }

  Future<void> _playAudioFromFile(String url, int index) async {
    try {
      print(
          'Fetching audio from: $url with token: ${_token?.substring(0, 20)}...');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'audio/mpeg,audio/wav,*/*',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body length: ${response.bodyBytes.length} bytes');

      if (response.statusCode == 200) {
        final audioBytes = response.bodyBytes;
        if (audioBytes.isEmpty) {
          print('Empty audio bytes received');
          _showMessage('Empty audio data received.');
          return;
        }

        final contentType =
            response.headers['content-type']?.toLowerCase() ?? '';
        print('Content-Type: $contentType');
        String mimeType =
            contentType.contains('audio/wav') ? 'audio/wav' : 'audio/mpeg';
        if (!contentType.contains('audio/mpeg') &&
            !contentType.contains('audio/wav')) {
          print('Unsupported content type: $contentType');
          _showMessage('Unsupported audio format: $contentType');
          return;
        }

        print('Encoding audio to Base64');
        final base64String = base64Encode(audioBytes);
        final base64Uri = 'data:$mimeType;base64,$base64String';
        print('Base64 URI length: ${base64Uri.length} characters');

        if (kIsWeb) {
          print('Playing audio with HtmlAudioElement');
          final audio = html.AudioElement(base64Uri);
          await audio.play().catchError((e) {
            print('HtmlAudioElement error: $e');
            _showMessage('Error playing audio: $e');
            return e;
          });
          setState(() => _currentPlayingIndex = index);
          audio.onEnded.listen((_) {
            print('Audio completed: $url');
            setState(() => _currentPlayingIndex = -1);
          });
          audio.onError.listen((e) {
            print('HtmlAudioElement playback error: $e');
            _showMessage('Playback error: $e');
          });
        } else {
          print('Playing audio with just_audio (Base64)');
          await _audioPlayer.setUrl(base64Uri);
          await _audioPlayer.play();
          setState(() => _currentPlayingIndex = index);
          _audioPlayer.playerStateStream.listen((state) {
            if (state.processingState == ProcessingState.completed) {
              print('Audio completed: $url');
              setState(() => _currentPlayingIndex = -1);
            }
          });
        }
      } else {
        print(
            'Failed to fetch audio: ${response.statusCode} - ${response.reasonPhrase}');
        _showMessage(
            'Failed to fetch audio: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('File playback error: $e');
      _showMessage('File playback error: $e');
    }
  }

  void _startDelete(String id, String type) {
    setState(() {
      _isDeleting = true;
      _deleteProps = {'id': id, 'type': type};
    });
  }

  void _cancelDelete() {
    setState(() {
      _isDeleting = false;
      _deleteProps = null;
    });
  }

  Widget _buildWelcomeMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xffDDD8D8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFF605B5B),
            child: Text('AI', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Hello! 😊 I\'m here to help you understand your baby\'s needs. You can record your baby\'s crying or upload an audio file, and I\'ll analyze it to provide the best advice for you.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionMessage(Map<String, dynamic> record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xffDDD8D8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xff6c6868),
            child: Text('AI', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  record['prediction'],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(record['date']),
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xff4a4646)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceCard(Map<String, dynamic> record, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xff8D7D97),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, color: Colors.grey[700], size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _durationCache[index] ?? '0:00',
                      style: TextStyle(fontSize: 15, color: Color(0xffc9c1c1)),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _currentPlayingIndex == index
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: const Color(0xFFD9D9D9D9),
                            size: 30,
                          ),
                          onPressed: () =>
                              _playAudio(record['audioUrl'], index),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert,
                              color: Color(0xFFD9D9D9D9)),
                          onSelected: (value) {
                            if (value == 'delete') {
                              _startDelete(record['id'], 'ONE');
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(record['date']),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFCBC3D6), // لون واحد بدل التدرج
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Image.asset('assets/images/back (1).png'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/Ellipse 59.png', // استبدل بمسار الصورة المناسب
                          height: 30,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Voice Recognition',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10), // مسافة بعد النص
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        itemCount: 1 + (_records.length * 2),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildWelcomeMessage();
                          }
                          final recordIndex = (index - 1) ~/ 2;
                          final isVoiceCard = (index - 1) % 2 == 0;
                          final record = _records[recordIndex];
                          if (isVoiceCard) {
                            return _buildVoiceCard(record, recordIndex);
                          } else {
                            return _buildPredictionMessage(record);
                          }
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xffCBC3D6),
                  boxShadow: const [
                    /*BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),*/
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file,
                          color: Color(0xffD9D9D9D9)),
                      label: const Text('Upload',
                          style: TextStyle(color: Color(0xffD9D9D9D9))),
                      onPressed: _isLoading ? null : _pickAndUploadAudio,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8D7D97)),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(_isRecording ? Icons.stop : Icons.mic,
                          color: Color(0xffD9D9D9D9)),
                      label: Text(
                        _isRecording ? 'Stop' : 'Record',
                        style: TextStyle(color: Color(0xffD9D9D9D9)),
                      ),
                      onPressed: _isLoading
                          ? null
                          : (_isRecording
                              ? _stopRecordingAndUpload
                              : _startRecording),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8D7D97),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_showScrollToBottom)
            Positioned(
              right: 16,
              bottom: 100,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xffc1bbbb),
                onPressed: _scrollToBottom,
                child:
                    const Icon(Icons.arrow_downward, color: Color(0xff8D7D97)),
              ),
            ),
          if (_isDeleting)
            DeleteConfirmationDialog(
              onCancel: _cancelDelete,
              onConfirm: () =>
                  _deleteRecord(_deleteProps!['id'], _deleteProps!['type']),
              deleteText: _deleteProps!['type'] == 'ONE'
                  ? 'this voice permanently'
                  : 'all voices permanently',
            ),
        ],
      ),
      floatingActionButton: _records.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: Color(0xffc1bbbb),
              onPressed: () => _startDelete('', 'ALL'),
              child: const Icon(Icons.delete, color: Color(0xff8D7D97)),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder.closeRecorder();
    _scrollController.dispose();
    super.dispose();
  }
}

class DeleteConfirmationDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final String deleteText;

  const DeleteConfirmationDialog({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    required this.deleteText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Confirm Delete',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Are you sure you want to delete $deleteText?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffc1bbbb)),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
/*import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // لتحديد إذا كنا نعمل على الويب

class VoiceRecognitionScreen extends StatefulWidget {
  @override
  _VoiceRecognitionScreenState createState() => _VoiceRecognitionScreenState();
}

class _VoiceRecognitionScreenState extends State<VoiceRecognitionScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg(); // إضافة FlutterFFmpeg

  List<Map<String, dynamic>> _records = [];
  bool _isLoading = false;
  bool _isRecording = false;
  int _recordingDuration = 0;
  Timer? _recordingTimer;
  String? _token;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _loadTokenAndRecords();
  }

  Future<void> _initializeRecorder() async {
    await _audioRecorder.openRecorder();
  }

  Future<void> _loadTokenAndRecords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });

    if (_token != null) {
      await _fetchRecords();
    }
  }

  Future<void> _pickAndUploadAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio, // السماح بجميع أنواع الملفات الصوتية
      );

      if (result != null && result.files.isNotEmpty) {
        var file = result.files.single;

        // عند الويب استخدم bytes بدلاً من path
        if (kIsWeb) {
          // عند الويب نستخدم bytes للملف
          Uint8List fileBytes = file.bytes!;
          await _uploadAudioFileFromBytes(fileBytes, file.name);
        } else {
          File audioFile = File(file.path!);
          // تحويل الملف إلى MP3 قبل رفعه
          String mp3Path = await _convertToMp3(audioFile);
          await _uploadAudioFile(File(mp3Path)); // رفع الملف المحول
        }
      }
    } catch (e) {
      _showMessage('Error selecting file: $e');
    }
  }

  // طريقة لتحويل الصوت إلى MP3
  Future<String> _convertToMp3(File inputFile) async {
    final tempDir = await getTemporaryDirectory();
    final mp3Path =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp3';

    await _flutterFFmpeg.execute('-i ${inputFile.path} $mp3Path');
    return mp3Path;
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.isEncoderSupported(Codec.aacADTS)) {
        Directory tempDir = await getTemporaryDirectory();
        String path =
            '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _audioRecorder.startRecorder(
          toFile: path,
          codec: Codec.pcm16WAV,
        );

        setState(() {
          _isRecording = true;
          _recordingDuration = 0;
        });

        _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() => _recordingDuration++);
        });
      }
    } catch (e) {
      _showMessage('Recording error: $e');
    }
  }

  Future<void> _stopRecordingAndUpload() async {
    try {
      String? path = await _audioRecorder.stopRecorder();
      _recordingTimer?.cancel();

      if (path != null) {
        File audioFile = File(path);
        // تحويل الملف إلى MP3 قبل رفعه
        String mp3Path = await _convertToMp3(audioFile);
        await _uploadAudioFile(File(mp3Path)); // رفع الملف المحول
      }
    } catch (e) {
      _showMessage('Recording stop error: $e');
    } finally {
      setState(() => _isRecording = false);
    }
  }

  Future<void> _uploadAudioFile(File audioFile) async {
    if (_token == null) {
      _showMessage('Authentication required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://localhost:7054/api/BabyRecord/Upload'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $_token',
       */ // 'accept': '*/*',
/*});

      request.files.add(await http.MultipartFile.fromPath(
        'File',
        audioFile.path,
        contentType:
            MediaType('audio', 'mp3'), // تأكد من تحديد نوع الملف الصحيح
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        _showMessage('Analysis completed!');
        await _fetchRecords();
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Upload error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadAudioFileFromBytes(
      Uint8List fileBytes, String fileName) async {
    if (_token == null) {
      _showMessage('Authentication required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://localhost:7054/api/BabyRecord/Upload'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $_token',
       */ // 'accept': '*/*',
/*});

      request.files.add(http.MultipartFile.fromBytes(
        'File',
        fileBytes,
        filename: fileName,
        contentType: MediaType('audio', 'mp3'), // تحديد نوع الصوت كمرفق MP3
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        _showMessage('Analysis completed!');
        await _fetchRecords();
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Upload error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchRecords() async {
    if (_token == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://localhost:7054/api/BabyRecord/records'),
        headers: {
          'Authorization': 'Bearer $_token',
         */ // 'accept': '*/*',
/*},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _records = data
              .map((record) => {
                    'id': record['id'],
                    'prediction': record['prediction'],
                    'date': record['uploadedAt'],
                    'audioUrl': record['fileUrl'],
                  })
              .toList();
        });
      }
    } catch (e) {
      _showMessage('Fetch error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _playAudio(String url) async {
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      _showMessage('Playback error: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, h:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Baby Voice Analysis'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(record['prediction']),
                          subtitle: Text(_formatDate(record['date'])),
                          trailing: IconButton(
                            icon: Icon(Icons.play_arrow),
                            onPressed: () => _playAudio(record['audioUrl']),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.upload_file),
                    label: Text('Upload Audio'),
                    onPressed: _pickAndUploadAudio,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                    label: Text(
                        _isRecording ? 'Stop ($_recordingDuration)' : 'Record'),
                    onPressed: _isRecording
                        ? _stopRecordingAndUpload
                        : _startRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecording ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder.closeRecorder();
    _recordingTimer?.cancel();
    super.dispose();
  }
}
*/
/*
import 'dart:io';
import 'dart:convert'; // لتحويل JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart'; // لاختيار الملفات
import 'package:audioplayers/audioplayers.dart'; // لتشغيل الصوت

class VoiceRecognitionScreen extends StatefulWidget {
  @override
  _VoiceRecognitionScreenState createState() => _VoiceRecognitionScreenState();
}

class _VoiceRecognitionScreenState extends State<VoiceRecognitionScreen> {
  List<Map<String, String>> messages = []; // قائمة الرسائل
  bool isLoading = false;
  File? audioFile;
  final AudioPlayer audioPlayer = AudioPlayer(); // لتشغيل الصوت

  @override
  void initState() {
    super.initState();
    // إضافة رسالة ترحيبية
    messages.add({
      'text':
          'Welcome to the Voice Recognition System! You can record or upload your baby\'s sound, and we\'ll help analyze it to provide appropriate advice.',
      'sender': 'system',
    });
    fetchBabyRecords(); // جلب السجلات عند بدء التشغيل
  }

  Future<void> fetchBabyRecords() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found');
    }

    final url = Uri.parse('https://localhost:7054/api/BabyRecord/records');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> records = json.decode(response.body);
        for (var record in records) {
          setState(() {
            messages.add({
              'text': 'تحليل الصوت: ${record['prediction'] ?? 'لا يوجد تحليل'}',
              'sender': 'system',
            });
          });
        }
      } else {
        setState(() {
          messages.add({
            'text': 'فشل في جلب السجلات. الرجاء المحاولة مرة أخرى.',
            'sender': 'system',
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          'text': 'حدث خطأ أثناء جلب السجلات: $e',
          'sender': 'system',
        });
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> uploadAudioFile() async {
    if (audioFile == null) {
      print(
          'audioFile is null. Please select a file first.'); // طباعة رسالة تحذيرية
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an audio file first.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found');
    }

    final url = Uri.parse('https://localhost:7054/api/BabyRecord/Upload');

    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('File', audioFile!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final prediction = json.decode(responseData)['prediction'];

      setState(() {
        messages.add({
          'text': 'تم تحميل الملف بنجاح. التحليل: $prediction',
          'sender': 'system',
        });
      });
      fetchBabyRecords(); // تحديث السجلات بعد الرفع
    } else {
      setState(() {
        messages.add({
          'text': 'فشل في تحميل الملف. الرجاء المحاولة مرة أخرى.',
          'sender': 'system',
        });
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> pickAudioFile() async {
    print('بدء اختيار الملف...'); // طباعة رسالة بدء العملية

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio, // اختيار ملفات الصوت فقط
    );

    if (result != null) {
      print(
          'تم اختيار ملف: ${result.files.single.path}'); // طباعة مسار الملف المختار

      setState(() {
        audioFile = File(result.files.single.path!);
        print(
            'تم تعيين audioFile: ${audioFile?.path}'); // طباعة مسار audioFile بعد التعيين

        messages.add({
          'text': 'تم اختيار الملف: ${audioFile!.path}',
          'sender': 'user',
        });
        print('تمت إضافة رسالة إلى القائمة.'); // طباعة تأكيد إضافة الرسالة
      });
    } else {
      print('لم يتم اختيار أي ملف.'); // طباعة رسالة عدم اختيار ملف
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No file selected.')),
      );
    }

    print('انتهاء اختيار الملف.'); // طباعة رسالة انتهاء العملية
  }

  Future<void> recordAudio() async {
    // يمكنك استخدام حزمة مثل `audiorecorder` لتسجيل الصوت
    // هنا سنضيف رسالة وهمية لتسجيل الصوت
    setState(() {
      messages.add({
        'text': 'تم تسجيل صوت جديد.',
        'sender': 'user',
      });
    });

    // بعد التسجيل، يمكنك إرسال الملف المسجل إلى السيرفر
    // هنا نستخدم نفس وظيفة uploadAudioFile لإرسال الملف المسجل
    await uploadAudioFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Recognition Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ChatBubble(
                  text: message['text']!,
                  isMe: message['sender'] == 'user',
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: pickAudioFile,
                    child: Text('Upload'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: recordAudio,
                    child: Text('Record'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const ChatBubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

*/
