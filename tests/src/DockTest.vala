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
    private Meta.Window? window = null;

    construct {
        add_test ("Test dock launches", test_dock_launches);
        add_test ("Test crash", test_crash);
    }

    private void test_dock_launches () {
        warning ("OwO 1");
        var a = new ManagedClient (wm.get_display (), { "io.elementary.dock" });
        a.window_created.connect ((window) => {
            this.window = window;

            quit_main_loop ();
        });

        run_main_loop ();
    }

    private void test_crash () {
        warning ("OwO 3");

        Timeout.add (5000, () => {
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

            cursor_tracker.get_pointer (out coords, null);
            warning ("%f %f", coords.x, coords.y);
            warning ("OwO 5");

            quit_main_loop ();
            return Source.REMOVE;
        });

        run_main_loop ();

        warning ("OwO 4");
    }
}
