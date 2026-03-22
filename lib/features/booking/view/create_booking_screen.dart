import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/worker_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../viewmodel/booking_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateBookingScreen extends StatefulWidget {
  final WorkerModel worker;

  const CreateBookingScreen({super.key, required this.worker});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _notesController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  Future<void> _submitBooking() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Date and Time')),
      );
      return;
    }

    final bookingVM = Provider.of<BookingViewModel>(context, listen: false);

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    final formattedTime = _selectedTime!.format(context);

    final booking = BookingModel(
      id: const Uuid().v4(),
      userId: currentUser.id,
      workerId: widget.worker.id,
      status: 'pending',
      date: _selectedDate,
      time: formattedTime,
      notes: _notesController.text,
      createdAt: DateTime.now(),
    );

    final success = await bookingVM.createBooking(booking);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Requested Successfully!')),
      );
      Navigator.pop(context); // Go back to worker profile
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bookingVM.error ?? 'Failed to book')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Book Service',
          style: TextStyle(color: AppColors.textPrimaryColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking ${widget.worker.name}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.worker.category,
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'When do you need the service?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedDate == null
                                ? 'Select Date'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedTime == null
                                ? 'Select Time'
                                : _selectedTime!.format(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Job Description / Notes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe what needs to be fixed or done...',
                prefixIcon: const Icon(
                  Icons.notes,
                  color: AppColors.primaryColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            Consumer<BookingViewModel>(
              builder: (context, vm, child) {
                return CustomButton(
                  text: 'Confirm Booking Request',
                  isLoading: vm.isLoading,
                  onPressed: _submitBooking,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
