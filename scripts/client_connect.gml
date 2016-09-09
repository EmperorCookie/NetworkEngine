///client_connect(ip, port, timeout_ms)
if(instance_number(server) > 0) {
    show_debug_message("NE ERROR (client_connect): Server already exists.");
    return noone;
}
if(instance_number(client) > 0) {
    show_debug_message("NE ERROR (client_connect): Client already exists.");
    return noone;
}
with(instance_create(0, 0, client)) {
    server_ip = argument0;
    port = argument1;
    // CONNECT TO SERVER //
    socket = network_create_socket(network_socket_tcp);
    repeat(10) {
        port_udp = 15000 + floor(random(50000));
        socket_udp = network_create_socket_ext(network_socket_udp, port_udp);
    }
    network_set_config(network_config_connect_timeout, argument2);
    if(socket >= 0 && socket_udp >= 0) {
        if(network_connect(socket, server_ip, port) >= 0) {
            show_debug_message("NE: Connected to server.");
            // SEND UDP PORT //
            var buff = buffer_create(1, buffer_grow, 1);
            buffer_write(buff, buffer_u8, NET.UDP_PORT);
            buffer_write(buff, buffer_u16, port_udp);
            network_send_packet(socket, buff, buffer_tell(buff));
            // SEND UDP PING //
            buffer_seek(buff, buffer_seek_start, 0);
            buffer_write(buff, buffer_u8, NET.PING);
            network_send_udp(socket_udp, server_ip, port, buff, buffer_tell(buff));
            // SEND TIME REQUEST //
            buffer_seek(buff, buffer_seek_start, 0);
            buffer_write(buff, buffer_u8, NET.TIME);
            server_time_timer = get_timer();
            network_send_packet(socket, buff, buffer_tell(buff));
            buffer_delete(buff);
            return id;
        } else {
            show_debug_message("NE ERROR (client_connect): Server did not respond.");
            network_destroy(socket);
            network_destroy(socket_udp);
            instance_destroy();
        }
    } else {
        show_debug_message("NE ERROR (client_connect): Socket creation failed. Please check that port " + string(port) + " isn't already in use.");
        if(socket >= 0) {
            network_destroy(socket);
        }
        if(socket_udp >= 0) {
            network_destroy(socket_udp);
        }
        instance_destroy();
    }
}
return noone;
