# NetworkEngine

NetworkEngine is designed to be as simple as possible to use but at the same time to be very powerful and efficient.

**Features**

* Server-client model
* Uses GameMaker:Studio's built-in network functions
* Inherently cross-platform
* Uses both TCP and UDP where it makes sense
* Supports GameMaker:Studio's built-in object variables
* Custom variables through sync variable functions

**Future Features**

* Zone system allows network entities to be separated into virtual zones to prevent useless traffic
* Remote function execution, supports both global and entity-centric
* Movement smoothing with support for both interpolation and extrapolation

## Using NetworkEngine

### Setup

**Important:** The server is also a client in this engine, so there is no need to connect to a server that was hosted locally.

1. Create (`server_create`) or join (`client_connect`) by IP (You can also use DNS lookup `network_resolve` with the built-in GM:S function)
2. Start using the engine

### Entities

In order to define an entity in GM:S, you create a regular object and make it a child of `obj_entity`.

Entity instances should be created using `entity_create` instead of `instance_create` and destroyed using `entity_destroy`.

Entities have some useful variables that you can set in order to get started easily:

* `is_local` is either 0 if the entity is remote or 1 if it's local
* `sync_properties` tells the engine whether to sync built-in properties like sprite_index, mask_index, image_speed, depth, etc.
* `sync_movement` tells the engine whether to sync built-in movement like speed, x, y, gravity, etc.
* `sync_physics` tells the engine whether to sync built-in physics
* `server_id` is the instance ID on the server, which will match across all clients

**Sync Variables**

All sync variables are local. There is currently no support for global variables and it is not a feature that is planned for the future.

You create a sync variable using `sync_variable_add` and access it using either `sync_variable_get` or `sv_values[?"variable_name"]`.

* `sv_values` is a `ds_map` that holds the values of all sync variables, it is safe to access it but to modify it you should use `sync_variable_set`
* `sync_variable_add` adds a sync variable to the entity
* `sync_variable_remove` removes a sync variable from the entity but only locally
* `sync_variable_set` sets the value of a sync variable
* `sync_variable_get` gets the value of a sync variable, but you can also use `sv_values[?"variable_name"]`

**TCP vs UDP**

Sync variables support both TCP and UDP. 

In this engine, a variable synchronised using TCP will only generate network traffic when the value of the variable changes. On the other hand, a variable synchronised using UDP will constantly generate network traffic as packets might get lost which UDP doesn't cover, so to offset this, a UDP variable will be sent over the network even if it didn't change.

In general, you want to use TCP for variables which are only updated once in a while and you want to use UDP for variables that can potentially change every step.

## Contributing

The project is open to contributions. Please use GitFlow.

Note that this project is intended to be released on the YYG Marketplace, so the license will be their EULA.