import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'core/network/auth_interceptor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:university_qa_system/core/network/connection_checker.dart';
import 'package:university_qa_system/core/services/secure_storage_service.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:university_qa_system/features/authentication/data/data_sources/auth_remote_data_source.dart';
import 'package:university_qa_system/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:university_qa_system/features/authentication/domain/repositories/auth_repository.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/sign_in_with_elit.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/verify_user_access.dart';
import 'package:university_qa_system/features/authentication/presentation/bloc/auth_bloc.dart';

import 'package:university_qa_system/features/dashboard/data/data_sources/dashboard_remote_data_source.dart';
import 'package:university_qa_system/features/dashboard/data/repository/dashboard_repository_impl.dart';
import 'package:university_qa_system/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:university_qa_system/features/dashboard/domain/use_cases/load_dashboard_question_records.dart';
import 'package:university_qa_system/features/dashboard/domain/use_cases/load_dashboard_statistic.dart';
import 'package:university_qa_system/features/dashboard/presentation/bloc/dashboard_bloc.dart';

import 'package:university_qa_system/features/chat_box/data/data_sources/chat_box_remote_data_source.dart';
import 'package:university_qa_system/features/chat_box/data/repositories/chat_box_repository_impl.dart';
import 'package:university_qa_system/features/chat_box/domain/repositories/chat_box_repository.dart';
import 'package:university_qa_system/features/chat_box/domain/use_cases/ask_question.dart';
import 'package:university_qa_system/features/chat_box/presentation/bloc/chat_box_bloc.dart';

part 'init_dependencies.main.dart';
