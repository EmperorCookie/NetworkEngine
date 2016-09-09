///client_packet_handle(buffer)
var reason;
reason = buffer_read(argument0, buffer_u8);
switch(reason) {
    case NET.DISCONNECT:
        //show_debug_message("NE: Client connection closed by server.");
        show_debug_message("Reason: " + buffer_read(argument0, buffer_string));
        client_disconnect();
    break;
    case NET.PING:
        //show_debug_message("NE: Client received ping, sending pong.");
        var buff = buffer_create(1, buffer_grow, 1);
        buffer_write(buff, buffer_u8, NET.PING);
        network_send_packet(socket, buff, buffer_tell(buff));
        buffer_delete(buff);
    break;
    case NET.TIME:
        //show_debug_message("NE: Client received server time.");
        var timer = get_timer();
        var stime = buffer_read(argument0, buffer_f64) - (timer - server_time_timer) * 0.5;
        ds_list_add(server_time_iterations, stime - timer);
        if(ds_list_size(server_time_iterations) >= 10) {
            server_time_acquired = true;
            server_time_delta = 0;
            for(var i = 0; i < 10; i += 1) {
                server_time_delta += server_time_iterations[|i];
            }
            server_time_delta *= 0.1;
            show_debug_message("NE: Client finished time sync. Delta is " + string(server_time_delta * 0.000001) + "s.");
            ds_list_clear(server_time_iterations);
        } else {
            var buff = buffer_create(1, buffer_grow, 1);
            buffer_write(buff, buffer_u8, NET.TIME);
            server_time_timer = get_timer();
            network_send_packet(socket, buff, buffer_tell(buff));
            buffer_delete(buff);
        }
    break;
    case NET.TICK_RATE:
        //show_debug_message("NE: Client received tick rate.");
        tick_rate = buffer_read(argument0, buffer_u8);
    break;
    case NET.CREATE:
        //show_debug_message("NE: Client received entity creation.");
        // MULTIPLE ENTITIES //
        if(buffer_read(argument0, buffer_bool)) {
            while(true) {
                var nx = buffer_read(argument0, buffer_f64);
                var ny = buffer_read(argument0, buffer_f64);
                var no = buffer_read(argument0, buffer_u32);
                var ni = buffer_read(argument0, buffer_u32);
                // CREATE INSTANCE //
                with(instance_create(nx, ny, obj_entity)) {
                    // ADD CONNECTION INFORMATION //
                    server_id = ni;
                    other.remote_entities[?ni] = id;
                    // CHANGE INTO PROPER INSTANCE //
                    instance_change(no, 1);
                }
                if(!buffer_read(argument0, buffer_bool)) {
                    break;
                }
            }
        // SINGLE ENTITY //
        } else {
            // READ NEW INSTANCE INFORMATION //
            var nx = buffer_read(argument0, buffer_f64);
            var ny = buffer_read(argument0, buffer_f64);
            var no = buffer_read(argument0, buffer_u32);
            var ni = buffer_read(argument0, buffer_u32);
            // CREATE INSTANCE //
            with(instance_create(nx, ny, obj_entity)) {
                // ADD CONNECTION INFORMATION //
                server_id = ni;
                other.remote_entities[?ni] = id;
                // CHANGE INTO PROPER INSTANCE //
                instance_change(no, 1);
            }
        }
    break;
    case NET.DESTROY:
        //show_debug_message("NE: Client received entity destruction.");
        while(true) {
            var se = buffer_read(argument0, buffer_u32);
            with(remote_entities[?se]) {
                entity_cleanup();
            }
            ds_map_delete(remote_entities, se);
            if(!buffer_read(argument0, buffer_bool)) {
                break;
            }
        }
    break;
    case NET.CREATE_ID:
        //show_debug_message("NE: Client received entity ID.");
        // READ ID //
        with(buffer_read(argument0, buffer_u32)) {
            server_id = buffer_read(argument0, buffer_u32);
        }
    break;
    case NET.SYNC_ENTITY:
        //show_debug_message("NE: Client received entity information.");
        while(true) {
            // NEXT INSTANCE //
            if(!buffer_read(argument0, buffer_bool)) {
                break;
            }
            var i = buffer_read(argument0, buffer_u32);
            var r = remote_entities[?i];
            while(true) {
                // NEXT SYNC //
                if(!buffer_read(argument0, buffer_bool)) {
                    break;
                }
                var s = buffer_read(argument0, buffer_u8);
                switch(s) {
                    case SYNC.PROPERTIES:
                        if(is_undefined(r)) {
                            buffer_seek(argument0, buffer_seek_relative, 71);
                        } else {
                            r.solid = buffer_read(argument0, buffer_bool);
                            r.visible = buffer_read(argument0, buffer_bool);
                            r.persistent = buffer_read(argument0, buffer_bool);
                            r.depth = buffer_read(argument0, buffer_f64);
                            r.sprite_index = buffer_read(argument0, buffer_u32);
                            r.image_alpha = buffer_read(argument0, buffer_f64);
                            r.image_blend = buffer_read(argument0, buffer_f64);
                            r.image_index = buffer_read(argument0, buffer_f64);
                            r.image_speed = buffer_read(argument0, buffer_f64);
                            r.image_single = buffer_read(argument0, buffer_f64);
                            r.image_xscale = buffer_read(argument0, buffer_f64);
                            r.image_yscale = buffer_read(argument0, buffer_f64);
                        }
                    break;
                    case SYNC.MOVEMENT:
                        if(is_undefined(r)) {
                            buffer_seek(argument0, buffer_seek_relative, 56);
                        } else {
                            r.friction = buffer_read(argument0, buffer_f64);
                            r.gravity = buffer_read(argument0, buffer_f64);
                            r.gravity_direction = buffer_read(argument0, buffer_f64);
                            r.hspeed = buffer_read(argument0, buffer_f64);
                            r.vspeed = buffer_read(argument0, buffer_f64);
                            r.x = buffer_read(argument0, buffer_f64);
                            r.y = buffer_read(argument0, buffer_f64);
                        }
                    break;
                    case SYNC.PHYSICS:
                        if(is_undefined(r)) {
                            buffer_seek(argument0, buffer_seek_relative, 90);
                        } else {
                            r.phy_active = buffer_read(argument0, buffer_bool);
                            r.phy_angular_velocity = buffer_read(argument0, buffer_f64);
                            r.phy_angular_damping = buffer_read(argument0, buffer_f64);
                            r.phy_linear_velocity_x = buffer_read(argument0, buffer_f64);
                            r.phy_linear_velocity_y = buffer_read(argument0, buffer_f64);
                            r.phy_linear_damping = buffer_read(argument0, buffer_f64);
                            r.phy_speed_x = buffer_read(argument0, buffer_f64);
                            r.phy_speed_y = buffer_read(argument0, buffer_f64);
                            r.phy_position_x = buffer_read(argument0, buffer_f64);
                            r.phy_position_y = buffer_read(argument0, buffer_f64);
                            r.phy_rotation = buffer_read(argument0, buffer_f64);
                            r.phy_fixed_rotation = buffer_read(argument0, buffer_f64);
                            r.phy_bullet = buffer_read(argument0, buffer_bool);
                        }
                    break;
                    case SYNC.VARIABLES:
                        while(true) {
                            // NEXT VARIABLE //
                            if(!buffer_read(argument0, buffer_bool)) {
                                break;
                            }
                            var n = buffer_read(argument0, buffer_string);
                            var t = buffer_read(argument0, buffer_u8);
                            var v = buffer_read(argument0, t);
                            if(!is_undefined(r)) {
                                r.sv_values[?n] = v;
                            }
                        }
                    break;
                }
            }
        }
    break;
    case NET.SYNC_REQUEST:
        //show_debug_message("NE: Client received sync request.");
        for(var a = ds_list_size(local_entities) - 1; a >= 0; a -= 1) {
            with(local_entities[|a]) {
                for(var b = ds_list_size(sv_names) - 1; b >= 0; b -= 1) {
                    sv_changed[|sv_names[|b]] = true;
                }
            }
        }
    break;
}
