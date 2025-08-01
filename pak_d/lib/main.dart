import 'package:flutter/material.dart';
import 'websocket_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';






void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'AI Detection',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'SF Pro Text',
        ),
        home: const HomePage(),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // รายชื่อโรคและรายละเอียดสั้น ๆ
  static final List<Map<String, String>> diseaseList = [
    {
      "image": "assets/mouth_ulcer.png",
      "title": "แผลบาดเจ็บช่องปากทั่วไป",
      "description": "แผลที่เกิดจากการกระทบกระเทือนหรืออุบัติเหตุเล็กๆ ภายในช่องปาก"
    },
    {
      "image": "assets/canker_sore.png",
      "title": "แผลร้อนใน",
      "description": "แผลจุดเล็กสีขาวที่เกิดภายในช่องปาก เช่น กระพุ้งแก้ม ลิ้น หรือเหงือก"
    },
    {
      "image": "assets/herpes_simplex.png",
      "title": "เริม",
      "description": "เริมในช่องปากและริมฝีปาก มักจะมีลักษณะตุ่มน้ำใสๆ"
    },
    {
      "image": "assets/oral_cancer.png",
      "title": "มะเร็งปาก",
      "description": "ก้อนหรือแผลเรื้อรังในช่องปาก อาจเจ็บหรือเลือดออกง่าย"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            'Home',
            style: TextStyle(
              color: Colors.black,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // เนื้อหาเลื่อนขึ้นลงได้
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // How to use image section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                  child: Image.asset(
                    'assets/howto.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    'โรคที่สามารถตรวจพบได้',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: diseaseList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final disease = diseaseList[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DiseaseDetailPage(disease: disease),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center, // เปลี่ยนจาก start เป็น center
                                children: [
                                  Text(
                                    disease["title"]!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF356AE6),
                                    ),
                                    textAlign: TextAlign.center, // เพิ่มบรรทัดนี้
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    disease["description"]!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center, // เพิ่มบรรทัดนี้
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: Colors.black26, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // ปุ่มกล้องลอยล่างกลางจอ
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CameraPage(),
                    ),
                  );
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow:const [
                      BoxShadow (
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _image;
  Map<String, dynamic>? _result;
  bool _isLoading = false;

  final WebSocketService _webSocketService =
      WebSocketService(url: 'ws://192.168.1.170:8001/ws');

  bool _isWsConnected = false;

  @override
  void initState() {
    super.initState();
    _webSocketService.connect((data) {
      debugPrint('Received WS message: $data');
    });

    _waitForWebSocketConnection();
  }

  Future<void> _waitForWebSocketConnection() async {
    while (!_webSocketService.isConnected) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    setState(() {
      _isWsConnected = true;
    });
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }

  Future<void> _sendImageWithWebSocket(File imageFile) async {
    if (!_isWsConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WebSocket ยังไม่เชื่อมต่อ กรุณาลองใหม่อีกครั้ง')),
      );
      return;
    }

    try {
      setState(() {
        _image = imageFile;
        _isLoading = true;
        _result = null;
      });

      final result = await _webSocketService.sendImageAndWait(imageFile);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _result = result;
      });

      if (result != null && result['status'] == 'success') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultPage(
              image: imageFile,
              result: result,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result?['message'] ?? "ไม่สามารถประมวลผลได้"}'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาอนุญาตให้แอปเข้าถึงกล้อง')),
        );
      }
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      await _sendImageWithWebSocket(imageFile);
    }
  }

  Future<void> _pickFromGallery() async {
    final permission =
        Platform.isAndroid ? Permission.storage : Permission.photos;
    final status = await permission.request();

    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาอนุญาตให้แอปเข้าถึงแกลเลอรี่')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      await _sendImageWithWebSocket(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _image != null
                ? Image.file(
                    _image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(
                        Icons.camera_alt,
                        size: 80,
                        color: Colors.white24,
                      ),
                    ),
                  ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white70,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.only(top: 16, bottom: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'รบกวนถ่ายให้ชัดเจนโดยพยายามโฟกัสบริเวณที่ต้องการตรวจ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: _pickFromGallery,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image, size: 24),
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 30,
                                ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Toggle camera
                        },
                        child: const SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(Icons.flip_camera_ios, size: 28),
                        ),
                      ),
                    ],
                  ),
                  if (_result != null)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResultPage(
                                image: _image!,
                                result: _result!,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          ResultPage.labelToTitle[_result!['disease']] ?? 'ผลการตรวจ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final File image;
  final Map<String, dynamic> result;

  const ResultPage({
    super.key,
    required this.image,
    required this.result,
  });

  // Map label เป็นชื่อโรคที่แสดง
  static const Map<String, String> labelToTitle = {
    "normal": "ปกติ",
    "herpes": "เริม",
    "ulcer": "แผลร้อนใน",
    "cancer": "มะเร็งปาก",
    "injury": "แผลบาดเจ็บช่องปากทั่วไป",
  };

  @override
  Widget build(BuildContext context) {
    // debug print เพื่อตรวจสอบค่า label ที่ได้มา
    debugPrint('Received result label: ${result['label']}');

    // อ่าน label จากผลลัพธ์ backend และแปลงเป็น lowercase เผื่อ format ไม่ตรงกัน
    final String label = (result['label'] as String?)?.toLowerCase() ?? 'ulcer';

    // แปลง label เป็นชื่อแสดงผล
    final String title = labelToTitle[label] ?? "ไม่ทราบผล";

    // เช็คว่าเป็น normal หรือไม่
    final bool isNormal = label == "normal";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // รูปภาพ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.file(
                image,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // หัวข้อ
          const Text(
            "ผลการวิเคราะห์",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          // ชื่อโรค
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF356AE6),
            ),
          ),
          const SizedBox(height: 8),
          // ปุ่มรายละเอียดเพิ่มเติม (ถ้าไม่ใช่ปกติ)
          if (!isNormal)
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiseaseDetailPage(
                      disease: {
                        "title": title,
                        // เพิ่ม field อื่นถ้าต้องการ
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF356AE6)),
              label: const Text(
                "รายละเอียดเพิ่มเติม",
                style: TextStyle(
                  color: Color(0xFF356AE6),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF356AE6),
              ),
            )
          else
            const SizedBox(height: 32),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(
              '⚠️ คำเตือน:\nผลลัพธ์นี้เป็นเพียงการวิเคราะห์เบื้องต้นโดยระบบปัญญาประดิษฐ์\nหากอาการไม่ดีขึ้นภายใน 3–5 วัน หรือมีอาการรุนแรง ควรพบแพทย์หรือทันตแพทย์เพื่อรับการวินิจฉัยที่ถูกต้อง',
              style: TextStyle(
                color: Color(0xFF356AE6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // ปุ่ม home ใหญ่
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DiseaseDetailPage extends StatelessWidget {
  final Map<String, String> disease;
  const DiseaseDetailPage({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    final isMouthUlcer = disease["title"] == "แผลบาดเจ็บช่องปากทั่วไป";
    final isCankerSore = disease["title"] == "แผลร้อนใน";
    final isHerpes = disease["title"] == "เริม";
    final isOralCancer = disease["title"] == "มะเร็งปาก";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          disease["title"] ?? "",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isMouthUlcer)
               Column(
                children: [
                  // เพิ่มรูปภาพตรงนี้
                  Image.asset(
                    "assets/mu2.png",
                    width: 180,
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "แผลบาดเจ็บ\nช่องปากทั่วไป",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF356AE6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "แผลที่เกิดจากการระคายเคือง หรืออุบัติเหตุเล็กๆ ภายในช่องปาก เช่น เผลอกัดตัวเอง หรือกินของร้อนเกินไป ไม่ได้เกิดจากเชื้อ และมักหายเองได้ มักเป็นเพียงชั่วคราว ไม่เกี่ยวข้องกับโรคเรื้อรัง",
                    style: TextStyle(fontSize: 16, height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Align (
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "สาเหตุของแผล",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF356AE6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "• กัดปากโดยไม่ตั้งใจ หรือเคี้ยวโดนกระพุ้งแก้ม\n"
                      "• กินอาหารแข็ง กรอบ หรือของทอดที่ขอบคม\n"
                      "• ดื่มของร้อนจัด เช่น ชา กาแฟ ซุปเดือด\n"
                      "• เครื่องมือจัดฟัน ฟันปลอม ฟันซี่แหลมขูดเนื้อเยื่อในปาก\n"
                      "• แปรงฟันแรงเกินไป หรือใช้แปรงขนแข็งเกิน",
                      style: TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "ลักษณะแผลและอาการ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF356AE6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "• แผลเล็ก แดงหรือขาว เจ็บนิดหน่อย\n"
                      "• ไม่มีตุ่มน้ำ ไม่มีขอบแดงชัด\n"
                      "• หายได้เองใน 3–7 วัน โดยไม่ทิ้งรอย\n"
                      "• อาจรู้สึกระคายเคืองเวลารับประทานอาหารร้อนหรือรสจัด",
                      style: TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "การดูแลเบื้องต้น",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF356AE6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "• อมน้ำเกลือ หรือบ้วนปากด้วยน้ำสะอาดผสม เบกกิ้งโซดาเล็กน้อย\n"
                      "• หลีกเลี่ยงของเผ็ด เปรี้ยว ร้อน หรือแข็ง\n"
                      "• ใช้ยาทาแผลเฉพาะจุด เช่น ยาสมานแผลที่ไม่มี steroid\n"
                      "• ดูแลสุขอนามัยในช่องปากให้สะอาดทุกวัน",
                      style: TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "ควรไปพบแพทย์เมื่อใด?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF356AE6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "• แผลไม่หายใน 14 วัน\n"
                      "• มีอาการบวมแดงรุนแรง มีหนอง หรือกลิ่นปากผิดปกติ\n"
                      "• มีไข้ หรือมีแผลหลายจุด",
                      style: TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "ขอขอบคุณ แหล่งที่มาจาก\n"
                      "mouth ulcers - better health channel\n"
                      "แผลในปาก 5 ชนิด ที่พบได้บ่อย - SKT Dental Center",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            else if (isCankerSore)
              // แผลร้อนใน
              Column(
                children: [
                  Image.asset(
                    "assets/cs2.png",
                    width: 180,
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "แผลร้อนใน",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF356AE6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "แผลร้อนใน คือ แผลอักเสบเล็กๆ ที่เกิดภายในช่องปาก เช่น ที่กระพุ้งแก้ม ลิ้น หรือเหงือก โดยไม่ได้เกิดจากเชื้อโรค และไม่ติดต่อ มักเกิดซ้ำๆ ในบางคน โดยเฉพาะเวลาที่ร่างกายอ่อนแอ เครียด หรือขาดวิตามินบางชนิด เป็นภาวะที่พบได้บ่อย โดยเฉพาะในวัยรุ่นและวัยทำงาน",
                    style: TextStyle(fontSize: 16, height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "สาเหตุของแผลร้อนใน",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF356AE6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "• พันธุกรรม\n"
                      "• ขาดวิตามิน B12, D, กรดโฟลิก หรือธาตุเหล็ก\n"
                      "• ภาวะเครียด พักผ่อนน้อย หรือภูมิคุ้มกันต่ำ\n"
                      "• ฮอร์โมนแปรปรวน (เช่น ช่วงมีประจำเดือน)\n"
                      "• การแพ้อาหารบางชนิด เช่น ถั่ว นม ช็อกโกแลต มะเขือเทศ (แต่ละคนอาจไม่เหมือนกัน)\n"
                      "• การบาดเจ็บในปาก เช่น กัดปาก ฟันขูด แปรงฟันแรงเกินไป",
                      style: TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "ลักษณะแผลและอาการ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF356AE6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "• แผลกลมหรือรี ขอบแดง ขาวตรงกลาง\n"
                      "• เจ็บมากโดยเฉพาะเวลาพูด กิน หรือแปรงฟัน\n"
                      "• ไม่มีกลิ่น ไม่มีไข้ และไม่ติดต่อ\n"
                      "• มักเกิดที่เยื่อบุอ่อน เช่น กระพุ้งแก้ม ลิ้นด้านล่าง พื้นปาก\n"
                      "• เกิดซ้ำได้เรื่อยๆ โดยเฉพาะเวลาร่างกายอ่อนแอ",
                      style: TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "การดูแลเบื้องต้น",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF356AE6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "• อมน้ำเกลือวันละ 2–3 ครั้ง (ช่วยลดการอักเสบ ฆ่าเชื้ออ่อนๆ)\n"
                      "• หลีกเลี่ยงอาหารเผ็ด เปรี้ยว ร้อน หรือกรอบแข็ง\n"
                      "• ใช้ยาทาแผลที่มี steroid เช่น triamcinolone acetonide\n"
                      "• ใช้ยาชาเฉพาะที่ เช่น benzocaine เพื่อลดอาการเจ็บ\n"
                      "• รักษาสุขภาพร่างกายให้แข็งแรง นอนพักให้พอ",
                      style: TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "ควรไปพบแพทย์เมื่อ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF356AE6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "• แผลไม่หายใน 2 สัปดาห์\n"
                      "• มีอาการบวมแดงรุนแรง มีตุ่มหนอง หรือกลิ่นปากผิดปกติ\n"
                      "• มีไข้สูงเกิน 38 องศาเซลเซียส\n"
                      "• มีแผลในช่องปากหลายจุด หรือมีแผลขนาดใหญ่\n"
                      "• มีอาการเจ็บปวดรุนแรงจนทำกิจกรรมประจำวันลำบาก",
                      style: TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "ขอขอบคุณ แหล่งที่มาจาก\n"
                      "แผลร้อนใน (แผลในปาก) -  MedPark Hospital \n"
                      "ร้อนใน แผลในช่องปากที่ควรระวัง - รามา แชนแนล",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            else if (isHerpes)
              // --- ส่วนของโรคเริม ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ชื่อโรค
                  const Center(
                    child: Text(
                      "เริม",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF356AE6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // คำอธิบายเบื้องต้น
                  const Text(
                    "เริมสามารถเกิดได้ทั้งในช่องปากและที่ริมฝีปาก สาเหตุเกิดจากเชื้อไวรัสชนิดเดียวกับ คือ Herpes Simplex Virus type 1 หรือ ไวรัสชนิดที่ 1 แต่ตำแหน่งลักษณะและตำแหน่งที่เกิดก็มีความแตกต่างกันอยู่บ้าง ตัวอย่างเช่น เริมในช่องปากมักเกิดที่เยื่อบุภายในปาก ส่วนเริมที่ริมฝีปากจะเกิดที่ผิวหนังรอบริมฝีปาก",
                    style: TextStyle(fontSize: 16, height: 1.6),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 20),

                  // หัวข้อย่อย: เริมในปาก
                  const Text(
                    "• เริมในปาก",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF356AE6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Image.asset(
                      "assets/hsm.png", 
                      width: 180,
                      height: 120,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "เป็นการติดเชื้อไวรัส ภายในช่องปาก โดยมักพบครั้งแรกในเด็กเล็ก และอาจกลับมาเป็นซ้ำได้ตลอดชีวิตในช่วงที่ร่างกายอ่อนแอ ภูมิคุ้มกันต่ำ หรือเครียดสะสม โดยเฉพาะในผู้ที่ไม่เคยสัมผัสเชื้อมาก่อน หรือเพิ่งได้รับเชื้อใหม่",
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 20),

                  // ลักษณะแผล
                  const Text(
                    "ลักษณะแผล",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF356AE6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "• เจ็บจากตุ่มน้ำใสเล็กๆ เรียงตัวเป็นกลุ่ม (คล้ายผื่นหรือร้อนใน)\n"
                    "• ตุ่มจะแตกและกลายเป็นแผลเล็กๆ กระจายหลายจุด\n"
                    "• มักพบบริเวณริมฝีปาก เหงือก เพดานปาก ลิ้น หรือกระพุ้งแก้ม\n"
                    "• แผลมีอาการเจ็บรุนแรง โดยเฉพาะเวลารับประทานอาหารหรือพูด\n"
                    "• แผลจะหายได้ภายใน 7-10 วัน",
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 20),

                  // อาการที่มักพบ
                  const Text(
                    "อาการที่มักพบ",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF356AE6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "• มีไข้สูง โดยเฉพาะในเด็กเล็ก\n"
                    "• เหงือกบวมแดง บวม และเจ็บมาก\n"
                    "• มีอาการไหลมาก เพราะกลืนลำบาก\n"
                    "• เบื่ออาหาร หรือกินได้น้อย\n"
                    "• ต่อมน้ำเหลืองใต้คางโต\n"
                    "• อาจมีอาการเจ็บคอ ปวดศีรษะ",
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 20),

                  // การดูแลรักษา
                  const Text(
                    "การดูแลรักษา",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF356AE6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "• ยาต้านไวรัส เช่น acyclovir, valacyclovir, หรือ famciclovir (ควรเริ่มตั้งแต่วันแรกที่มีอาการ)\n"
                    "• ยาแก้ปวด ลดไข้ เช่น paracetamol หรือ ibuprofen\n"
                    "• อย่า/น้ำยาบ้วนปากแบบยาชาเพื่อลดอาการเจ็บ (เช่น lidocaine gel)\n"
                    "• ดื่มน้ำมากๆ เพื่อป้องกันภาวะขาดน้ำ โดยเฉพาะในเด็ก\n"
                    "• รับประทานอาหารอ่อน เย็น เช่น โจ๊ก ไอศกรีม โยเกิร์ต\n"
                    "• พักผ่อนมากๆ หลีกเลี่ยงการสัมผัสกับผู้อื่นจนกว่าตุ่มจะหาย",
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 20),

                  // เมื่อใดควรพบแพทย์
                  const Text(
                    "เมื่อใดควรพบแพทย์?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF356AE6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "• ใช้ยาตามอาการ ไม่ตอบกับอาหารหรือยา\n"
                    "• แผลจำนวนมาก เจ็บจนพูดหรือกลืนไม่ได้\n"
                    "• มีอาการรุนแรง เช่น ต่อมน้ำเหลืองบวม เจ็บมาก หรือมีไข้\n"
                    "• แผลไม่ดีขึ้นภายใน 10 วัน",
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 20),

                  // หัวข้อย่อย: เริมที่ริมฝีปาก
                  const Text(
                    "• เริมที่ริมฝีปาก",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF356AE6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Image.asset(
                      "assets/hsl.png", 
                      width: 180,
                      height: 120,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "บริเวณผิวหนังรอบริมฝีปาก ทำให้เกิดตุ่มน้ำเล็กๆ เป็นกลุ่มและกลายสะลายแผลพุพองขนาดเล็ก มักเรียกว่า “ไข้ริมฝีปาก” หรือ “แผลเย็น (cold sore)”",
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 24),

                  // ขอบคุณแหล่งที่มา
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "ขอขอบคุณ แหล่งที่มาจาก\n"
                      "เริม (Herpes simplex) – MedPark Hospital\n"
                      "Herpes oral – Mount Sinai",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            else if (isOralCancer)
              // --- ส่วนของมะเร็งช่องปาก ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ชื่อโรค
                  const Center(
                    child: Text(
                      "มะเร็งปาก",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF356AE6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // คำอธิบายเบื้องต้น
                  const Text(
                    "มะเร็งปาก สามารถเกิดขึ้นได้ทั้งในและนอกช่องปาก ซึ่งส่วนเป็นมะเร็งในช่องปากและมะเร็งที่ริมฝีปาก มะเร็งเกิดค่อนข้างช้าแต่แพร่กระจายเข้าสู่อวัยวะอื่นได้ ทั้งต่อมน้ำเหลืองและอวัยวะสำคัญอื่น ๆ การดูแลสุขภาพช่องปากสม่ำเสมอและตรวจพบแต่เนิ่น ๆ จะช่วยลดและชะลอโรค",
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 20),

                  // หัวข้อย่อย: มะเร็งในช่องปาก
                  const Text(
                    "• มะเร็งในช่องปาก",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF356AE6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Image.asset(
                      "assets/ioc.png", // เปลี่ยนชื่อไฟล์ตามที่คุณมี
                      width: 180,
                      height: 120,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "มะเร็งในช่องปาก คือมะเร็งที่เกิดบริเวณภายในช่องปาก เช่น ลิ้น เหงือก กระพุ้งแก้ม ฟันปาก หรือเพดานปาก โดยมักเริ่มจากก้อนเนื้อผิดปกติหรือแผลเรื้อรังที่ขอบแข็ง ซึ่งจะลุกลามและแพร่กระจายได้ง่ายถ้าไม่ได้ตรวจพบและรักษาตั้งแต่เนิ่นๆ",
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 20),

                  // สาเหตุและปัจจัยเสี่ยง
                  const Text(
                    "สาเหตุและปัจจัยเสี่ยง",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF356AE6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "• สูบบุหรี่หรือดื่มเครื่องดื่มแอลกอฮอล์\n"
                    "• อายุมากขึ้น โดยเฉพาะมากกว่า 40 ปี\n"
                    "• การติดเชื้อไวรัส HPV โดยเฉพาะสายพันธุ์ที่ก่อมะเร็ง\n"
                    "• สุขภาพช่องปากไม่ดี เช่น ฟันผุเรื้อรัง เหงือกอักเสบ หรือฟันปลอมที่ขูดกับเนื้อเยื่อ\n"
                    "• การระคายเคืองเรื้อรังจากการขูดหรือกัดกระพุ้งแก้ม ฟันปลอม หรือฟันซี่แหลม\n"
                    "• กรรมพันธุ์หรือประวัติครอบครัวเป็นมะเร็ง",
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 20),

                  // อาการเตือน
                  const Text(
                    "อาการเตือน",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF356AE6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "• แผลที่ริมฝีปากไม่หายเกิน 2-3 สัปดาห์\n"
                    "• ริมฝีปากหนา แข็ง หรือคล้ำเป็นจุดหรือรังสี\n"
                    "• มีก้อน หรือก้อนแข็งบริเวณริมฝีปาก\n"
                    "• มีเลือดออกจากริมฝีปากโดยไม่ทราบสาเหตุ\n"
                    "• ริมฝีปากคั่งบวมหรือเจ็บบริเวณแผล",
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 20),

                  // การวินิจฉัย
                  const Text(
                    "การวินิจฉัย",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF356AE6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "• แพทย์ตรวจร่างกายและดูแผลโดยละเอียด\n"
                    "• การตัดชิ้นเนื้อ (biopsy)\n"
                    "• การถ่ายภาพ CT หรือ MRI หากสงสัยว่ามีการลุกลาม",
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 20),

                  // การรักษา
                  const Text(
                    "การรักษา",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF356AE6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "• ผ่าตัดนำก้อนมะเร็งออก (มักได้ผลดีในระยะเริ่มแรก)\n"
                    "• การฉายรังสีบริเวณริมฝีปาก\n"
                    "• เคมีบำบัดในกรณีที่มีการลุกลามหรือแพร่กระจาย\n"
                    "• Targeted therapy หากตรวจพบยีนผิดปกติที่ตอบสนองต่อยาชนิดเฉพาะ",
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 20),

                  // เมื่อใดควรพบแพทย์?
                  const Text(
                    "เมื่อใดควรพบแพทย์?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF356AE6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "• มีแผลริมฝีปากที่ไม่หายภายใน 2 สัปดาห์\n"
                    "• มีก้อน ตุ่ม ปูด หรือแผลเลือดซึมผิดปกติ\n"
                    "• ริมฝีปากเปลี่ยนรูปร่างหรือรู้สึกผิดปกติแต่เนิ่นๆ",
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  // ขอบคุณแหล่งที่มา
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "ขอขอบคุณ แหล่งที่มาจาก\n"
                      "มะเร็งปากและช่องปากทุกชนิด – โรงพยาบาลเพชรเวช\n"
                      "Lip Cancer – Cleveland Clinic",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}