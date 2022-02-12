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
    context 'namespaced content missing Kind' do
      let(:t) {
        {"foo"=>[{"metadata"=>{"namespace"=>"foo", "name"=>"foo"}}],
         "bar"=>[{"metadata"=>{"namespace"=>"bar", "name"=>"foo"}}]}
      }
      it 'fails' do
        expect {
          Splat.write_namespaces_into_folder(
            namespaces_arr: t, target_dir: 'test-tmp-dir')
        }.to raise_error(StandardError, "Kubernetes YAML resources cannot be missing apiVersion or kind")
      end
    end
    context 'namespaced content, properly formed' do
      let(:t) {
        {"foo"=>[{"metadata"=>{"namespace"=>"foo", "name"=>"foo"}, "apiVersion"=>"v1", "kind"=>"Whatever"}],
         "bar"=>[{"metadata"=>{"namespace"=>"bar", "name"=>"foo"}, "apiVersion"=>"v1", "kind"=>"Whatever"}]}
      }
      it 'works' do
        allow(Splat).to receive(:mkdirp)
        expect(Splat).to receive(:write_to_file).with(
          :object=>{"metadata"=>{"name"=>"foo","namespace"=>"foo"},"apiVersion"=>"v1","kind"=>"Whatever"},
          :target_file=>"test-tmp-dir/foo/foo-whatever.yaml"
        ).ordered
        expect(Splat).to receive(:write_to_file).with(
          :object=>{"metadata"=>{"name"=>"foo","namespace"=>"bar"},"apiVersion"=>"v1","kind"=>"Whatever"},
          :target_file=>"test-tmp-dir/bar/foo-whatever.yaml"
        ).ordered

        r = Splat.write_namespaces_into_folder(
          namespaces_arr: t, target_dir: 'test-tmp-dir')
      end
    end
    context 'unnamespaced content, properly formed' do
      let(:t) {
        {nil=>[{"metadata"=>{"name"=>"foo"}, "apiVersion"=>"v1", "kind"=>"Whatever"},
               {"metadata"=>{"name"=>"bar"}, "apiVersion"=>"v1", "kind"=>"Whatever"}]}
      }
      it 'works' do
        allow(Splat).to receive(:mkdirp)
        expect(Splat).to receive(:write_to_file).with(
          :object=>{"metadata"=>{"name"=>"foo"},"apiVersion"=>"v1","kind"=>"Whatever"},
          :target_file=>"test-tmp-dir/foo-whatever.yaml"
        ).ordered
        expect(Splat).to receive(:write_to_file).with(
          :object=>{"metadata"=>{"name"=>"bar"},"apiVersion"=>"v1","kind"=>"Whatever"},
          :target_file=>"test-tmp-dir/bar-whatever.yaml"
        ).ordered

        r = Splat.write_namespaces_into_folder(
          namespaces_arr: t, target_dir: 'test-tmp-dir')
      end
    end
  end
end
