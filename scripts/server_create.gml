///server_create(port, max_players, tick_rate, timeout)
if(instance_number(server) > 0) {
    show_debug_message("NE ERROR (server_create): Server already exists.");
    return noone;
}
if(instance_number(client) > 0) {
    show_debug_message("NE ERROR (server_create): Client already exists.");
    return noone;
}
with(instance_create(0, 0, server)) {
    port = argument0;
    max_players = argument1;
    tick_rate = argument2;
    timeout = argument3;
    // START SERVER //
    socket = network_create_server(network_socket_tcp, port, max_players);
    socket_udp = network_create_server(network_socket_udp, port, max_players);
    if(socket >= 0 && socket_udp >= 0) {
        show_debug_message("NE: Server created on port " + string(port) + ".");
        return id;
    } else {
        show_debug_message("NE ERROR (server_create): Socket creation failed. Please check that port " + string(port) + " isn't already in use.");
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
