import 'package:flutter/foundation.dart' show immutable;
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _uuid = Uuid();

/// A read-only description of a todo-item
class Todo extends HiveObject {
  Todo({
    required this.description,
    required this.id,
    this.completed = false,
  });

  String id;
  String description;
  bool completed;

  @override
  String toString() {
    return 'Todo(description: $description, completed: $completed)';
  }
}

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  Todo read(BinaryReader reader) {
    final id = reader.readString(),
        description = reader.readString(),
        completed = reader.readString();
    return Todo(description: description, id: id, completed: completed == "1");
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.description);
    writer.writeString(obj.completed ? "1" : "0");
  }

  @override
  int get typeId => 0;
}

final box = Hive.box<Todo>("todo");

/// An object that controls a list of [Todo].
class TodoList extends StateNotifier<List<Todo>> {
  TodoList([List<Todo>? initialTodos]) : super(initialTodos ?? []);

  void remove(Todo target) {
    box.delete(target.id);
    state = box.values.toList();
    // state = state.where((todo) => todo.id != target.id).toList();
    // Hive.box<Todo>("todo").delete(target.id);
  }

  void add(String description) {
    final id = _uuid.v4();
    box.put(id, Todo(description: description, id: id));
    state = box.values.toList();
  }

  void toggle(Todo todo) {
    todo.completed = !todo.completed;
    state = box.values.toList();
    todo.save();
  }

  void edit({required Todo todo, required String description}) {
    todo.description = description;
    state = box.values.toList();
    todo.save();
  }
}
