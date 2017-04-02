///sync_variable_add(name, buffer_type, value, use_tcp)
//
// name: String which will be used to store the variable in the maps
// buffer_type: Buffer data type, example buffer_f64 or buffer_string
// value: Initial value
// use_tcp: If true, TCP will be used to sync the variable.
//          If false, UDP will be used to sync the variable.
//
// TCP VS UDP
//
// In this engine, a variable synchronised using TCP will only generate
// network traffic when the value of the variable changes.
// On the other hand, a variable synchronised using UDP will constantly
// generate network traffic as packets might get lost which UDP doesn't
// cover, so to offset this, a UDP variable will be sent over the
// network even if it didn't change.
//
// In general, you want to use TCP for variables which are only updated
// once in a while and you want to use UDP for variables that can
// potentially change every step.
//
if(is_string(argument0)) {
    if(ds_list_find_index(sv_names, argument0) == -1) {
        ds_list_add(sv_names, argument0);
        sv_types[?argument0] = argument1;
        sv[?argument0] = argument2;
        sv_tcp[?argument0] = !(!argument3);
        sv_changed[?argument0] = true;
    } else {
        show_debug_message("NE ERROR (sync_variable_add): Duplicate name.");
    }
} else {
    show_debug_message("NE ERROR (sync_variable_add): Name must be a string.");
}
