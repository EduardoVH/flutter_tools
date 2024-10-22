import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:torch_flashlight/torch_flashlight.dart'; // Ensure the library is correctly installed.

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  bool _isFlashOn = false;
  bool _isTorchAvailable = false;

  // Variables to store sensor data
  List<double>? _accelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;

  @override
  void initState() {
    super.initState();
    _checkTorchAvailability(); // Check if the flashlight is available
    _listenToSensors();
  }

  // Check if the flashlight is available on the device
  Future<void> _checkTorchAvailability() async {
    bool isAvailable = await TorchFlashlight.isTorchFlashlightAvailable();
    setState(() {
      _isTorchAvailable = isAvailable;
    });
  }

  void _listenToSensors() {
    // Listen to accelerometer events
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    });

    // Listen to gyroscope events
    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    });

    // Listen to magnetometer events
    magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        _magnetometerValues = <double>[event.x, event.y, event.z];
      });
    });
  }

  // Toggle flashlight on/off
  Future<void> _toggleFlash() async {
    if (!_isTorchAvailable) {
      print("Flashlight not available on this device.");
      return;
    }

    try {
      if (_isFlashOn) {
        await TorchFlashlight.disableTorchFlashlight(); // Method to turn off the flashlight
      } else {
        await TorchFlashlight.enableTorchFlashlight(); // Method to turn on the flashlight
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      print("Error controlling the flashlight: $e");
    }
  }

  // Display sensor values on the screen
  Widget _buildSensorData(String sensorName, List<double>? values) {
    return Text(
      '$sensorName: ${values?.map((v) => v.toStringAsFixed(2)).toList() ?? 'Waiting...'}',
      style: const TextStyle(fontSize: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensors and Flashlight')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _toggleFlash,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFlashOn ? Colors.red : Colors.green, // Change color based on state
                foregroundColor: Colors.white, // Change text color
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Adjust padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
              ),
              child: Text(_isFlashOn ? 'Turn Off Flashlight' : 'Turn On Flashlight'),
            ),
            const SizedBox(height: 20),
            _buildSensorData('Accelerometer', _accelerometerValues),
            const SizedBox(height: 10),
            _buildSensorData('Gyroscope', _gyroscopeValues),
            const SizedBox(height: 10),
            _buildSensorData('Magnetometer', _magnetometerValues),
          ],
        ),
      ),
    );
  }
}
