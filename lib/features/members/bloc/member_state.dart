part of 'member_bloc.dart';

abstract class MemberState extends Equatable {
  const MemberState();

  @override
  List<Object?> get props => [];
}

class MemberInitial extends MemberState {}

class MemberLoading extends MemberState {}

class MemberLoaded extends MemberState {
  final List<MemberModel> members;

  const MemberLoaded({required this.members});

  @override
  List<Object?> get props => [members];
}

class MemberError extends MemberState {
  final String message;

  const MemberError(this.message);

  @override
  List<Object?> get props => [message];
}

class MemberOperationSuccess extends MemberState {
  final String message;
  final List<MemberModel> members;

  const MemberOperationSuccess({required this.message, required this.members});

  @override
  List<Object?> get props => [message, members];
}

class MemberOperationFailure extends MemberState {
  final String message;
  final List<MemberModel> members;

  const MemberOperationFailure({required this.message, required this.members});

  @override
  List<Object?> get props => [message, members];
}
