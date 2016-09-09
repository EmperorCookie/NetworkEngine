///entity_destroy(instance_id)
if(object_is_ancestor(argument0.object_index, obj_entity)) {
    var host = noone;
    if(instance_number(server) > 0) {
        host = server.id;
    } else {
        if(instance_number(client) > 0) {
            host = client.id;
        }
    }
    if(host != noone) {
        if(argument0.is_local) {
            var buff = buffer_create(1, buffer_grow, 1);
            buffer_write(buff, buffer_u8, NET.DESTROY);
            buffer_write(buff, buffer_u32, argument0.server_id);
            buffer_write(buff, buffer_bool, 0);
            if(host.object_index == server) {
                with(server_connection) {
                    network_send_packet(socket, buff, buffer_tell(buff));
                }
            } else {
                network_send_packet(host.socket, buff, buffer_tell(buff));
            }
            buffer_delete(buff);
            ds_list_delete(host.local_entities, ds_list_find_index(host.local_entities, argument0));
            with(argument0) {
                entity_cleanup();
            }
        } else {
            show_debug_message("NE ERROR (entity_destroy): Entity is not local.");
        }
    } else {
        show_debug_message("NE ERROR (entity_destroy): Game host could not be found.");
    }
} else {
    show_debug_message("NE ERROR (entity_destroy): Object is not an entity.");
}
