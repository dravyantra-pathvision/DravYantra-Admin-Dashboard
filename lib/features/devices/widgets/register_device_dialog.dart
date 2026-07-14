import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class RegisterDeviceDialog extends StatefulWidget {
  const RegisterDeviceDialog({Key? key}) : super(key: key);

  @override
  State<RegisterDeviceDialog> createState() => _RegisterDeviceDialogState();
}

class _RegisterDeviceDialogState extends State<RegisterDeviceDialog> {
  final _formKey = GlobalKey<FormState>();
  
  final _deviceIdCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  final _firmwareCtrl = TextEditingController();
  final _hardwareCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _manufacturerCtrl = TextEditingController();
  final _macCtrl = TextEditingController();
  final _gpsCtrl = TextEditingController();
  final _fuelCtrl = TextEditingController();
  final _imeiCtrl = TextEditingController();
  final _simCtrl = TextEditingController();
  
  bool _accelerometer = false;

  @override
  void dispose() {
    _deviceIdCtrl.dispose();
    _serialCtrl.dispose();
    _firmwareCtrl.dispose();
    _hardwareCtrl.dispose();
    _typeCtrl.dispose();
    _manufacturerCtrl.dispose();
    _macCtrl.dispose();
    _gpsCtrl.dispose();
    _fuelCtrl.dispose();
    _imeiCtrl.dispose();
    _simCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'device_id': _deviceIdCtrl.text.trim(),
        'serial_number': _serialCtrl.text.trim(),
        'firmware_version': _firmwareCtrl.text.trim(),
        'hardware_version': _hardwareCtrl.text.trim(),
        'device_type': _typeCtrl.text.trim(),
        'manufacturer': _manufacturerCtrl.text.trim(),
        'mac_address': _macCtrl.text.trim(),
        'gps_module': _gpsCtrl.text.trim(),
        'fuel_sensor': _fuelCtrl.text.trim(),
        'imei': _imeiCtrl.text.trim(),
        'sim_number': _simCtrl.text.trim(),
        'accelerometer': _accelerometer,
      };
      Navigator.of(context).pop(data);
    }
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: ctrl,
        style: const TextStyle(color: AdminTheme.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AdminTheme.textSecondary),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AdminTheme.border)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AdminTheme.primary)),
        ),
        validator: isRequired ? (v) => v == null || v.trim().isEmpty ? 'Required field' : null : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AdminTheme.surface,
      title: const Text('Register New Device', style: TextStyle(color: AdminTheme.textPrimary)),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildTextField('Device ID (e.g. DY-DEV-001)', _deviceIdCtrl, isRequired: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('Serial Number', _serialCtrl, isRequired: true)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Manufacturer', _manufacturerCtrl, isRequired: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('Device Type', _typeCtrl, isRequired: true)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Hardware Version', _hardwareCtrl, isRequired: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('Firmware Version', _firmwareCtrl, isRequired: true)),
                  ],
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Align(alignment: Alignment.centerLeft, child: Text('Network & Sensors', style: TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.textPrimary))),
                ),
                Row(
                  children: [
                    Expanded(child: _buildTextField('MAC Address', _macCtrl)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('IMEI (Optional)', _imeiCtrl)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildTextField('SIM Number (Optional)', _simCtrl)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('GPS Module', _gpsCtrl)),
                  ],
                ),
                _buildTextField('Fuel Sensor Type', _fuelCtrl),
                SwitchListTile(
                  title: const Text('Accelerometer Available', style: TextStyle(color: AdminTheme.textPrimary)),
                  value: _accelerometer,
                  activeColor: AdminTheme.primary,
                  onChanged: (val) => setState(() => _accelerometer = val),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: AdminTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: Colors.white),
          child: const Text('Register Device'),
        ),
      ],
    );
  }
}
