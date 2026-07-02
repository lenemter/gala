/*
 * Copyright 2026 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Authored by: Leonhard Kargl <leo.kargl@proton.me>
 */

/**
 * More of a test for our testing infrastructure and not really
 * for testing any specific functionality of Gala.
 * Check that the MutterTestCase base class successfully sets up meta and clutter
 * and allows us to interact with it, e.g. by creating a Clutter actor.
 */
public class Gala.DockTest : GalaTestCase {
    private ManagedClient managed_client;
    private Meta.Window? window = null;

    construct {
        add_test ("Test dock launches", test_dock_launches);
        add_test ("Test crash", test_crash);
    }

    private void test_dock_launches () {
        managed_client = new ManagedClient (wm.get_display (), { "io.elementary.dock" });
        managed_client.window_created.connect ((window) => this.window = window);

        wait_for_dock_window ();
    }

    private void test_crash () {
        wait_for_seconds (5);

#if HAS_MUTTER48
        unowned var cursor_tracker = wm.get_display ().get_compositor ().get_backend ().get_cursor_tracker ();
#else
        unowned var cursor_tracker = wm.get_display ().get_cursor_tracker ();
#endif
        Graphene.Point coords = {};
        cursor_tracker.get_pointer (out coords, null);

        var frame_rect = window.get_frame_rect ();

        unowned var seat = Clutter.get_default_backend ().get_default_seat ();
        var pointer_device = seat.create_virtual_device (POINTER_DEVICE);
        pointer_device.notify_absolute_motion (
            Clutter.get_current_event_time () * 1000,
            frame_rect.x + frame_rect.width / 2 - coords.x,
            frame_rect.y + frame_rect.height / 2 - coords.y
        );

        wait_for_seconds (1);

        Graphene.Point new_coords = {};
        cursor_tracker.get_pointer (out new_coords, null);
        assert_true (new_coords.x != coords.x || new_coords.y != coords.y);

        for (var i = 0; i < 10; i++) {
            try {
                var subprocess = new GLib.Subprocess.newv ({ "killall", "io.elementary.dock" }, NONE);
                subprocess.wait_check (null);
                window = null;
            } catch (Error e) {
                assert_no_error (e);
            }

            wait_for_dock_window ();
            wait_for_seconds(3);
        }
    }

    private void wait_for_dock_window () {
        var context = MainContext.default ();

        while (window == null) {
            context.iteration (true);
        }
    }

    private void wait_for_seconds (uint seconds) {
        var context = MainContext.default ();
        var microseconds = seconds * 1000000;
        var initial_time = GLib.get_monotonic_time ();

        while (GLib.get_monotonic_time () - initial_time < microseconds) {
            context.iteration (true);
        }
    }
}
