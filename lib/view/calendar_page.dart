import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../components/calendar_event_tile.dart';
import '../models/project_task.dart';
import '../providers/calendar_provider.dart';
import '../providers/project_provider.dart';
import '../repositories/task_repository.dart';
import 'project_detail_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final Map<String, List<ProjectTask>> _tasksByProject = {};
  final List<StreamSubscription<List<ProjectTask>>> _subscriptions = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _watchTasks();
  }

  void _watchTasks() {
    final projectProvider = context.watch<ProjectProvider>();
    final uid = projectProvider.uid;
    if (uid == null) return;
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _tasksByProject.clear();
    final taskRepository = context.read<TaskRepository>();
    for (final project in projectProvider.projects) {
      _subscriptions
          .add(taskRepository.watchTasks(uid, project.id).listen((tasks) {
        if (!mounted) return;
        setState(() => _tasksByProject[project.id] = tasks);
      }));
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = context.watch<ProjectProvider>().projects;
    final events = CalendarProvider.groupEvents(
      projects: projects,
      tasksByProject: _tasksByProject,
    );
    DateTime normalizeDay(DateTime value) {
      return DateTime(value.year, value.month, value.day);
    }

    final normalizedSelected = normalizeDay(_selectedDay);
    final selectedEvents =
        events[normalizedSelected] ?? const <CalendarEvent>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Calendário')),
      body: ListView(
        children: [
          TableCalendar<CalendarEvent>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2040, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            eventLoader: (day) {
              final normalized = normalizeDay(day);
              return events[normalized] ?? const <CalendarEvent>[];
            },
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = normalizeDay(selected);
                _focusedDay = focused;
              });
            },
            calendarStyle: const CalendarStyle(markersMaxCount: 3),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Eventos de ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          if (selectedEvents.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child:
                  Text('Nenhum prazo nesta data.', textAlign: TextAlign.center),
            )
          else
            ...selectedEvents.map((event) {
              final project = event.project ??
                  projects
                      .where((item) => item.id == event.projectId)
                      .firstOrNull;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: CalendarEventTile(
                  event: event,
                  onTap: project == null
                      ? () {}
                      : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  ProjectDetailPage(project: project),
                            ),
                          ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
