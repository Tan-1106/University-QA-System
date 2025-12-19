import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'core/network/auth_interceptor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'features/authentication/domain/usecases/verify_user_access.dart';
import 'package:university_qa_system/core/network/connection_checker.dart';
import 'package:university_qa_system/core/services/secure_storage_service.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:university_qa_system/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:university_qa_system/features/authentication/domain/usecases/sign_in_with_elit.dart';
import 'package:university_qa_system/features/authentication/domain/repositories/auth_repository.dart';
import 'package:university_qa_system/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:university_qa_system/features/authentication/data/data_sources/auth_remote_data_source.dart';

part 'init_dependencies.main.dart';
