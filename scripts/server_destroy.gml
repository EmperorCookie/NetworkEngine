///server_destroy()
if(instance_number(server) > 0) {
    var buff = buffer_create(1, buffer_grow, 1);
    buffer_write(buff, buffer_u8, NET.DISCONNECT);
    buffer_write(buff, buffer_string, "Server shut down.");
    with(server_connection) {
        network_send_packet(socket, buff, buffer_tell(buff));
        instance_destroy();
    }
    buffer_delete(buff);
    with(obj_entity) {
        entity_cleanup();
    }
    with(server) {
        network_destroy(socket);
        network_destroy(socket_udp);
        instance_destroy();
    }
}
