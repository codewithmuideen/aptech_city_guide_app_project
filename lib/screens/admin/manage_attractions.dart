import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/attraction.dart';
import '../../models/city.dart';
import '../../providers/city_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/image_source_picker.dart';
import '../../widgets/smart_image.dart';

class ManageAttractionsScreen extends StatelessWidget {
  const ManageAttractionsScreen({super.key});

  void _openEditor(BuildContext context, {Attraction? existing}) {
    final cities = context.read<CityProvider>().cities;
    if (cities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Create a city first')));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AttractionEditorSheet(existing: existing, cities: cities),
    );
  }

  @override
  Widget build(BuildContext context) {
    final city = context.watch<CityProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Attractions (${city.attractions.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_outlined),
            tooltip: 'Add attraction',
            onPressed: () => _openEditor(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Attraction'),
      ),
      body: city.attractions.isEmpty
          ? const Center(child: Text('No attractions yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: city.attractions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final a = city.attractions[i];
                final inCity = city.cities.firstWhere(
                    (c) => c.id == a.cityId,
                    orElse: () => City(
                        id: '',
                        name: 'Unknown',
                        country: '',
                        description: '',
                        imageUrl: '',
                        latitude: 0,
                        longitude: 0));
                return Card(
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SmartImage(
                          source: a.imageUrl, width: 60, height: 60),
                    ),
                    title: Text(a.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${a.category.label} - ${inCity.name}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () =>
                              _openEditor(context, existing: a)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete attraction?'),
                              content: Text(
                                  'Remove "${a.name}" and all of its reviews?'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (ok == true && context.mounted) {
                            await context
                                .read<CityProvider>()
                                .deleteAttraction(a.id);
                          }
                        },
                      ),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}

class _AttractionEditorSheet extends StatefulWidget {
  final Attraction? existing;
  final List<City> cities;
  const _AttractionEditorSheet({this.existing, required this.cities});

  @override
  State<_AttractionEditorSheet> createState() => _AttractionEditorSheetState();
}

class _AttractionEditorSheetState extends State<_AttractionEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _description;
  late TextEditingController _image;
  late TextEditingController _address;
  late TextEditingController _phone;
  late TextEditingController _website;
  late TextEditingController _hours;
  late TextEditingController _lat;
  late TextEditingController _lng;
  late String _cityId;
  late AttractionCategory _category;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _image = TextEditingController(text: e?.imageUrl ?? '');
    _address = TextEditingController(text: e?.address ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
    _website = TextEditingController(text: e?.website ?? '');
    _hours = TextEditingController(text: e?.openingHours ?? '');
    _lat = TextEditingController(text: e?.latitude.toString() ?? '');
    _lng = TextEditingController(text: e?.longitude.toString() ?? '');
    _cityId = e?.cityId ?? widget.cities.first.id;
    _category = e?.category ?? AttractionCategory.attraction;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _image.dispose();
    _address.dispose();
    _phone.dispose();
    _website.dispose();
    _hours.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please choose or paste an image for this attraction')));
      return;
    }
    final provider = context.read<CityProvider>();
    final a = Attraction(
      id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      cityId: _cityId,
      name: _name.text.trim(),
      category: _category,
      description: _description.text.trim(),
      imageUrl: _image.text.trim(),
      address: _address.text.trim(),
      phone: _phone.text.trim(),
      website: _website.text.trim(),
      openingHours: _hours.text.trim(),
      latitude: double.tryParse(_lat.text.trim()) ?? 0,
      longitude: double.tryParse(_lng.text.trim()) ?? 0,
    );
    if (widget.existing == null) {
      await provider.addAttraction(a);
    } else {
      await provider.updateAttraction(a);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.existing == null ? 'Add Attraction' : 'Edit Attraction',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _cityId,
                decoration: const InputDecoration(labelText: 'City'),
                items: widget.cities
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _cityId = v!),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<AttractionCategory>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: AttractionCategory.values
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              CustomTextField(
                  label: 'Name',
                  controller: _name,
                  validator: (v) => Validators.notEmpty(v, label: 'Name')),
              CustomTextField(
                label: 'Description',
                controller: _description,
                maxLines: 3,
                validator: (v) => Validators.notEmpty(v, label: 'Description'),
              ),
              ImageSourcePicker(controller: _image, label: 'Attraction image'),
              CustomTextField(label: 'Address', controller: _address),
              CustomTextField(label: 'Phone', controller: _phone),
              CustomTextField(label: 'Website', controller: _website),
              CustomTextField(label: 'Opening hours', controller: _hours),
              Row(children: [
                Expanded(
                    child: CustomTextField(
                        label: 'Latitude',
                        controller: _lat,
                        keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(
                    child: CustomTextField(
                        label: 'Longitude',
                        controller: _lng,
                        keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
