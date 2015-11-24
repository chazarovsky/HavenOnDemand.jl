module HavenOnDemand

export set_api_key,

       # Speech Recognition
       recognize_speech,

       # Connectors
       cancel_connector_schedule,
       connector_history,
       connector_status,
       create_connector,
       delete_connector,
       retrieve_config,
       start_connector,
       stop_connector,
       update_connector,

       # Format Conversion
       expand_container,
       ocr_document,
       store_object,
       extract_text,
       view_document,

       # Image Analysis
       recognize_barcodes,
       detect_faces,
       recognize_images,

       # Graph Analysis
       get_common_neighbors,
       get_neighbors,
       get_nodes,
       get_shortest_path,
       get_sub_graph,
       suggest_links,
       summarize_graph,

       # Policy
       create_classification_objects,
       create_policy_objects,
       delete_classification_objects,
       delete_policy_objects,
       retrieve_classification_objects,
       retrieve_policy_objects,
       update_classification_objects,
       update_policy_objects,

       # Prediction
       predict,
       recommend,
       train_predictor,

       # Query Profile and Manipulation
       create_query_profile,
       delete_query_profile,
       retrieve_query_profile,
       update_query_profile,

       # Search
       find_related_concepts,
       find_similar,
       get_content,
       get_parametric_values,
       query_text_index,
       retrieve_index_fields,

       # Text Analysis
       auto_complete,
       classify_document,
       extract_concepts,
       categorize_document,
       entity_extraction,
       expand_terms,
       highlight_text,
       identify_language,
       analyze_sentiment,
       tokenize_text,

       # Unstructured Text Indexing
       add_to_text_index,
       create_text_index,
       delete_text_index,
       delete_from_text_index,
       index_status,
       list_resources,
       restore_text_index

using HttpCommon: Response
using Requests:   json, post
using DataFrames: readtable, eachrow

import Base: showerror

type HODException <: Exception
    response::Response
end

function showerror(io::IO, ex::HODException)
    endpoint = match(r"sync/(.+)/", get(ex.response.request).resource)[1]
    println(io, typeof(ex))
    for (k, v) in json(ex.response)
        print(io, string(uppercase(k), ": "))
        println(io, v)
    end
    println(io, "For more information, visit:")
    println(io, "* https://dev.havenondemand.com/apis/$(endpoint)")
end

function call_HOD(
        endpoint        :: UTF8String,
        async           :: Bool;
        api_url         :: ASCIIString = "https://api.havenondemand.com",
        version         :: Int         = 1,
        default_version :: Int         = 1,
        options         :: Dict        = Dict(),
    )
    try
        options["apikey"] = HOD_API_KEY
    catch
        error("Use `HavenOnDemand.set_api_key(api_key::ASCIIString)` first.")
    end
    sync_str = async ? "async" : "sync"
    r = post("$(api_url)/$(version)/api/$(sync_str)/$(endpoint)/v$(default_version)", data = options)
    return r.status == 200 ? json(r) : throw(HODException(r))
end

set_api_key(api_key::ASCIIString) = (global HOD_API_KEY; HOD_API_KEY = api_key; nothing)

const API = readtable(joinpath(Pkg.dir("HavenOnDemand"), "src", "api.csv"), separator = ' ')
      API[:func_name] = Symbol[API[:func_name]...]

for row in eachrow(API)
    func_name   = row[:func_name]
    endpoint    = row[:endpoint]
    description = row[:description]
    title = join([ucfirst(s) for s in split(string(func_name), '_')], ' ')
    docstring = (
        """
        # HPE Haven OnDemand: $(title)

        `$(func_name)(;async = false, kwargs...)`

        $description

        For more information, visit:

        * https://dev.havenondemand.com/apis/$(endpoint)
        """
    )
    @eval begin
        @doc $docstring ->
        $(func_name)(;async = false, kwargs...) = call_HOD($endpoint, async, options = Dict(kwargs))
    end
end

end
