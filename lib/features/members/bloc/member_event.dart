part of 'member_bloc.dart';

abstract class MemberEvent extends Equatable {
  const MemberEvent();

  @override
  List<Object?> get props => [];
}

class LoadMembers extends MemberEvent {
  final bool activeOnly;

  const LoadMembers({this.activeOnly = true});
}

class LoadAllMembers extends MemberEvent {
  const LoadAllMembers();
}

class SearchMembersEvent extends MemberEvent {
  final String term;

  const SearchMembersEvent(this.term);

  @override
  List<Object?> get props => [term];
}

class ClearMemberSearch extends MemberEvent {
  const ClearMemberSearch();
}

class CreateMemberEvent extends MemberEvent {
  final MemberModel member;

  const CreateMemberEvent(this.member);

  @override
  List<Object?> get props => [member];
}

class UpdateMemberEvent extends MemberEvent {
  final MemberModel member;

  const UpdateMemberEvent(this.member);

  @override
  List<Object?> get props => [member];
}

class DeleteMemberEvent extends MemberEvent {
  final MemberModel member;

  const DeleteMemberEvent(this.member);

  @override
  List<Object?> get props => [member];
}
