#!/usr/bin/env ruby
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

# TODO: distill common shell script needs into common file for parsing parameters for Solr URL, input filename, -debug, etc
#       script/runner or script/console-like, from Rails.  A data mapper would be a great generalizable piece.


# mmk: I have modified this file to import data from csv for the Economic
# Botany collection at HUH.  I've just begun learning Ruby, so all code
# ugliness is entirely mine.  2007-12-11

require 'solr'
require 'fastercsv'

solr_url = ENV["SOLR_URL"] || "http://webprojects-dev.huh.harvard.edu:8080/solr"
econ_filename = ARGV[0]
debug = ARGV[1] == "-debug"

solr = Solr::Connection.new(solr_url)

# Exported column names
# ID,Barcode,CollectionIdentifier,Family,Genus,SpecificEpithet,DisplayDuplicate,Collection,Author,InfraRank,InfraEpithet,
# InfraAuthor,IsParaphernalia,CertaintyOfDet,Determiner,Collector,OtherCollector,CollectionDate,Country,State,Locality,Latitude
# Longitude,AcquiredOrPurchasedBy,Acquisition,AcquisitionDate,AqcuiredOfPurchasedFrom,AcquisitionCountry,AcquisitionState
# AcquisitionLocality,ClassificationOfMaterial,IsProcessed,IsArtifact,IsPotentialDisplayMaterial,SpecimenFormat,Description
# PlantPart,Condition,IsOversized,LabelNeeded,NashCase,Documentation,IsHerbariumSheet,NotesOnUsesAndProcessing,GeneralComments
# IsSecureStorage,IsAppraised,Status,Publication,TDWG_Level1,TDWG_Level2

def filter(doc)
  genus_text = doc['genus_text']

  if (genus_text == nil) then return true
  end

  genus_text = genus_text.downcase

  if (genus_text == 'papaver' or genus_text == 'psilocybe' or genus_text == 'erythroxylum')
  then return false
  end

  material_facet = doc['material_facet']

  if (genus_text == 'cannabis' and (!material_facet or material_facet.downcase != 'fiber & textiles'))
  then return false
  end

  coll_date_text = doc['coll_date_text']

  if (coll_date_text =~ /\b(\d{4})\b/) and ($1.to_i >= 1970)
  then return false
  end

  return true 
end

mapping = {
  "ID" => "id",
  "Barcode" => "barcode_text",
  "CollectionIdentifier" => "coll_id_text",
  "Family" => "family_facet",
  "Genus" => "genus_text",
  "SpecificEpithet" => "species_text",
  "Collection" => "collection_facet",
  "Collector" => "collector_text",
  "CollectionDate" => "coll_date_text",
  "Country" => "country_facet",
  "State" => "state_facet",
  "Locality" => "locality_text",
  "ClassificationOfMaterial" => "material_facet",
  "IsProcessed" => "is_processed_facet",
  "SpecimenFormat" => "specimen_format_facet",
  "Description" => "description_text",
  "PlantPart" => "plant_part_text",
  "NotesOnUsage" => "notes_text",
  "GeneralComments" => "comment_text",
  "TDWG_Level1" => "tdwg1_facet",
  "TDWG_Level2" => "tdwg2_facet",
}

count = 0
omits = 0

puts "importing records..."

FasterCSV.foreach(econ_filename, :headers=>true) do |row|
  if (count += 1) % 1000 == 0
  then puts "#{count}..."
  end

  doc = {}
  row.each do |heading, value|
    solr_name = mapping[heading]

    if value and solr_name
      then

      str_value = value.strip

      if solr_name == 'is_processed_facet'
        then
        str_value = str_value == '1' ? 'true' : 'false'
      end

      doc[solr_name] = str_value
    end

  end

  #puts doc.inspect if debug and !filter(doc)

  if (filter(doc) and !debug)
  then solr.add doc 
  else omits += 1
  end
  
end

solr.commit unless debug
solr.optimize unless debug

puts "processed #{count} records"
puts "omitted #{omits} records"
