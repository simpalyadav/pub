// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:path/path.dart' as p;
import 'package:pub/src/io.dart';
import 'package:test/test.dart';

import '../../descriptor.dart' as d;
import '../../test_pub.dart';

void main() {
  test('recompiles a script if the snapshot is out-of-date', () async {
    final server = await servePackages();
    server.serve('foo', '1.0.0', contents: [
      d.dir('bin', [d.file('script.dart', "main(args) => print('ok');")])
    ]);

    await runPub(args: ['global', 'activate', 'foo']);

    await d.dir(cachePath, [
      d.dir('global_packages', [
        d.dir('foo', [
          d.dir('bin', [
            d.outOfDateSnapshot('script.dart-$versionSuffix.snapshot-1'),
          ])
        ])
      ])
    ]).create();

    deleteEntry(p.join(d.dir(cachePath).io.path, 'global_packages', 'foo',
        'bin', 'script.dart-$versionSuffix.snapshot'));
    var pub = await pubRun(global: true, args: ['foo:script']);
    // In the real world this would just print "hello!", but since we collect
    // all output we see the precompilation messages as well.
    expect(pub.stdout, emits('Building package executable...'));
    expect(pub.stdout, emitsThrough('ok'));
    await pub.shouldExit();

    await d.dir(cachePath, [
      d.dir('global_packages', [
        d.dir('foo', [
          d.dir('bin',
              [d.file('script.dart-$versionSuffix.snapshot', contains('ok'))])
        ])
      ])
    ]).validate();
  });
}
