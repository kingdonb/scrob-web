#!/usr/bin/env ruby
# input-splitter.rb - generate k8s.yml in manifests/

require 'yaml'
require './lib/splat/splat'

array = []

  YAML.load_stream(STDIN) { |doc| array << doc }

  # Write the manifest files out
  Splat.write_namespaces_into_folder(target_dir: './manifests/k8s',
    namespaces_arr: Splat.sort_into_namespaces(array))

