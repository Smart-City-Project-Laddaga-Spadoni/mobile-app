// Mocks generated by Mockito 5.4.4 from annotations
// in mobile_app/test/widget_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:http/http.dart' as _i2;
import 'package:mobile_app/services/api_service.dart' as _i3;
import 'package:mobile_app/services/storage_service.dart' as _i5;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeResponse_0 extends _i1.SmartFake implements _i2.Response {
  _FakeResponse_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [ApiService].
///
/// See the documentation for Mockito's code generation for more information.
class MockApiService extends _i1.Mock implements _i3.ApiService {
  MockApiService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.Response> login(
    String? serverUrl,
    String? username,
    String? password,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #login,
          [
            serverUrl,
            username,
            password,
          ],
        ),
        returnValue: _i4.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #login,
            [
              serverUrl,
              username,
              password,
            ],
          ),
        )),
      ) as _i4.Future<_i2.Response>);

  @override
  _i4.Future<_i2.Response> fetchDeviceStatus(
    String? serverUrl,
    String? deviceId,
    String? token,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchDeviceStatus,
          [
            serverUrl,
            deviceId,
            token,
          ],
        ),
        returnValue: _i4.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #fetchDeviceStatus,
            [
              serverUrl,
              deviceId,
              token,
            ],
          ),
        )),
      ) as _i4.Future<_i2.Response>);

  @override
  _i4.Future<_i2.Response> toggleLight(
    String? serverUrl,
    String? deviceId,
    bool? isLightOn,
    String? token,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #toggleLight,
          [
            serverUrl,
            deviceId,
            isLightOn,
            token,
          ],
        ),
        returnValue: _i4.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #toggleLight,
            [
              serverUrl,
              deviceId,
              isLightOn,
              token,
            ],
          ),
        )),
      ) as _i4.Future<_i2.Response>);
}

/// A class which mocks [StorageService].
///
/// See the documentation for Mockito's code generation for more information.
class MockStorageService extends _i1.Mock implements _i5.StorageService {
  MockStorageService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<void> write(
    String? key,
    String? value,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #write,
          [
            key,
            value,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<String?> read(String? key) => (super.noSuchMethod(
        Invocation.method(
          #read,
          [key],
        ),
        returnValue: _i4.Future<String?>.value(),
      ) as _i4.Future<String?>);

  @override
  _i4.Future<void> delete(String? key) => (super.noSuchMethod(
        Invocation.method(
          #delete,
          [key],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}
