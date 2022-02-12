require './lib/splat/splat'
# Splat.write_namespaces_into_folder(
#   target_dir: './secrets',
#   namespaces_arr: Splat.sort_into_namespaces(secrets))

RSpec.describe Splat do
  describe '#sort_into_namespaces' do
    it 'groups by namespace' do
      t = [{"metadata"=> {"namespace"=> "foo"}}, {"metadata"=> {"namespace"=> "bar"}}]
      r = Splat.sort_into_namespaces(t)
      expect(r.keys).to eq(['foo', 'bar'])
    end

    it 'puts unnamespaced things into a separate bin' do
      t = [{"metadata"=> {"name"=> "foo"}}, {"metadata"=> {"name"=> "bar"}}]
      r = Splat.sort_into_namespaces(t)
      expect(r.keys).to eq([nil])
    end
  end

  describe '#write_namespaces_into_folder' do
    context 'namespaced content' do
      let(:t) {
        {"foo"=>[{"metadata"=>{"namespace"=>"foo", "name"=>"foo"}}],
         "bar"=>[{"metadata"=>{"namespace"=>"bar", "name"=>"foo"}}]}
      }
      it 'works' do
        allow(Splat).to receive(:mkdirp)
        expect(Splat).to receive(:write_to_file).with(
          :object=>{"metadata"=>{"name"=>"foo", "namespace"=>"foo"}},
          :target_file=>"test-tmp-dir/foo/foo.yaml"
        ).ordered
        expect(Splat).to receive(:write_to_file).with(
          :object=>{"metadata"=>{"name"=>"foo", "namespace"=>"bar"}},
          :target_file=>"test-tmp-dir/bar/foo.yaml"
        ).ordered

        r = Splat.write_namespaces_into_folder(
          namespaces_arr: t, target_dir: 'test-tmp-dir')
      end
    end
    context 'unnamespaced content' do
      let(:t) {
        {nil=>[{"metadata"=>{"name"=>"foo"}},
               {"metadata"=>{"name"=>"bar"}}]}
      }
      it 'works' do
        allow(Splat).to receive(:mkdirp)
        expect(Splat).to receive(:write_to_file).with(
          :object=>{"metadata"=>{"name"=>"foo"}},
          :target_file=>"test-tmp-dir/foo.yaml"
        ).ordered
        expect(Splat).to receive(:write_to_file).with(
          :object=>{"metadata"=>{"name"=>"bar"}},
          :target_file=>"test-tmp-dir/bar.yaml"
        ).ordered

        r = Splat.write_namespaces_into_folder(
          namespaces_arr: t, target_dir: 'test-tmp-dir')
      end
    end
  end
end
