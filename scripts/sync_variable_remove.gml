///sync_variable_remove(name)
// WARNING: VARIABLE IS ONLY REMOVED LOCALLY
var i = ds_list_find_index(sv_names, argument0);
if(i >= 0) {
    ds_list_delete(sv_names, i);
    ds_map_delete(sv_types, argument0);
    ds_map_delete(sv, argument0);
    ds_map_delete(sv_tcp, argument0);
    ds_map_delete(sv_changed, argument0);
} else {
    show_debug_message("NE ERROR (sync_variable_remove): Variable does not exist.");
}
