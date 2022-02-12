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

  def write_namespaces_into_folder(namespaces_arr:, target_dir:)
    namespaces_arr.each do |namespace, arr|
      path = safe_path_ref(target_dir:target_dir, namespace:namespace)

      arr.each do |o|
        object_name = o.dig("metadata", "name")
        target_file = File.join(path, "#{object_name}.yaml")
        write_to_file(target_file: target_file, object: o)
      end
    end
  end

  def write_to_file(target_file:, object:)
    File.open(target_file, 'w') { |file| file.write(object.to_yaml) }
  end
end

