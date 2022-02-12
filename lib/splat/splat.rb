# typed: strict
require 'forwardable'
require 'fileutils'
require 'yaml'

module Splat
  module_function
  def sort_into_namespaces(arr)
    arr.group_by {|o| o.dig("metadata", "namespace")}
  end

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

  def write_to_file(target_file:, object:)
    File.open(target_file, 'w') { |file| file.write(object.to_yaml) }
  end
end

