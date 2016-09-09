///client_disconnect()
if(instance_number(client) > 0) {
    with(obj_entity) {
        entity_cleanup();
    }
    with(client) {
        network_destroy(socket);
        network_destroy(socket_udp);
        instance_destroy();
    }
}
