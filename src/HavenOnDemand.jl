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
using Requests: json, post

import Base: showerror

type HODException <: Exception
    response::Response
end

function showerror(io::IO, ex::HODException)
    println(io, typeof(ex))
    for (k, v) in json(ex.response)
        print(io, string(uppercase(k), ": "))
        println(io, v)
    end
    println(io, "For more information, visit: https://dev.havenondemand.com/apis")
end

function call_HOD(
        endpoint        :: ASCIIString,
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

const HOD_APPS = Dict(
    :recognize_speech                => ["recognizespeech",               "Transcribes speech to text from a video or audio file."],
    :cancel_connector_schedule       => ["cancelconnectorschedule",       "Cancels a connector schedule."],
    :connector_history               => ["connectorhistory",              "Returns connector status history information."],
    :connector_status                => ["connectorstatus",               "Returns connector status information."],
    :create_connector                => ["createconnector",               "Creates a connector."],
    :delete_connector                => ["deleteconnector",               "Delete a connector."],
    :retrieve_config                 => ["retrieveconfig",                "Retrieves a connector configuration."],
    :start_connector                 => ["startconnector",                "Starts a connector."],
    :stop_connector                  => ["stopconnector",                 "Stops a running connector."],
    :update_connector                => ["updateconnector",               "Updates a connector."],
    :expand_container                => ["expandcontainer",               "Extracts the contents of a container file."],
    :store_object                    => ["storeobject",                   "Stores a file."],
    :extract_text                    => ["extracttext",                   "Extracts text from a file."],
    :view_document                   => ["viewdocument",                  "Converts a document to HTML format for viewing in a Web browser."],
    :ocr_document                    => ["ocrdocument",                   "Extracts text from an image."],
    :recognize_barcodes              => ["recognizebarcodes",             "Detects and decodes 1D and 2D barcodes in an image that you provide."],
    :detect_faces                    => ["detectfaces",                   "Detects faces in an image."],
    :recognize_images                => ["recognizeimages",               "Recognizes a known set of images in an image that you provide."],
    :get_common_neighbors            => ["getcommonneighbors",            "Finds the common neighbors of the nodes that you specify."],
    :get_neighbors                   => ["getneighbors",                  "List the neighbors of one or more specified nodes."],
    :get_nodes                       => ["getnodes",                      "Lists the nodes in your graph."],
    :get_shortest_path               => ["getshortestpath",               "Finds the shortest path in the graph between two specified nodes."],
    :get_sub_graph                   => ["getsubgraph",                   "Returns a subgraph based on a set of nodes that you provide."],
    :suggest_links                   => ["suggestlinks",                  "Suggests nodes that a specified node is close to in the graph, but that it does not currently connect to."],
    :summarize_graph                 => ["summarizegraph",                "Returns a summary of what is in the graph."],
    :create_classification_objects   => ["createclassificationobjects",   "Create objects supporting document classification."],
    :create_policy_objects           => ["createpolicyobjects",           "Create policies or policy types."],
    :delete_classification_objects   => ["deleteclassificationobjects",   "Delete objects supporting document classification."],
    :delete_policy_objects           => ["deletepolicyobjects",           "Delete policies or policy types."],
    :retrieve_classification_objects => ["retrieveclassificationobjects", "Retrieve objects supporting document classification."],
    :retrieve_policy_objects         => ["retrievepolicyobjects",         "Retrieve policies or policy types."],
    :update_classification_objects   => ["updateclassificationobjects",   "Update objects supporting document classification."],
    :update_policy_objects           => ["updatepolicyobjects",           "Update policies or policy types."],
    :predict                         => ["predict",                       "Runs the prediction model on the provided data."],
    :recommend                       => ["recommend",                     "Runs the prediction model on the provided data, and provide desired recommendations."],
    :train_predictor                 => ["trainpredictor",                "Trains a prediction model."],
    :create_query_profile            => ["createqueryprofile",            "Create a query profile."],
    :delete_query_profile            => ["deletequeryprofile",            "Delete a query profile."],
    :retrieve_query_profile          => ["retrievequeryprofile",          "Retrieve a query profile."],
    :update_query_profile            => ["updatequeryprofile",            "Update a query profile."],
    :find_related_concepts           => ["findrelatedconcepts",           "Returns the best terms and phrases in documents that match the specified query."],
    :find_similar                    => ["findsimilar",                   "Finds documents that are conceptually similar to your text or a document."],
    :get_content                     => ["getcontent",                    "Display the content of one or more specified documents or document sections."],
    :get_parametric_values           => ["getparametricvalues",           "Performs parametric search that combines query text with one or more parametric field names."],
    :query_text_index                => ["querytextindex",                "Searches for items that match your specified natural language text, Boolean expressions, or fields."],
    :retrieve_index_fields           => ["retrieveindexfields",           "Retrieves the ingested fields for a specified field type or for all field types."],
    :auto_complete                   => ["autocomplete",                  "Completes a word fragment."],
    :classify_document               => ["classifydocument",              "Classifies a document into predefined collections."],
    :extract_concepts                => ["extractconcepts",               "Extracts the key concepts from the text you submit."],
    :categorize_document             => ["categorizedocument",            "Searches for categories that match a specified document."],
    :entity_extraction               => ["extractentities",               "Extracts entities (words, phrases, or blocks of information) from your input text."],
    :expand_terms                    => ["expandterms",                   "Returns a list of matching possible terms for a wildcard, stem, or fuzzy expansion."],
    :highlight_text                  => ["highlighttext",                 "Highlights the specified terms in the text you submit."],
    :identify_language               => ["identifylanguage",              "Identifies the language of a piece of text."],
    :analyze_sentiment               => ["analyzesentiment",              "Analyzes text for positive or negative sentiment."],
    :tokenize_text                   => ["tokenizetext",                  "Returns information about the terms in the specified text."],
    :add_to_text_index               => ["addtotextindex",                "Indexes a document."],
    :create_text_index               => ["createtextindex",               "Creates a text index."],
    :delete_text_index               => ["deletetextindex",               "Deletes a text index."],
    :delete_from_text_index          => ["deletefromtextindex",           "Deletes a document from the index."],
    :index_status                    => ["indexstatus",                   "Returns index status information."],
    :list_resources                  => ["listresources",                 "Lists your dynamic resources."],
    :restore_text_index              => ["restoretextindex",              "Restores a text index at a previous state."]
)


for (func, data) in HOD_APPS
    endpoint, documentation = data
    title = join([string(uppercase(s[1]), s[2:end]) for s in split(string(func), '_')], ' ')
    docstring = (
        """
        # HPE Haven OnDemand: $(title)

        <br>

        `$(func)(;async = false, kwargs...)`: $documentation

        <br>

        For more information, visit:

        * https://dev.havenondemand.com/apis/$(endpoint)
        """
    )
    @eval begin
        @doc $docstring ->
        $(func)(;async = false, kwargs...) = call_HOD($endpoint, async, options = Dict(kwargs))
    end
end

end
