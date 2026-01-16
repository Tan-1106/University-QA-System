import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:university_qa_system/core/network/auth_interceptor.dart';
import 'package:university_qa_system/core/network/connection_checker.dart';
import 'package:university_qa_system/core/services/secure_storage_service.dart';
import 'package:university_qa_system/features/api_management/data/data_sources/api_management_remote_data_source.dart';

import 'package:university_qa_system/features/authentication/data/data_sources/auth_remote_data_source.dart';
import 'package:university_qa_system/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:university_qa_system/features/authentication/domain/repositories/auth_repository.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/log_out.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/sign_in_with_elit.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/verify_user_access.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/sign_in_with_system_account.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/system_account_registration.dart';
import 'package:university_qa_system/features/authentication/presentation/bloc/auth_bloc.dart';

import 'package:university_qa_system/features/dashboard/data/data_sources/dashboard_remote_data_source.dart';
import 'package:university_qa_system/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:university_qa_system/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:university_qa_system/features/dashboard/domain/use_cases/load_dashboard_question_records.dart';
import 'package:university_qa_system/features/dashboard/domain/use_cases/load_dashboard_statistic.dart';
import 'package:university_qa_system/features/dashboard/domain/use_cases/respond_to_question.dart';
import 'package:university_qa_system/features/dashboard/presentation/bloc/dashboard_bloc.dart';

import 'package:university_qa_system/features/chat_box/data/data_sources/chat_box_remote_data_source.dart';
import 'package:university_qa_system/features/chat_box/data/repositories/chat_box_repository_impl.dart';
import 'package:university_qa_system/features/chat_box/domain/repositories/chat_box_repository.dart';
import 'package:university_qa_system/features/chat_box/domain/use_cases/ask_question.dart';
import 'package:university_qa_system/features/chat_box/domain/use_cases/send_feedback.dart';
import 'package:university_qa_system/features/chat_box/domain/use_cases/get_qa_history.dart';
import 'package:university_qa_system/features/chat_box/domain/use_cases/view_qa_record_details.dart';
import 'package:university_qa_system/features/chat_box/presentation/bloc/chat/chat_box_bloc.dart';
import 'package:university_qa_system/features/chat_box/presentation/bloc/history/history_bloc.dart';
import 'package:university_qa_system/features/chat_box/presentation/bloc/history_details/history_details_bloc.dart';

import 'package:university_qa_system/features/document/data/data_sources/document_remote_data_source.dart';
import 'package:university_qa_system/features/document/data/repositories/document_repository_impl.dart';
import 'package:university_qa_system/features/document/domain/repositories/document_repository.dart';
import 'package:university_qa_system/features/document/domain/use_cases/delete_document.dart';
import 'package:university_qa_system/features/document/domain/use_cases/get_existing_filters.dart';
import 'package:university_qa_system/features/document/domain/use_cases/get_faculty_documents.dart';
import 'package:university_qa_system/features/document/domain/use_cases/get_general_documents.dart';
import 'package:university_qa_system/features/document/domain/use_cases/update_document_basic_info.dart';
import 'package:university_qa_system/features/document/domain/use_cases/view_document.dart';
import 'package:university_qa_system/features/document/presentation/bloc/document_list/document_list_bloc.dart';
import 'package:university_qa_system/features/document/presentation/bloc/document_viewer/document_viewer_bloc.dart';
import 'package:university_qa_system/features/document/presentation/provider/document_provider.dart';

import 'package:university_qa_system/features/popular_question/data/data_sources/popular_question_data_source.dart';
import 'package:university_qa_system/features/popular_question/data/repositories/popular_questions_repository_impl.dart';
import 'package:university_qa_system/features/popular_question/domain/repositories/popular_questions_repository.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/assign_faculty_scope_to_question.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/generate_popular_questions.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/load_admin_popular_questions.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/load_student_popular_questions.dart';
import 'package:university_qa_system/features/popular_question/presentation/bloc/student_pq/student_pq_bloc.dart';
import 'package:university_qa_system/features/popular_question/presentation/bloc/admin_pq/admin_pq_bloc.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/load_existing_faculties.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/toggle_question_display_status.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/update_question.dart';

import 'package:university_qa_system/features/user_management/data/data_sources/user_management_remote_data_source.dart';
import 'package:university_qa_system/features/user_management/presentation/bloc/user_management_bloc.dart';
import 'package:university_qa_system/features/user_management/data/repositories/user_management_repository_impl.dart';
import 'package:university_qa_system/features/user_management/domain/repositories/user_management_repository.dart';
import 'package:university_qa_system/features/user_management/domain/use_cases/assign_role.dart';
import 'package:university_qa_system/features/user_management/domain/use_cases/change_ban_status.dart';
import 'package:university_qa_system/features/user_management/domain/use_cases/load_all_faculties.dart';
import 'package:university_qa_system/features/user_management/domain/use_cases/load_all_roles.dart';
import 'package:university_qa_system/features/user_management/domain/use_cases/load_users.dart';

import 'package:university_qa_system/features/api_management/data/repositories/api_management_repository_impl.dart';
import 'package:university_qa_system/features/api_management/domain/repositories/api_management_repository.dart';
import 'package:university_qa_system/features/api_management/domain/use_cases/load_api_keys.dart';
import 'package:university_qa_system/features/api_management/domain/use_cases/delete_api_key.dart';
import 'package:university_qa_system/features/api_management/domain/use_cases/get_key_models.dart';
import 'package:university_qa_system/features/api_management/domain/use_cases/add_api_key.dart';
import 'package:university_qa_system/features/api_management/domain/use_cases/add_key_model.dart';
import 'package:university_qa_system/features/api_management/presentation/bloc/api_key/api_keys_bloc.dart';



part 'init_dependencies.main.dart';
