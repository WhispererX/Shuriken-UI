/**
 * @description Creates a new struct by merging properties from `dest` and `source`.
 *              Properties from `source` override those in `dest` if they share the same keys.
 * @param {Struct} dest - The base struct to copy values from.
 * @param {Struct} source - The struct whose values will override those in `dest`.
 * @returns {Struct} A new struct containing merged values.
 */
function struct_merge(dest, source) {
    var merged = {};
    var destNames = variable_struct_get_names(dest);
    var sourceNames = variable_struct_get_names(source);
    
    // Copy all from dest
    for (var i = 0; i < array_length(destNames); i++) {
        var name = destNames[i];
        merged[$ name] = dest[$ name];
    }
    
    // Override with source
    for (var i = 0; i < array_length(sourceNames); i++) {
        var name = sourceNames[i];
        merged[$ name] = source[$ name];
    }
    
    return merged;
}