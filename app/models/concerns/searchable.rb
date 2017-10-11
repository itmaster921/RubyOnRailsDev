module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    def self.search(query)
      if query.present?
        __elasticsearch__.search("#{query.to_s.strip}").records
      else
        all
      end
    end

    def self.rebuild_elasticsearch_index
      __elasticsearch__.create_index! force: true
      __elasticsearch__.refresh_index!
    end

    # sync with elasticsearch
    begin
      __elasticsearch__.create_index! unless __elasticsearch__.index_exists?
      import
    rescue Exception => e
      p "Failed to index Searchable #{name}: #{e.message}"
    end
  end
end
