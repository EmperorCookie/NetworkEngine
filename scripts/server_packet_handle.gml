///server_packet_handle(buffer,socket)
var reason, m;
reason = buffer_read(argument0, buffer_u8);
var connection_id = noone;
if(argument1 != socket_udp) {
    connection_id = ds_map_find_value(connections, argument1);
    connection_id.timeout = 0;
}
switch(reason) {
    case NET.UDP_PORT:
        //show_debug_message("NE: Server received UDP port.");
        connection_id.port_udp = buffer_read(argument0, buffer_u16);
    break;
    case NET.PING:
        //show_debug_message("NE: Server received pong.");
    break;
    case NET.TIME:
        //show_debug_message("NE: Server received time request.");
        var buff = buffer_create(1, buffer_grow, 1);
        buffer_write(buff, buffer_u8, NET.TIME);
        buffer_write(buff, buffer_f64, get_timer());
        network_send_packet(argument1, buff, buffer_tell(buff));
        buffer_delete(buff);
    break;
    case NET.CREATE:
        //show_debug_message("NE: Server received entity creation.");
        // READ NEW INSTANCE INFORMATION //
        var nm = buffer_read(argument0, buffer_bool);
        var nx = buffer_read(argument0, buffer_f64);
        var ny = buffer_read(argument0, buffer_f64);
        var no = buffer_read(argument0, buffer_u32);
        var ni = buffer_read(argument0, buffer_u32);
        // CREATE INSTANCE //
        var i = instance_create(nx, ny, obj_entity);
        i.server_id = i;
        // ADD CONNECTION INFORMATION //
        i.client_id = connection_id;
        ds_list_add(connection_id.entities, i);
        // SEND ENTITY ID TO CLIENT //
        var buff = buffer_create(1, buffer_grow, 1);
        buffer_write(buff, buffer_u8, NET.CREATE_ID);
        buffer_write(buff, buffer_u32, ni);
        buffer_write(buff, buffer_u32, i);
        network_send_packet(argument1, buff, buffer_tell(buff));
        buffer_delete(buff);
        // RELAY ENTITY CREATION TO OTHER CLIENTS //
        buff = buffer_create(1, buffer_grow, 1);
        buffer_write(buff, buffer_u8, NET.CREATE);
        buffer_write(buff, buffer_bool, 0);
        buffer_write(buff, buffer_f64, nx);
        buffer_write(buff, buffer_f64, ny);
        buffer_write(buff, buffer_u32, no);
        buffer_write(buff, buffer_u32, i);
        with(server_connection) {
            if(id != connection_id) {
                network_send_packet(socket, buff, buffer_tell(buff));
            }
        }
        buffer_delete(buff);
        // CHANGE INTO PROPER INSTANCE //
        with(i) {
            instance_change(no, 1);
        }
    break;
    case NET.DESTROY:
        //show_debug_message("NE: Server received entity destruction.");
        while(true) {
            var re = buffer_read(argument0, buffer_u32);
            with(re) {
                entity_cleanup();
            }
            ds_list_delete(connection_id.entities, ds_list_find_index(connection_id.entities, re));
            if(!buffer_read(argument0, buffer_bool)) {
                break;
            }
        }
    break;
    case NET.SYNC_ENTITY:
        //show_debug_message("NE: Server received entity information.");
        while(true) {
            // NEXT INSTANCE //
            if(!buffer_read(argument0, buffer_bool)) {
                break;
            }
            var i = buffer_read(argument0, buffer_u32);
            var r = i;
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
                                r.sv[?n] = v;
                            }
                        }
                    break;
                }
            }
        }
        // FORWARD TO OTHER PLAYERS //
        if(argument1 == socket_udp) {
            with(server_connection) {
                if(id != connection_id) {
                    if(port_udp != -1) {
                        network_send_udp(other.socket_udp, ip, port_udp, argument0, buffer_tell(argument0));
                    }
                }
            }
        } else {
            with(server_connection) {
                if(id != connection_id) {
                    network_send_packet(socket, argument0, buffer_tell(argument0));
                }
            }
        }
    break;
}
