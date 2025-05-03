/**
 * @description Returns a struct containing only the key-value pairs from `compare` that differ from or are not present in `base`.
 * This is useful for tracking changes or generating diffs between two structs.
 *
 * @param {Struct} base - The original struct to compare against.
 * @param {Struct} compare - The struct whose values will be compared with `base`.
 * @returns {Struct} A new struct with only the keys whose values are different or missing in `base`.
 */
function struct_subtract(base, compare) {
    var result = {};
    var keys = variable_struct_get_names(compare);

    for (var i = 0; i < array_length(keys); i++) {
        var key = keys[i];

        var in_base = variable_struct_exists(base, key);
        var value_compare = compare[$ key];
        var value_base = in_base ? base[$ key] : undefined;

        if (!in_base || value_compare != value_base) {
            result[$ key] = value_compare;
        }
    }

    return result;
}
