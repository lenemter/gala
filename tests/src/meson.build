tests = [
    'DockTest',
    # 'GalaSetupTest',
]

test_sources = []
foreach test : tests
    test_sources += test + '.vala'
endforeach

src_test_sources = files(
    'GalaTestCase.vala',
    'Main.vala',
)

test_executable = executable(
    'io.elementary.gala.tests',
    common_test_sources,
    src_test_sources,
    test_sources,
    dependencies: [gala_dep, gala_bin_dep],
    install: false,
)

foreach test : tests
    test(test, test_executable, args: 'Gala' + test, suite: ['Gala', 'Gala/bin'], is_parallel: false, timeout: 60)
endforeach

