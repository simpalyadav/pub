// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:path/path.dart' as path;
import 'package:pub/src/io.dart';
import 'package:pub/src/validator.dart';
import 'package:pub/src/validator/license.dart';
import 'package:test/test.dart';

import '../descriptor.dart' as d;
import '../test_pub.dart';
import 'utils.dart';

Validator license() => LicenseValidator();

void main() {
  group('should consider a package valid if it', () {
    test('looks normal', () async {
      await d.validPackage.create();
      await expectValidation(license);
    });

    test('has both LICENSE and UNLICENSE file', () async {
      await d.validPackage.create();
      await d.file(path.join(appPath, 'UNLICENSE'), '').create();
      await expectValidation(license);
    });
  });

  group('should warn if it', () {
    test('has only a COPYING file', () async {
      await d.validPackage.create();
      deleteEntry(path.join(d.sandbox, appPath, 'LICENSE'));
      await d.file(path.join(appPath, 'COPYING'), '').create();
      await expectValidation(license, warnings: isNotEmpty);
    });

    test('has only an UNLICENSE file', () async {
      await d.validPackage.create();
      deleteEntry(path.join(d.sandbox, appPath, 'LICENSE'));
      await d.file(path.join(appPath, 'UNLICENSE'), '').create();
      await expectValidation(license, warnings: isNotEmpty);
    });

    test('has only a prefixed LICENSE file', () async {
      await d.validPackage.create();
      deleteEntry(path.join(d.sandbox, appPath, 'LICENSE'));
      await d.file(path.join(appPath, 'MIT_LICENSE'), '').create();
      await expectValidation(license, warnings: isNotEmpty);
    });

    test('has only a suffixed LICENSE file', () async {
      await d.validPackage.create();
      deleteEntry(path.join(d.sandbox, appPath, 'LICENSE'));
      await d.file(path.join(appPath, 'LICENSE.md'), '').create();
      await expectValidation(license, warnings: isNotEmpty);
    });
  });

  group('should consider a package invalid if it', () {
    test('has no LICENSE file', () async {
      await d.validPackage.create();
      deleteEntry(path.join(d.sandbox, appPath, 'LICENSE'));
      await expectValidation(license, errors: isNotEmpty);
    });

    test('has a prefixed UNLICENSE file', () async {
      await d.validPackage.create();
      deleteEntry(path.join(d.sandbox, appPath, 'LICENSE'));
      await d.file(path.join(appPath, 'MIT_UNLICENSE'), '').create();
      await expectValidation(license, errors: isNotEmpty);
    });

    test('has a .gitignored LICENSE file', () async {
      var repo = d.git(appPath, [d.file('.gitignore', 'LICENSE')]);
      await d.validPackage.create();
      await repo.create();
      await expectValidation(license, errors: isNotEmpty);
    });
  });
}
