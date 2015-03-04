require 'yaml'

module Middleman
  module Cli

    class Prismic < Thor
      # Path where Middleman expects the local data to be stored
      MIDDLEMAN_LOCAL_DATA_FOLDER = 'data'

      check_unknown_options!

      namespace :prismic
      desc 'prismic', 'Import data from Prismic'

      method_option "refetch",
        aliases: "-r",
        desc: "Refetches the data from Prismic"

      def self.source_root
        ENV['MM_ROOT']
      end

      # Tell Thor to exit with a nonzero exit code on failure
      def self.exit_on_failure?
        true
      end

      def prismic
        ::Middleman::Application.server.inst

        api = ::Prismic.api(MiddlemanPrismic.options.api_url)
        response = api.form('everything').submit(api.master_ref)

        available_documents = []
        response.each {|d| available_documents << d.type}

        available_documents.uniq!

        available_documents.each do |document_type|
          documents = response.select{|d| d.type == document_type}
          File.open("data/#{document_type.pluralize}", 'w') do |f|
            f.write(Hash[[*documents.map.with_index]].invert.to_yaml)
          end
        end

      end

    end
  end
end
