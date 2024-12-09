import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class PlannerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PlannerViewModel>.reactive(
      onModelReady: (model) async {
        await model.init();
        print('Planner Page initialized');
      },
      viewModelBuilder: () => PlannerViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Planner'),
            backgroundColor: kColDDSPrimaryDark,
          ),
          body: model.isBusy
              ? const Center(child: BusyWidget())
              : Column(
                  children: [
                    // Calendar Widget
                    // Padding(
                    //   padding: const EdgeInsets.all(16.0),
                    //   child: TableCalendar(
                    //     focusedDay: DateTime.now(),
                    //     firstDay: DateTime.utc(2020, 1, 1),
                    //     lastDay: DateTime.utc(2030, 12, 31),
                    //     eventLoader: (day) {
                    //       // Filter events by date
                    //       return model.getEventsForDay(day);
                    //     },
                    //     onDaySelected: (selectedDay, focusedDay) {
                    //       model.onDateSelected(selectedDay);
                    //     },
                    //     calendarStyle: CalendarStyle(
                    //       todayDecoration: BoxDecoration(
                    //         color: kColDDSPrimaryDark,
                    //         shape: BoxShape.circle,
                    //       ),
                    //       selectedDecoration: BoxDecoration(
                    //         color: Colors.blueAccent,
                    //         shape: BoxShape.circle,
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    // Event List for the selected date
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: ListView.builder(
                          itemCount: model.eventsForSelectedDay.length,
                          itemBuilder: (context, index) {
                            final event = model.eventsForSelectedDay[index];

                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 12.0, top: 10),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EventDetailView(eventId: event.id),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Time: ${event.time}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            event.title,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        event.description,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEventPage(),
                ),
              );
              if (result != null) {
                model.addEvent(result);
              }
            },
            backgroundColor: kColDDSPrimaryDark,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class PlannerViewModel extends BaseViewModel {
  List<Event> eventsForSelectedDay = [];

  Future<void> init() async {
    // Fetch initial events or perform setup if needed
  }

  List<Event> getEventsForDay(DateTime day) {
    // Retrieve events for the selected day
    return [
      Event(
        id: 1,
        title: 'Client Meeting',
        description: 'Discuss project details with the client.',
        time: '10:00 AM',
      ),
      Event(
        id: 2,
        title: 'Team Sync',
        description: 'Weekly team synchronization meeting.',
        time: '2:00 PM',
      ),
    ];
  }

  void onDateSelected(DateTime selectedDay) {
    // Handle date selection if you need to update the event list or perform any logic
    eventsForSelectedDay = getEventsForDay(selectedDay);
    notifyListeners();
  }

  void addEvent(Event event) {
    // Add new event to the list
    eventsForSelectedDay.add(event);
    notifyListeners();
  }
}

class Event {
  final int id;
  final String title;
  final String description;
  final String time;

  Event({
    this.id,
    this.title,
    this.description,
    this.time,
  });
}

class EventDetailView extends StatelessWidget {
  final int eventId;

  const EventDetailView({this.eventId});

  @override
  Widget build(BuildContext context) {
    // Fetch the event details using the eventId and display them
    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: Center(
        child: Text('Event details for event ID: $eventId'),
      ),
    );
  }
}

class AddEventPage extends StatelessWidget {
  const AddEventPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Event')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Example: Adding a new event
            Navigator.pop(
              context,
              Event(
                id: 3,
                title: 'New Event',
                description: 'New event description.',
                time: '4:00 PM',
              ),
            );
          },
          child: const Text('Add New Event'),
        ),
      ),
    );
  }
}
