/*
	Constructors:
		GM_Map()
		GM_Map(Arg)
		GM_Map(Multimaps)
		GM_Map(Paired-Container)
		GM_Map(Builtin-Paired-Array)
		GM_Map(Builtin-Paired-List)
		GM_Map(Builtin-Map)
		GM_Map(Arg0, Arg1, ...)

	Initialize:
		new GM_Map()

	Usage:
		To Iterate values:
			for (var It = Container.first(); It.not_equals(Container.last()); It.go()) {
				myfunc(It.get())
			}
		
*/
function GM_Map(): Container() constructor {
	///@function size()
	static size = function() { return ds_map_size(raw) }

	///@function empty()
	static empty = function() { return ds_map_empty(raw) }

	///@function contains(key)
	static contains = function(K) { return ds_map_exists(raw, K) }

	///@function seek(key)
	static seek = function(K) { return ds_map_find_value(raw, K) }

	///@function at(index)
	static at = function(Index) { return (new iterator_type(self, Index)).get() }

	///@function back()
	static back = function() { return at(0) }

	///@function front()
	static front = function() {  return at(size()) }

	///@function first()
	static first = function() { return (new iterator_type(self, 0)).pure() }

	///@function last()
	static last = function() { return (new iterator_type(self, size())).pure() }

	///@function set(key, value)
	static set = function(K, Value) { ds_map_set(raw, K, Value) return self }

	///@function insert(item)
	static insert = function() {
		var Key, Value
		if argument_count == 2 {
			Key = argument[0]
			Value = argument[1]
		} else {
			var Pair = argument[0]
			Key = Pair[0]
			Value = Pair[1]
		}
		ds_map_set(raw, Pair[0], Pair[1])
		return self
	}

	///@function set_list(key, builtin_list_id)
	static set_list = function(K, Value) { ds_map_add_list(raw, K, Value) }

	///@function set_map(key, builtin_map_id)
	static set_map = function(K, Value) { ds_map_add_map(raw, K, Value)  }

	///@function erase_at(key)
	static erase_at = function(K) {
		var Temp = at(K)
		ds_map_delete(raw, K)
		return Temp
	}

	///@function clear()
	static clear = function() { ds_map_clear(raw) }

	///@function key_swap(key_1, key_2)
	static key_swap = function(Key1, Key2) {
		var Temp = at(Key1)
		ds_map_set(raw, Key1, at(Key2))
		ds_map_set(raw, Key2, Temp)
	}

	///@function is_list(key)
	static is_list = function(K) { return ds_map_is_list(raw, K) }

	///@function is_map(key)
	static is_map = function(K) { return ds_map_is_map(raw, K) }

	///@function read(data_string)
	static read = function(Str) {
		var loaded = ds_map_create()
		ds_map_read(loaded, Str)
		if 0 < ds_map_size(loaded) {
			var MIt = ds_map_find_first(loaded)
			while true {
				insert(MIt, ds_map_find_value(loaded, MIt))
				MIt = ds_map_find_next(loaded, MIt)
				if is_undefined(MIt)
					break
			}
		} 
	}

	///@function write()
	static write = function() { return ds_map_write(raw) }

	///@function destroy()
	static destroy = function() { ds_map_destroy(raw); gc_collect() }

	type = GM_Map
	raw = ds_map_create()
	iterator_type = MapIterator

	if 0 < argument_count {
		if argument_count == 1 {
			var Item = argument[0]
			if is_array(Item) {
				// (*) Built-in Paired-Array
				for (var i = 0; i < array_length(Item); ++i) insert(Item[i])
			} else if !is_nan(Item) and ds_exists(Item, ds_type_list) {
				// (*) Built-in Paired-List
				for (var i = 0; i < ds_list_size(Item); ++i) insert(Item[| i])
			} else if !is_nan(Item) and ds_exists(Item, ds_type_map) {
				// (*) Built-in Map
				var Size = ds_map_size(Item)
				if 0 < Size {
					var MIt = ds_map_find_first(Item)
					while true {
						insert(MIt, ds_map_find_value(Item, MIt))
						MIt = ds_map_find_next(Item, MIt)
						if is_undefined(MIt)
							break
					}
				}
			} else if is_struct(Item) {
				var Type = instanceof(Item)
				if Type == "Multimap" {
					// (*) Multimaps
					foreach(Item.first(), Item.last(), function(Value) {
						var Key = Value[0], KList = Value[1].duplicate()
						insert(Key, KList)
					})
				} else if is_iterable(Item) {
					// (*) Paired-Container
					foreach(Item.first(), Item.last(), function(Value) {
						insert(Value)
					})
				}
			} else {
				// (*) Arg
				insert(Item)
			}
		} else {
			// (*) Arg0, Arg1, ...
			for (var i = 0; i < argument_count; ++i) insert(argument[i])
		}
	}
}