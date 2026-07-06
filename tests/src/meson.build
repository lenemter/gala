tests = [
    'GalaSetupTest',
    'DockTest',
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

glib_compile_schemas = find_program('glib-compile-schemas')

schema_xml = configure_file(
    input: '..' / '..' / 'data' / 'gala.gschema.xml',
    output: 'org.pantheon.desktop.gala.gschema.xml',
    copy: true,
)

schema_override = configure_file(
    input: '..' / '..' / 'data' / '20_elementary.pantheon.wm.gschema.override',
    output: '20_elementary.pantheon.wm.gschema.override',
    copy: true,
)

custom_target(
    'compile-test-schemas',
    input: [schema_xml, schema_override],
    output: 'gschemas.compiled',
    command: [
        glib_compile_schemas,
        '--targetdir', meson.current_build_dir(),
        meson.current_build_dir(),
    ],
    build_by_default: true,
)

foreach test : tests
    test(
        test,
        test_executable,
        env: {
            'GSETTINGS_SCHEMA_DIR': meson.current_build_dir(),
        },
        args: 'Gala' + test,
        suite: ['Gala', 'Gala/bin'],
        is_parallel: false,
        timeout: 120
    )
endforeach
