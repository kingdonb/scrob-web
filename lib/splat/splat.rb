# typed: strict
require 'forwardable'
require 'fileutils'
require 'yaml'

module Splat
  class Splat
    # we need to define Splat.Splat if we want to live here according to zeitwerk
    # /Users/kingdonb/.rvm/gems/ruby-3.1.0/gems/zeitwerk-2.5.4/lib/zeitwerk/loader/callbacks.rb:25:in `on_file_autoloaded': expected file
    # /Users/kingdonb/projects/fluxcd/scrob-web/lib/splat/splat.rb to define constant Splat::Splat, but didn't (Zeitwerk::NameError)
  end

  # module_function -- ackshually https://stackoverflow.com/a/35012552/661659
  class << self
    def sort_into_namespaces(arr)
      arr.group_by {|o| o.dig("metadata", "namespace")}
    end

    def write_namespaces_into_folder(namespaces_arr:, target_dir:)
      # validate first
      namespaces_arr.values.flatten.map{|o|
        abort_if_missing_kind(o)
        abort_if_missing_name(o)
      }

      # write everything out into folders
      namespaces_arr.each do |namespace, arr|
        path = safe_path_ref(target_dir:target_dir, namespace:namespace)

        arr.each do |o|
          object_name = o.dig("metadata", "name")
          object_kind = o.dig("kind").downcase
          target_file = File.join(path, "#{object_name}-#{object_kind}.yaml")
          write_to_file(target_file: target_file, object: o)
        end
      end
    end

    private

    def mkdirp(p)
      FileUtils.mkdir_p(p)
    end

    def safe_path_ref(target_dir:, namespace:)
      path = if namespace.nil?
               target_dir
             else
               File.join(target_dir,namespace)
             end
      mkdirp(path); path
    end

    def abort_if_missing_kind(object)
      o = object.dig("kind")
      if o.nil? || (o&.length == 0)
        raise StandardError,
          "Kubernetes YAML resources cannot be missing apiVersion or kind"
      end
    end

    def abort_if_missing_name(object)
      o = object.dig("metadata","name")
      if o.nil? || (o&.length == 0)
        raise StandardError,
          "Kubernetes YAML resources cannot be missing metadata.name"
      end
    end

    def write_to_file(target_file:, object:)
      File.open(target_file, 'w') { |file| file.write(object.to_yaml) }
    end
  end
end
