# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


class DocumentController < ApplicationController

  def result
    @doc = params[:doc]
    @response = params[:response]  # TODO: FlareContext?

    @econ_doc_label = {
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


    @econ_sort_hash = {
      "id" => 1,
      "barcode_text" => 2,
      "coll_id_text" => 3,
      "family_facet" => 4,
      "genus_text" => 5,
      "species_text" => 6,
      "collection_facet" => 7, 
      "collector_text" => 8,
      "coll_date_text" => 9,
      "country_facet" => 10,
      "state_facet" => 11,
      "locality_text" => 12,
      "material_facet" => 14,
      "is_processed_facet" => 15,
      "specimen_format_facet" => 16,
      "description_text" => 17,
      "plant_part_text" => 18,
      "notes_text" => 19,
      "comment_text" => 20,
      "tdwg1_facet" => 21,
      "tdwg2_facet" => 22,
      "score" => 23,
    }

    render :template => "document/document_#{SOLR_ENV}"    
  end
  
end
