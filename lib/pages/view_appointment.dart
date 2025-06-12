/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/appointment_view_model.dart';

class ViewAppointment extends StatelessWidget {
  const ViewAppointment({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(title: const Text("My Appointment")),
          body: Column(
            children: [
              _buildDateSelector(viewModel),
              _buildTabSelector(viewModel),
              Expanded(child: _buildAppointmentList(viewModel)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateSelector(AppointmentViewModel viewModel) {
    final dates = ["8", "9", "10", "11"];
    final days = ["Mon", "Tue", "Wed", "Thu"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(dates.length, (i) {
        final selected = viewModel.selectedDate == dates[i];
        return GestureDetector(
          onTap: () => viewModel.setDate(dates[i]),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selected ? Colors.teal[100] : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(dates[i], style: const TextStyle(fontSize: 18)),
                Text(days[i]),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTabSelector(AppointmentViewModel viewModel) {
    final tabs = ["Upcoming", "Completed", "Cancelled"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: tabs.map((tab) {
        final selected = viewModel.selectedTab == tab;
        return GestureDetector(
          onTap: () => viewModel.setTab(tab),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? Colors.black : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(tab,
                style:
                    TextStyle(color: selected ? Colors.white : Colors.black)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAppointmentList(AppointmentViewModel viewModel) {
    final list = viewModel.filteredAppointments;

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final appointment = list[index];
        return ListTile(
          leading:
              CircleAvatar(backgroundImage: NetworkImage(appointment.imageUrl)),
          title: Text(appointment.doctorName),
          subtitle: Text("${appointment.hospitalName}\n${appointment.time}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {}, // View details logic
                child: const Text("View"),
              ),
              const SizedBox(width: 8),
              if (appointment.status == "Upcoming")
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => viewModel.cancelAppointment(appointment),
                  child: const Text("Cancel"),
                ),
            ],
          ),
        );
      },
    );
  }
}
*/
