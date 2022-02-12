# typed: strict
require 'forwardable'
require 'fileutils'
require 'yaml'

module Splat
  module_function
  def sort_into_namespaces(arr)
    arr.group_by {|o| o.dig("metadata", "namespace")}
  end

  def write_namespaces_into_folder(namespaces_arr:, target_dir:)
    namespaces_arr.each do |namespace, arr|
      path = File.join(target_dir,namespace)
      FileUtils.mkdir_p path
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

