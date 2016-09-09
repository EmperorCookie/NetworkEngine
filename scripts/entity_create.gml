///entity_create(x, y, object)
if(!object_is_ancestor(argument2, obj_entity)) {
    show_debug_message("NE ERROR (entity_create): " + object_get_name(argument2) + " must be a child of obj_entity.");
    return noone;
}
var host = noone;
if(instance_number(server) > 0) {
    host = server.id;
} else {
    if(instance_number(client) > 0) {
        host = client.id;
    }
}
if(host == noone) {
    show_debug_message("NE ERROR (entity_create): Game host could not be found.");
    return noone;
}
var i = instance_create(argument0, argument1, obj_entity);
i.is_local = 1;
ds_list_add(host.local_entities, i);
var buff = buffer_create(1, buffer_grow, 1);
buffer_write(buff, buffer_u8, NET.CREATE);
buffer_write(buff, buffer_bool, 0);
buffer_write(buff, buffer_f64, argument0);
buffer_write(buff, buffer_f64, argument1);
buffer_write(buff, buffer_u32, argument2);
buffer_write(buff, buffer_u32, i);
if(host.object_index == server) {
    i.server_id = i;
    with(server_connection) {
        network_send_packet(socket, buff, buffer_tell(buff));
    }
} else {
    network_send_packet(host.socket, buff, buffer_tell(buff));
}
buffer_delete(buff);
with(i) {
    instance_change(argument2, 1);
}
return i;
