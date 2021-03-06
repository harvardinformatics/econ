# Copyright:: Copyright (c) 2007 Apache Software Foundation
# License::   Apache Version 2.0 (see http://www.apache.org/licenses/)

class BrowseController < ApplicationController
  before_filter :flare_before
  
  # def self.flare(options={})
  #   define_method() do
  #   end
  # end
  # 
  # flare do |f|
  #   f.facet_fields = []
  # end
  

  def index
    # TODO Add paging and sorting
    @info = solr(Solr::Request::IndexInfo.new) # TODO move this call to only have it called when the index may have changed
    @econ_facet_fields = @info.field_names.find_all {|v| v =~ /_facet$/}

    @facet_sort_hash = {
      "family_facet" => 1,
      "collection_facet" => 2,
      "country_facet" => 3,
      "state_facet" => 4,
      "material_facet" => 6,
      "is_processed_facet" => 7,
      "specimen_format_facet" => 8,
      "tdwg1_facet" => 9,
      "tdwg2_facet" => 10,
    }

    @econ_facet_labels = {
      "family_facet" => "Family",
      "collection_facet" => "Collection",
      "country_facet" => "Country",
      "state_facet" => "State",
      "material_facet" => "Classification of Material",
      "is_processed_facet" => "Is Processed?",
      "specimen_format_facet" => "Specimen Format",
      "tdwg1_facet" => "TDWG Level 1",
      "tdwg2_facet" => "TDWG Level 2",
    }

    @econ_doc_label = { # this is in document_controller.rb too, until I understand Rails scoping...
      "id" => "Record",
      "barcode_text" => "Barcode",
      "coll_id_text" => "Collection Identifier",
      "family_facet" => "Family",
      "genus_text" => "Genus",
      "species_text" => "Specific Epithet",
      "collection_facet" => "Collection",
      "collector_text" => "Collector",
      "coll_date_text" => "Collection Date",
      "country_facet" => "Country",
      "state_facet" => "State",
      "locality_text" => "Locality",
      "material_facet" => "Classification of Material",
      "is_processed_facet" => "Is Processed?",
      "specimen_format_facet" => "Specimen Format",
      "description_text" => "Description",
      "plant_part_text" => "Plant Part",
      "notes_text" => "Notes on Usage",
      "comment_text" => "General Comments",
      "tdwg1_facet" => "TDWG Level 1",
      "tdwg2_facet" => "TDWG Level 2",
    }

    @text_fields = @info.field_names.find_all {|v| v =~ /_text$/}
    
    session[:page] = sanitize(params[:page]).to_i if sanitize(params[:page])
    session[:page] = 1 if session[:page] <= 0
        
    @results_per_page = 25
    
    @start = (session[:page] - 1) * @results_per_page

    if (query and query.length > 0)
    then
      request = Solr::Request::Standard.new(:query => query,
                                            :filter_queries => filters,
                                            :rows => @results_per_page,
                                            :start => @start,
                                            :facets => {:fields => @econ_facet_fields, :limit => 20 , :mincount => 1, :sort => :count, :debug_query=>true},
                                            :highlighting => {:field_list => @text_fields})
      # logger.info({:query => query, :filter_queries => filters}.inspect)
      @response = solr(request)
    end

    #TODO: call response.field_facets(??) - maybe field_facets should be return a higher level? 
  end
  
  def facet
    @facets = retrieve_field_facets(sanitize(params[:field_name]))
  end
  
  def auto_complete_for_search_query
    # TODO instead of "text", default to the default search field configured in schema.xml
    @values = retrieve_field_facets("text", 5, sanitize(params['search']['query']).downcase)
    
    render :partial => 'suggest'
  end

  def add_query
    query = sanitize(params[:search][:query])
    query ||= ""

    if query.strip.length > 0
    then
    session[:queries] << {:query => query}
    session[:page] = 1
    end

    redirect_to :action => 'index'
  end
  
  def update_query
    # logger.debug "update_query: #{params.inspect}"
    session[:queries][sanitize(params[:index]).to_i][:query] = sanitize(params[:value])
    session[:page] = 1
    render :update do |page|
      page.redirect_to '/browse'
    end
  end

  def invert_query
    q = session[:queries][sanitize(params[:index]).to_i]
    q[:negative] = !q[:negative]
    session[:page] = 1
    redirect_to :action => 'index'
  end

  def remove_query
    session[:queries].delete_at(sanitize(params[:index]).to_i)
    session[:page] = 1
    redirect_to :action => 'index'
  end

  def invert_filter
    f = session[:filters][sanitize(params[:index]).to_i]
    f[:negative] = !f[:negative]
    session[:page] = 1
    redirect_to :action => 'index'
  end
  
  def remove_filter
    session[:filters].delete_at(sanitize(params[:index]).to_i)
    session[:page] = 1
    redirect_to :action => 'index'
  end
  
  def add_filter
    session[:filters] << {:field => sanitize(params[:field_name]), :value => sanitize(params[:value]), :negative => (params[:negative] ? true : false)} 
    session[:page] = 1
    redirect_to :action => 'index'
  end
  
  def clear
    session[:queries] = nil
    session[:filters] = nil
    session[:page] = 1
    flare_before
    redirect_to :action => 'index'
  end
  
  private
  def flare_before
    session[:queries] ||= [] 
    session[:filters] ||= []
    session[:page] ||= 1
  end
  
  def retrieve_field_facets(field, limit=-1, prefix=nil)
    req = Solr::Request::Standard.new(:query => query,
       :filter_queries => filters,
       :facets => {:fields => [field],
                   :mincount => 1, :limit => limit, :prefix => prefix, :missing => true, :sort => :count
                  },
       :rows => 0
    )
    
    results = SOLR.send(req)
    
    results.field_facets(field)
  end

  def sanitize(string)
    if string
    then
    string = string.gsub('&', ' and ')
    string = string.gsub(/\W/, ' ')
    string = string.gsub(/\s+/, ' ')
    end

    string
  end
  
end
