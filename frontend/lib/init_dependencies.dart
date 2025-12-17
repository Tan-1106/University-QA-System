import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:university_qa_system/core/network/connection_checker.dart';
import 'package:university_qa_system/features/authentication/data/data_sources/auth_remote_data_source.dart';
import 'package:university_qa_system/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:university_qa_system/features/authentication/domain/repositories/auth_repository.dart';
import 'package:university_qa_system/features/authentication/domain/usecases/user_information.dart';
import 'package:university_qa_system/features/authentication/presentation/bloc/auth_bloc.dart';

part 'init_dependencies.main.dart';