require 'yaml'
require 'fileutils'

module Middleman
  module Cli

    class Prismic < Thor
      # Path where Middleman expects the local data to be stored
      MIDDLEMAN_LOCAL_DATA_FOLDER = 'data'

      check_unknown_options!

      namespace :prismic
      desc 'prismic', 'Import data from Prismic'

=begin
      method_option "refetch",
        aliases: "-r",
        desc: "Refetches the data from Prismic"
=end

      def self.source_root
        ENV['MM_ROOT']
      end

      # Tell Thor to exit with a nonzero exit code on failure
      def self.exit_on_failure?
        true
      end

      def prismic
        ::Middleman::Application.server.inst
        reference = MiddlemanPrismic.options.release

        Dir.mkdir('data') unless File.exists?('data')

        FileUtils.rm_rf(Dir.glob('data/prismic_*'))

        api = ::Prismic.api(MiddlemanPrismic.options.api_url)
        response = api.form('everything').submit(api.ref(reference))

        available_documents = []
        response.each {|d| available_documents << d.type}

        available_documents.uniq!

        available_documents.each do |document_type|
          documents = response.select{|d| d.type == document_type}
          File.open("data/prismic_#{document_type.pluralize}", 'w') do |f|
            f.write(Hash[[*documents.map.with_index]].invert.to_yaml)
          end
        end

        File.open('data/prismic_reference', 'w') do |f|
          f.write(api.master_ref.to_yaml)
        end

        MiddlemanPrismic.options.custom_queries.each do |k, v|
          response = api.form('everything').query(*v).submit(api.master_ref)
          File.open("data/prismic_custom_#{k}", 'w') do |f|
            f.write(Hash[[*response.map.with_index]].invert.to_yaml)
          end
        end
      end

    end
  end
end
