import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../models/member_model.dart';
import '../repositories/member_repository.dart';

part 'member_event.dart';
part 'member_state.dart';

@injectable
class MemberBloc extends Bloc<MemberEvent, MemberState> {
  final MemberRepository _repository;

  MemberBloc(this._repository) : super(MemberInitial()) {
    on<LoadMembers>(_onLoadMembers);
    on<LoadAllMembers>(_onLoadAllMembers);
    on<SearchMembersEvent>(_onSearchMembers);
    on<ClearMemberSearch>(_onClearSearch);
    on<CreateMemberEvent>(_onCreateMember);
    on<UpdateMemberEvent>(_onUpdateMember);
    on<DeleteMemberEvent>(_onDeleteMember);
  }

  Future<void> _onLoadMembers(LoadMembers event, Emitter<MemberState> emit) async {
    emit(MemberLoading());
    final result = await _repository.getActiveMembers();
    result.fold(
      (f) => emit(MemberError(f.message)),
      (list) => emit(MemberLoaded(members: list)),
    );
  }

  Future<void> _onLoadAllMembers(LoadAllMembers event, Emitter<MemberState> emit) async {
    emit(MemberLoading());
    final result = await _repository.getAllMembers();
    result.fold(
      (f) => emit(MemberError(f.message)),
      (list) => emit(MemberLoaded(members: list)),
    );
  }

  Future<void> _onSearchMembers(SearchMembersEvent event, Emitter<MemberState> emit) async {
    if (event.term.isEmpty) {
      add(const LoadMembers(activeOnly: false));
      return;
    }
    emit(MemberLoading());
    final result = await _repository.searchMembers(event.term);
    result.fold(
      (f) => emit(MemberError(f.message)),
      (list) => emit(MemberLoaded(members: list)),
    );
  }

  Future<void> _onClearSearch(ClearMemberSearch event, Emitter<MemberState> emit) async {
    add(const LoadAllMembers());
  }

  Future<void> _onCreateMember(CreateMemberEvent event, Emitter<MemberState> emit) async {
    final result = await _repository.insertMember(event.member);
    result.fold(
      (f) => emit(MemberOperationFailure(
        message: f.message,
        members: state is MemberLoaded ? (state as MemberLoaded).members : [],
      )),
      (_) async {
        add(const LoadAllMembers());
        emit(MemberOperationSuccess(
          message: 'เพิ่มสมาชิกเรียบร้อยแล้ว',
          members: state is MemberLoaded ? (state as MemberLoaded).members : [],
        ));
      },
    );
  }

  Future<void> _onUpdateMember(UpdateMemberEvent event, Emitter<MemberState> emit) async {
    final result = await _repository.updateMember(event.member);
    result.fold(
      (f) => emit(MemberOperationFailure(
        message: f.message,
        members: state is MemberLoaded ? (state as MemberLoaded).members : [],
      )),
      (_) async {
        add(const LoadAllMembers());
        emit(MemberOperationSuccess(
          message: 'แก้ไขสมาชิกเรียบร้อยแล้ว',
          members: state is MemberLoaded ? (state as MemberLoaded).members : [],
        ));
      },
    );
  }

  Future<void> _onDeleteMember(DeleteMemberEvent event, Emitter<MemberState> emit) async {
    final result = await _repository.deleteMember(event.member);
    result.fold(
      (f) => emit(MemberOperationFailure(
        message: f.message,
        members: state is MemberLoaded ? (state as MemberLoaded).members : [],
      )),
      (_) async {
        add(const LoadAllMembers());
        emit(MemberOperationSuccess(
          message: 'ลบสมาชิกเรียบร้อยแล้ว',
          members: state is MemberLoaded ? (state as MemberLoaded).members : [],
        ));
      },
    );
  }
}
