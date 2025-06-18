import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../services/doctor_service.dart';

class CreateDoctorPage extends StatefulWidget {
  const CreateDoctorPage({Key? key}) : super(key: key);

  @override
  State<CreateDoctorPage> createState() => _CreateDoctorPageState();
}

class _CreateDoctorPageState extends State<CreateDoctorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _imageUrlController = TextEditingController();

  final DoctorService _doctorService = DoctorService();

  bool _isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final doctor = Doctor(
        name: _nameController.text.trim(),
        specialty: _specialtyController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
      );

      try {
        await _doctorService.createDoctor(doctor);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor created successfully!')),
        );
        _formKey.currentState!.reset();
        _nameController.clear();
        _specialtyController.clear();
        _imageUrlController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create doctor: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Doctor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter name' : null,
              ),
              TextFormField(
                controller: _specialtyController,
                decoration: const InputDecoration(labelText: 'Specialty'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter specialty'
                    : null,
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter image URL'
                    : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Create Doctor'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
