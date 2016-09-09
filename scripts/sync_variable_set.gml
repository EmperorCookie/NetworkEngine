///sync_variable_set(name, value)
if(is_local) {
    if(ds_list_find_index(sv_names, argument0) >= 0) {
        sv_values[?argument0] = argument1;
        sv_changed[?argument0] = true;
    } else {
        show_debug_message("NE ERROR (sync_variable_set): Variable does not exist.");
    }
} else {
    show_debug_message("NE ERROR (sync_variable_set): Instance must be local.");
}
