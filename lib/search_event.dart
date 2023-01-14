part of 'search_bloc.dart';

@immutable
abstract class SearchEvent {}

class SearchUserEvent extends SearchEvent {
  final String query;

  SearchUserEvent(this.query);
}