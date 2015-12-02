# Enables incremental static compilation.
__precompile__(true)


"""
# HavenOnDemand

Julia package to access HPE Haven OnDemand API.

* https://www.havenondemand.com

## Contact

-  Author: *Ismael Venegas Castelló*
-   Email: `ivenegas@richit.com.mx`
- License: **MIT**
-    Date: 2015
"""
module HavenOnDemand


export
    # General utilities:
    set_api_key, HODException, HOD_API,

    # Missing!:
    # list_stuff, job_status, job_result,

    # Speech Recognition:
    recognize_speech,

    # Connectors:
    cancel_connector_schedule, connector_history, connector_status,
    create_connector,          delete_connector,  retrieve_config,
    start_connector,           stop_connector,    update_connector,

    # Format Conversion:
    expand_container,  ocr_document, store_object, extract_text, view_document,

    # Image Analysis:
    recognize_barcodes, detect_faces, recognize_images,

    # Graph Analysis:
    get_common_neighbors, get_neighbors, get_nodes,       get_shortest_path,
    get_sub_graph,        suggest_links, summarize_graph,

    # Policy:
    create_classification_objects,   create_policy_objects,
    delete_classification_objects,   delete_policy_objects,
    retrieve_classification_objects, retrieve_policy_objects,
    update_classification_objects,   update_policy_objects,

    # Prediction:
    predict, recommend, train_predictor,

    # Query Profile and Manipulation:
    create_query_profile, delete_query_profile, retrieve_query_profile,
    update_query_profile,

    # Search:
    find_related_concepts, find_similar,     get_content,
    get_parametric_values, query_text_index, retrieve_index_fields,

    # Text Analysis:
    auto_complete,       classify_document, extract_concepts,
    categorize_document, entity_extraction, expand_terms,
    highlight_text,      identify_language, analyze_sentiment, tokenize_text,

    # Unstructured Text Indexing:
    add_to_text_index,      create_text_index, delete_text_index,
    delete_from_text_index, index_status,      list_resources,
    restore_text_index


using HttpCommon: Response
using   Requests: json,      post
using DataFrames: DataFrame, eachrow, readtable


import Base: showerror


"`String` is a `typealias` for `AbstractString`."
typealias String AbstractString


"`HavenOnDemand` Exception."
immutable HODException <: Exception
    "HttpCommon.Response returned from Haven OnDemand API."
    response::Response
end


"""
Shows `HavenOnDemand.HODException` error details, for more details, use a
`catch` block in order to inspect the **Haven OnDemand** response.
"""
function showerror(io::IO, ex::HODException)
    # Determine whether the request was `sync` or `async`:
    endpoint = match(
        r"sync/(.+)/",
        get(ex.response.request).resource
    ).captures[1]

    # Print each top level json attributes:
    println(io, typeof(ex), ": $endpoint")
    for (k, v) in json(ex.response)
        print(io, ucfirst(k), ": ")
        println(io, v)
    end

    println(io, "For more information, visit:")
    println(io, "* https://dev.havenondemand.com/apis/$(endpoint)")
end


"Main `HavenOnDemand` function, used to call **Haven OnDemand** API."
function call_HOD(
        endpoint        :: String,
        async           :: Bool;    # Some endpoints are `async_only`.
        api_url         :: String = "https://api.havenondemand.com",
        version         :: Int    = 1,
        default_version :: Int    = 1,
        options         :: Dict   = Dict()
    )

    try
        options["apikey"] = _HOD_API_KEY
    catch
        error("Use `HavenOnDemand.set_api_key(api_key::AbstractString)` first.")
    end

    sync_str = async ? "async" : "sync"
    r = post(
        "$(api_url)/$(version)/api/$(sync_str)/$(endpoint)/v$(default_version)",
        data = options
    )
    return r.status == 200 ? json(r) : throw(HODException(r))
end


"""
Sets the **HavenOn Demand** API key, this function must be called after
`using HavenOnDemand` with a valid key, in order to be able to use the Haven
OnDemand *API*.
"""
function set_api_key(api_key::String)
    global _HOD_API_KEY
    const _HOD_API_KEY = api_key
    return nothing
end


"`DataFrame` that holds the `HavenOnDemand` data used wrap the API."
const _HOD_API = readtable(
    joinpath(Pkg.dir("HavenOnDemand"), "src", "api.data"),
    separator = ' '
)

@doc (@doc _HOD_API) ->
const HOD_API = deepcopy(_HOD_API)    # add more rows


# Meta wrap most of the API:
for row in eachrow(_HOD_API::DataFrame)
    func_name, endpoint, async_only, description = [v for (k, v) in row]
    title = join([ucfirst(s) for s in split(func_name, '_')], ' ')
    docstring = """
        **HPE Haven OnDemand: $(title)**

        `$(func_name)([kwargs...])`

        $description

        All the arguments are optional and they must be supplied as keyword
        arguments, non valid keyword names are ignored.

        For information about valid arguments, visit:

        * https://dev.havenondemand.com/apis/$(endpoint)
        """

    @eval begin
        @doc $docstring ->
        function $(symbol(func_name))(; kwargs...)
            return call_HOD($endpoint, $async_only, options = Dict(kwargs))
        end
    end
end


end
